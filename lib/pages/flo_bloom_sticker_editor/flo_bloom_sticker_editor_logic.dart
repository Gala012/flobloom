import 'dart:io';
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

class StickerItem {
  final String id;
  final String emoji;
  final bool isAnimated;
  double x;
  double y;
  double scale;
  double rotation;
  StickerItem({
    required this.id,
    required this.emoji,
    required this.isAnimated,
    this.x = 0.5,
    this.y = 0.5,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

class FloBloomStickerEditorLogic extends GetxController
    with GetTickerProviderStateMixin {
  final _db = FloBloomDatabase();
  final previewKey = GlobalKey();
  Rx<File?> originalImage = Rx<File?>(null);
  final stickers = <StickerItem>[].obs;
  final selectedStickerId = ''.obs;
  var selectedTab = 'Static'.obs;
  final isProcessing = false.obs;
  final hasChanges = false.obs;
  late AnimationController animationController;
  double containerWidth = 0;
  double containerHeight = 0;
  static const staticStickers = [
    '❤️',
    '⭐',
    '🌸',
    '🎀',
    '💝',
    '🌹',
    '🪷',
    '🌺',
    '🍀',
    '🌈',
    '🎈',
    '🎊',
    '✨',
    '💫',
    '🔮',
    '🦄',
    '🌙',
    '☀️',
    '🎵',
    '💎',
    '🍓',
    '🍒',
    '🌻',
    '🎭',
  ];
  static const animatedStickers = [
    {'emoji': '🦋', 'name': 'Butterfly'},
    {'emoji': '🌟', 'name': 'Firefly'},
    {'emoji': '🌸', 'name': 'Petal'},
    {'emoji': '💫', 'name': 'Stars'},
    {'emoji': '❤️', 'name': 'Heart'},
    {'emoji': '✨', 'name': 'Sparkle'},
    {'emoji': '🍃', 'name': 'Leaf'},
    {'emoji': '🫧', 'name': 'Bubble'},
    {'emoji': '🌺', 'name': 'Bloom'},
    {'emoji': '🌙', 'name': 'Moon'},
    {'emoji': '🎶', 'name': 'Music'},
    {'emoji': '🌈', 'name': 'Rainbow'},
  ];
  @override
  void onInit() {
    super.onInit();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
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
    animationController.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.onClose();
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

  void onTabChange(String tab) => selectedTab.value = tab;
  void addSticker(String emoji, {bool isAnimated = false}) {
    final sticker = StickerItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      emoji: emoji,
      isAnimated: isAnimated,
    );
    stickers.add(sticker);
    selectedStickerId.value = sticker.id;
    hasChanges.value = true;
  }

  void onStickerTap(String id) {
    selectedStickerId.value = selectedStickerId.value == id ? '' : id;
  }

  void onStickerDrag(String id, double dx, double dy) {
    if (containerWidth == 0 || containerHeight == 0) return;
    final index = stickers.indexWhere((s) => s.id == id);
    if (index == -1) return;
    stickers[index].x = (stickers[index].x + dx / containerWidth).clamp(
      0.05,
      0.95,
    );
    stickers[index].y = (stickers[index].y + dy / containerHeight).clamp(
      0.05,
      0.95,
    );
    stickers.refresh();
    hasChanges.value = true;
  }

  void onStickerScale(String id, double dx, double dy) {
    final index = stickers.indexWhere((s) => s.id == id);
    if (index == -1) return;
    final delta = (dx - dy) / 80;
    stickers[index].scale = (stickers[index].scale + delta).clamp(0.3, 4.0);
    stickers.refresh();
    hasChanges.value = true;
  }

  void onStickerRotate(String id, double dx) {
    final index = stickers.indexWhere((s) => s.id == id);
    if (index == -1) return;
    stickers[index].rotation += dx / 60;
    stickers.refresh();
    hasChanges.value = true;
  }

  void onStickerDelete(String id) {
    stickers.removeWhere((s) => s.id == id);
    selectedStickerId.value = '';
    if (stickers.isEmpty) hasChanges.value = false;
  }

  void deselectAll() => selectedStickerId.value = '';
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
    try {
      isProcessing.value = true;
      selectedStickerId.value = '';
      await Future.delayed(const Duration(milliseconds: 150));
      final boundary =
          previewKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        errorToast('Failed to capture image');
        return;
      }
      final uiImage = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        errorToast('Failed to encode image');
        return;
      }
      final pngBytes = byteData.buffer.asUint8List();
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = filePath.join(
        appDir.path,
        'flo_bloom_sticker_$timestamp.png',
      );
      final savedFile = File(savePath);
      await savedFile.writeAsBytes(pngBytes);
      await _saveToDatabase(savedFile);
      successToast('Image saved successfully');
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back(result: savedFile.path);
    } catch (e) {
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
      final stickerNames = stickers.map((s) => s.emoji).join(',');
      await _db.insertRecord(
        FloBloomRecord(
          filePath: savedFile.path,
          originalPath: originalImage.value!.path,
          createTime: DateTime.now().millisecondsSinceEpoch,
          fileSize: fileSize.toInt(),
          resolution: image != null ? '${image.width}x${image.height}' : '0x0',
          isAnimated: stickers.any((s) => s.isAnimated) ? 1 : 0,
          stickers: stickerNames.isNotEmpty ? stickerNames : null,
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
