import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as filePath;
import 'package:path_provider/path_provider.dart';
import '../../config/frame_config.dart';
import '../../db_flo_bloom/data.dart';
import '../../db_flo_bloom/db_flo_bloom_entity.dart';
import '../../utils/image_processor.dart';
import '../../utils/index.dart';

class FloBloomFrameEditorLogic extends GetxController {
  final _db = FloBloomDatabase();
  Rx<File?> originalImage = Rx<File?>(null);
  var selectedFrame = ''.obs;
  var selectedCategory = 'simple'.obs;
  final isProcessing = false.obs;
  final hasChanges = false.obs;
  List<String> get currentCategoryFrames =>
      FrameConfigs.getFramesByCategory(selectedCategory.value);
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

  void onCategorySelect(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    if (selectedFrame.value.isNotEmpty) {
      final config = FrameConfigs.getFrame(selectedFrame.value);
      if (config?.category != category) {
        selectedFrame.value = '';
        hasChanges.value = false;
      }
    }
  }

  void onFrameSelect(String frameName) {
    selectedFrame.value = frameName;
    hasChanges.value = frameName.isNotEmpty;
  }

  Future<void> onBackTap() async {
    if (hasChanges.value) {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. Do you want to save before leaving?',
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
      File? savedFile;
      if (selectedFrame.value.isEmpty) {
        final imageInfo = await ImageProcessor.getImageInfo(
          originalImage.value!,
        );
        if (imageInfo == null) {
          errorToast('Failed to read image info');
          return;
        }
        savedFile = await ImageProcessor.saveImage(
          imageFile: originalImage.value!,
          width: imageInfo['width'],
          height: imageInfo['height'],
          extension: 'jpg',
        );
      } else {
        savedFile = await _compositeImageWithFrame();
      }
      if (savedFile != null) {
        await _saveToDatabase(savedFile);
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

  Future<File?> _compositeImageWithFrame() async {
    try {
      final frameConfig = FrameConfigs.getFrame(selectedFrame.value);
      if (frameConfig == null) {
        errorToast('Frame config not found');
        return null;
      }
      final originalBytes = await originalImage.value!.readAsBytes();
      final originalImg = img.decodeImage(originalBytes);
      if (originalImg == null) {
        errorToast('Failed to decode original image');
        return null;
      }
      final frameAssetData = await rootBundle.load(frameConfig.path);
      final frameBytes = frameAssetData.buffer.asUint8List();
      final frameImg = img.decodeImage(frameBytes);
      if (frameImg == null) {
        errorToast('Failed to decode frame image');
        return null;
      }
      final outWidth = frameImg.width;
      final outHeight = frameImg.height;
      final contentX = (outWidth * frameConfig.inset.left).round();
      final contentY = (outHeight * frameConfig.inset.top).round();
      final contentW = (outWidth * frameConfig.contentArea.widthRatio).round();
      final contentH = (outHeight * frameConfig.contentArea.heightRatio)
          .round();
      final scaleX = contentW / originalImg.width;
      final scaleY = contentH / originalImg.height;
      final scale = scaleX < scaleY ? scaleX : scaleY;
      final scaledW = (originalImg.width * scale).round();
      final scaledH = (originalImg.height * scale).round();
      final scaledOriginal = img.copyResize(
        originalImg,
        width: scaledW,
        height: scaledH,
      );
      final offsetX = contentX + ((contentW - scaledW) / 2).round();
      final offsetY = contentY + ((contentH - scaledH) / 2).round();
      final output = img.Image(width: outWidth, height: outHeight);
      img.fill(output, color: img.ColorRgb8(255, 255, 255));
      img.compositeImage(output, scaledOriginal, dstX: offsetX, dstY: offsetY);
      img.compositeImage(output, frameImg, blend: img.BlendMode.alpha);
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = filePath.join(
        appDir.path,
        'flo_bloom_frame_$timestamp.jpg',
      );
      final encodedImage = img.encodeJpg(output, quality: 90);
      final savedFile = File(savePath);
      await savedFile.writeAsBytes(encodedImage);
      return savedFile;
    } catch (e) {
      print('Error compositing image with frame: $e');
      return null;
    }
  }

  Future<void> _saveToDatabase(File savedFile) async {
    try {
      final imageInfo = await ImageProcessor.getImageInfo(savedFile);
      final record = FloBloomRecord(
        filePath: savedFile.path,
        originalPath: originalImage.value!.path,
        createTime: DateTime.now().millisecondsSinceEpoch,
        fileSize: ((imageInfo?['sizeKB'] ?? 0) * 1024).toInt(),
        resolution: '${imageInfo?['width'] ?? 0}x${imageInfo?['height'] ?? 0}',
        isAnimated: 0,
        filterName: selectedFrame.value.isNotEmpty ? selectedFrame.value : null,
        hasBeauty: 0,
        hasCrop: 0,
        hasFrame: selectedFrame.value.isNotEmpty ? 1 : 0,
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
