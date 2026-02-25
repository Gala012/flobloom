import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../utils/image_processor.dart';
import '../../utils/index.dart';
import '../../db_flo_bloom/data.dart';
import '../../db_flo_bloom/db_flo_bloom_entity.dart';
class _BeautyParams {
  final String imagePath;
  final String outputPath;
  final double smoothSkin;
  final double brighten;
  _BeautyParams({
    required this.imagePath,
    required this.outputPath,
    required this.smoothSkin,
    required this.brighten,
  });
}
Future<bool> _applyBeautyInIsolate(_BeautyParams params) async {
  try {
    final bytes = await File(params.imagePath).readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) return false;
    if (params.smoothSkin > 0) {
      final t2 = (params.smoothSkin / 100) * (params.smoothSkin / 100);
      final radius = (t2 * 2).round().clamp(1, 2);
      image = img.gaussianBlur(image, radius: radius);
      final brightness = 1.0 + t2 * 0.06;
      final contrast = 1.0 - t2 * 0.04;
      image = img.adjustColor(image, brightness: brightness, contrast: contrast);
    }
    if (params.brighten > 0) {
      final t2 = (params.brighten / 100) * (params.brighten / 100);
      final brightness = 1.0 + t2 * 0.6;
      final saturation = 1.0 - t2 * 0.18;
      image = img.adjustColor(
        image,
        brightness: brightness,
        saturation: saturation,
      );
    }
    final encodedImage = img.encodeJpg(image, quality: 90);
    await File(params.outputPath).writeAsBytes(encodedImage);
    return true;
  } catch (e) {
    print('Beauty isolate error: $e');
    return false;
  }
}
class FloBloomBeautyEditorLogic extends GetxController {
  final _db = FloBloomDatabase();
  Rx<File?> originalImage = Rx<File?>(null);
  var smoothSkin = 65.0.obs;
  var brighten = 45.0.obs;
  final isProcessing = false.obs;
  final hasChanges = false.obs;
  @override
  void onInit() {
    super.onInit();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    final imagePath = Get.arguments as String?;
    if (imagePath != null) {
      _loadImageFromPath(imagePath);
    } else {
      errorToast('No image provided');
      Get.back();
    }
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
  void onSmoothSkinChange(double value) {
    smoothSkin.value = value;
    hasChanges.value = true;
  }
  void onBrightenChange(double value) {
    brighten.value = value;
    hasChanges.value = true;
  }
  Future<void> onBackTap() async {
    if (hasChanges.value) {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'Do you want to save your changes before leaving?',
          ),
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
    try {
      isProcessing.value = true;
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempPath = '${tempDir.path}/beauty_save_$timestamp.jpg';
      final params = _BeautyParams(
        imagePath: originalImage.value!.path,
        outputPath: tempPath,
        smoothSkin: smoothSkin.value,
        brighten: brighten.value,
      );
      final success = await compute(_applyBeautyInIsolate, params);
      if (!success) {
        errorToast('Failed to apply beauty effect');
        return;
      }
      final tempFile = File(tempPath);
      final imageInfo = await ImageProcessor.getImageInfo(tempFile);
      if (imageInfo == null) {
        errorToast('Failed to get image info');
        return;
      }
      final savedFile = await ImageProcessor.saveImage(
        imageFile: tempFile,
        width: imageInfo['width'],
        height: imageInfo['height'],
        extension: 'jpg',
      );
      tempFile.delete().catchError((_) => tempFile);
      if (savedFile != null) {
        await _saveToDatabase(
          originalPath: originalImage.value!.path,
          savedPath: savedFile.path,
          fileSize: (imageInfo['sizeKB'] * 1024).toInt(),
          resolution: '${imageInfo['width']}x${imageInfo['height']}',
        );
        successToast('Image saved successfully');
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back(result: savedFile.path);
      } else {
        errorToast('Failed to save image');
      }
    } catch (e) {
      errorToast('Error saving image: $e');
    } finally {
      isProcessing.value = false;
    }
  }
  Future<void> _saveToDatabase({
    required String originalPath,
    required String savedPath,
    required int fileSize,
    required String resolution,
  }) async {
    try {
      final record = FloBloomRecord(
        filePath: savedPath,
        originalPath: originalPath,
        createTime: DateTime.now().millisecondsSinceEpoch,
        fileSize: fileSize,
        resolution: resolution,
        isAnimated: 0,
        hasBeauty: 1,
        hasCrop: 0,
        hasFrame: 0,
        hasWatermark: 0,
      );
      await _db.insertRecord(record);
    } catch (e) {
      print('Failed to save record to database: $e');
    }
  }
  @override
  void onClose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.onClose();
  }
}
