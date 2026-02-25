import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as filePath;
import 'package:path_provider/path_provider.dart';
import '../../db_flo_bloom/data.dart';
import '../../db_flo_bloom/db_flo_bloom_entity.dart';
import '../../utils/index.dart';
import 'particle_effect_painter.dart';

class FloBloomEffectEditorLogic extends GetxController
    with GetTickerProviderStateMixin {
  final _db = FloBloomDatabase();
  final previewKey = GlobalKey();
  Rx<File?> originalImage = Rx<File?>(null);
  var selectedEffect = 'None'.obs;
  var density = 50.0.obs;
  var speed = 50.0.obs;
  var opacity = 75.0.obs;
  var isPlaying = true.obs;
  final isProcessing = false.obs;
  final hasChanges = false.obs;
  late AnimationController particleController;
  late final List<Particle> particles;
  static const int _maxParticles = 60;
  String get densityLabel {
    if (density.value < 33) return 'Low';
    if (density.value < 67) return 'Medium';
    return 'High';
  }

  String get speedLabel {
    if (speed.value < 33) return 'Slow';
    if (speed.value < 67) return 'Normal';
    return 'Fast';
  }

  String get opacityLabel => '${opacity.value.toInt()}%';
  @override
  void onInit() {
    super.onInit();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _generateParticles();
    final imagePath = Get.arguments as String?;
    if (imagePath != null) {
      _loadImageFromPath(imagePath);
    } else {
      errorToast('No image provided');
      Get.back();
    }
  }

  @override
  void onClose() {
    if (particleController.isAnimating) {
      particleController.stop();
    }
    particleController.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.onClose();
  }

  void _generateParticles() {
    final rng = math.Random(42);
    particles = List.generate(
      _maxParticles,
      (_) => Particle(
        rng.nextDouble(),
        rng.nextDouble(),
        rng.nextDouble(),
        rng.nextDouble(),
      ),
    );
  }

  Future<void> _loadImageFromPath(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        originalImage.value = file;
      } else {
        errorToast('Image file not found');
        Get.back();
      }
    } catch (e) {
      errorToast('Failed to load image');
      Get.back();
    }
  }

  void onEffectSelect(String effect) {
    selectedEffect.value = effect;
    if (effect != 'None') {
      hasChanges.value = true;
      if (!isPlaying.value) {
        particleController.repeat();
        isPlaying.value = true;
      }
    }
  }

  void onDensityChange(double value) => density.value = value;
  void onSpeedChange(double value) => speed.value = value;
  void onOpacityChange(double value) => opacity.value = value;
  void togglePlayPause() {
    try {
      if (isPlaying.value) {
        particleController.stop();
      } else {
        particleController.repeat();
      }
      isPlaying.value = !isPlaying.value;
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
    }
  }

  Future<void> onBackTap() async {
    if (hasChanges.value) {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('Do you want to save your changes?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (result == true) {
        await onSaveTap();
      } else if (result == false) {
        Get.back();
      }
    } else {
      Get.back();
    }
  }

  Future<void> onSaveTap() async {
    if (originalImage.value == null) {
      errorToast('No image to save');
      return;
    }
    if (isProcessing.value) return;
    try {
      isProcessing.value = true;
      await Future.delayed(const Duration(milliseconds: 50));
      final context = previewKey.currentContext;
      if (context == null || !context.mounted) {
        errorToast('Failed to capture image');
        return;
      }
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        errorToast('Failed to capture image');
        return;
      }
      final uiImage = await renderObject.toImage(pixelRatio: 1.5);
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      uiImage.dispose();
      if (byteData == null) {
        errorToast('Failed to encode image');
        return;
      }
      final pngBytes = byteData.buffer.asUint8List();
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = filePath.join(
        appDir.path,
        'flo_bloom_effect_$timestamp.png',
      );
      final savedFile = File(savePath);
      await savedFile.writeAsBytes(pngBytes);
      await _saveToDatabase(savedFile);
      successToast('Image saved successfully');
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back(result: savedFile.path);
    } catch (e) {
      debugPrint('Save error: $e');
      errorToast('Failed to save: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _saveToDatabase(File savedFile) async {
    try {
      final bytes = await savedFile.readAsBytes();
      final image = img.decodeImage(bytes);
      final fileSize = await savedFile.length();
      await _db.insertRecord(
        FloBloomRecord(
          filePath: savedFile.path,
          originalPath: originalImage.value!.path,
          createTime: DateTime.now().millisecondsSinceEpoch,
          fileSize: fileSize.toInt(),
          resolution: image != null ? '${image.width}x${image.height}' : '0x0',
          isAnimated: 0,
          effectName: selectedEffect.value != 'None'
              ? selectedEffect.value
              : null,
          hasBeauty: 0,
          hasCrop: 0,
          hasFrame: 0,
          hasWatermark: 0,
        ),
      );
    } catch (e) {
      debugPrint('Failed to save record to database: $e');
    }
  }
}
