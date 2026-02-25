import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/image_processor.dart';
import '../../utils/index.dart';
import '../../db_flo_bloom/data.dart';
import '../../db_flo_bloom/db_flo_bloom_entity.dart';

class FloBloomCropEditorLogic extends GetxController {
  final _db = FloBloomDatabase();
  Rx<File?> originalImage = Rx<File?>(null);
  Rx<File?> currentImage = Rx<File?>(null);
  final imageWidth = 0.obs;
  final imageHeight = 0.obs;
  final imageSizeKB = 0.0.obs;
  final cropBoxLeft = 0.0.obs;
  final cropBoxTop = 0.0.obs;
  final cropBoxWidth = 0.0.obs;
  final cropBoxHeight = 0.0.obs;
  final containerWidth = 0.0.obs;
  final containerHeight = 0.0.obs;
  final imageDisplayLeft = 0.0.obs;
  final imageDisplayTop = 0.0.obs;
  final imageDisplayWidth = 0.0.obs;
  final imageDisplayHeight = 0.0.obs;
  var selectedRatio = 'Original'.obs;
  final isProcessing = false.obs;
  final hasChanges = false.obs;
  late TransformationController transformationController;
  @override
  void onInit() {
    super.onInit();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    transformationController = TransformationController();
    final imagePath = Get.arguments as String?;
    if (imagePath != null) {
      _loadImageFromPath(imagePath);
    }
  }

  Future<void> _loadImageFromPath(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await _loadImage(file);
      } else {
        errorToast('Image file not found');
        Get.back();
      }
    } catch (e) {
      errorToast('Failed to load image');
      Get.back();
    }
  }

  Future<void> _loadImage(File file) async {
    try {
      originalImage.value = file;
      currentImage.value = file;
      final info = await ImageProcessor.getImageInfo(file);
      if (info != null) {
        imageWidth.value = info['width'];
        imageHeight.value = info['height'];
        imageSizeKB.value = info['sizeKB'];
      }
      hasChanges.value = false;
      successToast('Image loaded successfully');
    } catch (e) {
      errorToast('Failed to load image: $e');
    }
  }

  void updateContainerSize(double width, double height) {
    if (containerWidth.value != width || containerHeight.value != height) {
      containerWidth.value = width;
      containerHeight.value = height;
    }
  }

  void updateImageDisplayRect(Rect displayRect) {
    imageDisplayLeft.value = displayRect.left;
    imageDisplayTop.value = displayRect.top;
    imageDisplayWidth.value = displayRect.width;
    imageDisplayHeight.value = displayRect.height;
    if (cropBoxWidth.value == 0 && imageDisplayWidth.value > 0) {
      _initializeCropBox();
    }
  }

  void _initializeCropBox() {
    if (containerWidth.value == 0 || containerHeight.value == 0) return;
    _updateCropBoxForRatio();
    cropBoxLeft.value = (containerWidth.value - cropBoxWidth.value) / 2;
    cropBoxTop.value = (containerHeight.value - cropBoxHeight.value) / 2;
    _constrainCropBoxToBounds();
  }

  void _updateCropBoxForRatio() {
    double aspectRatio = 1.0;
    if (selectedRatio.value == 'Original') {
      if (imageWidth.value > 0 && imageHeight.value > 0) {
        aspectRatio = imageWidth.value / imageHeight.value;
      }
    } else {
      final parts = selectedRatio.value.split(':');
      if (parts.length == 2) {
        final w = double.tryParse(parts[0]) ?? 1.0;
        final h = double.tryParse(parts[1]) ?? 1.0;
        aspectRatio = w / h;
      }
    }
    final maxWidth = containerWidth.value * 0.85;
    final maxHeight = containerHeight.value * 0.7;
    if (aspectRatio >= 1) {
      cropBoxWidth.value = maxWidth;
      cropBoxHeight.value = cropBoxWidth.value / aspectRatio;
      if (cropBoxHeight.value > maxHeight) {
        cropBoxHeight.value = maxHeight;
        cropBoxWidth.value = cropBoxHeight.value * aspectRatio;
      }
    } else {
      cropBoxHeight.value = maxHeight;
      cropBoxWidth.value = cropBoxHeight.value * aspectRatio;
      if (cropBoxWidth.value > maxWidth) {
        cropBoxWidth.value = maxWidth;
        cropBoxHeight.value = cropBoxWidth.value / aspectRatio;
      }
    }
  }

  void onRatioSelect(String ratio) {
    selectedRatio.value = ratio;
    _updateCropBoxForRatio();
    cropBoxLeft.value = (containerWidth.value - cropBoxWidth.value) / 2;
    cropBoxTop.value = (containerHeight.value - cropBoxHeight.value) / 2;
    _constrainCropBoxToBounds();
  }

  Offset? _lastFocalPoint;
  void onCropBoxScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
  }

  void onCropBoxScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 1) {
      if (_lastFocalPoint != null) {
        final delta = details.focalPoint - _lastFocalPoint!;
        cropBoxLeft.value += delta.dx;
        cropBoxTop.value += delta.dy;
        _constrainCropBoxToBounds();
      }
      _lastFocalPoint = details.focalPoint;
    }
  }

  Offset? _resizeStartPoint;
  double? _resizeStartWidth;
  double? _resizeStartHeight;
  double? _resizeStartLeft;
  double? _resizeStartTop;
  double? _currentAspectRatio;
  void onCornerResizeStart(Offset globalPosition, String corner) {
    _resizeStartPoint = globalPosition;
    _resizeStartWidth = cropBoxWidth.value;
    _resizeStartHeight = cropBoxHeight.value;
    _resizeStartLeft = cropBoxLeft.value;
    _resizeStartTop = cropBoxTop.value;
    if (cropBoxHeight.value > 0) {
      _currentAspectRatio = cropBoxWidth.value / cropBoxHeight.value;
    }
  }

  void onCornerResizeUpdate(Offset globalPosition, String corner) {
    if (_resizeStartPoint == null ||
        _resizeStartWidth == null ||
        _resizeStartHeight == null ||
        _resizeStartLeft == null ||
        _resizeStartTop == null ||
        _currentAspectRatio == null) {
      return;
    }
    final delta = globalPosition - _resizeStartPoint!;
    const minSize = 50.0;
    double newWidth = _resizeStartWidth!;
    double newHeight = _resizeStartHeight!;
    double newLeft = _resizeStartLeft!;
    double newTop = _resizeStartTop!;
    switch (corner) {
      case 'topLeft':
        final avgDelta = -(delta.dx + delta.dy) / 2;
        newWidth = (_resizeStartWidth! + avgDelta).clamp(
          minSize,
          double.infinity,
        );
        newHeight = newWidth / _currentAspectRatio!;
        newLeft = _resizeStartLeft! + (_resizeStartWidth! - newWidth);
        newTop = _resizeStartTop! + (_resizeStartHeight! - newHeight);
        break;
      case 'topRight':
        final avgDelta = (delta.dx - delta.dy) / 2;
        newWidth = (_resizeStartWidth! + avgDelta).clamp(
          minSize,
          double.infinity,
        );
        newHeight = newWidth / _currentAspectRatio!;
        newTop = _resizeStartTop! + (_resizeStartHeight! - newHeight);
        break;
      case 'bottomLeft':
        final avgDelta = (-delta.dx + delta.dy) / 2;
        newWidth = (_resizeStartWidth! + avgDelta).clamp(
          minSize,
          double.infinity,
        );
        newHeight = newWidth / _currentAspectRatio!;
        newLeft = _resizeStartLeft! + (_resizeStartWidth! - newWidth);
        break;
      case 'bottomRight':
        final avgDelta = (delta.dx + delta.dy) / 2;
        newWidth = (_resizeStartWidth! + avgDelta).clamp(
          minSize,
          double.infinity,
        );
        newHeight = newWidth / _currentAspectRatio!;
        break;
    }
    final maxWidth = imageDisplayWidth.value;
    final maxHeight = imageDisplayHeight.value;
    if (newWidth > maxWidth) {
      newWidth = maxWidth;
      newHeight = newWidth / _currentAspectRatio!;
    }
    if (newHeight > maxHeight) {
      newHeight = maxHeight;
      newWidth = newHeight * _currentAspectRatio!;
    }
    cropBoxWidth.value = newWidth;
    cropBoxHeight.value = newHeight;
    cropBoxLeft.value = newLeft;
    cropBoxTop.value = newTop;
    _constrainCropBoxToBounds();
  }

  void onCornerResizeEnd() {
    _resizeStartPoint = null;
    _resizeStartWidth = null;
    _resizeStartHeight = null;
    _resizeStartLeft = null;
    _resizeStartTop = null;
  }

  void _constrainCropBoxToBounds() {
    if (containerWidth.value == 0 || containerHeight.value == 0) return;
    final minLeft = imageDisplayLeft.value;
    final minTop = imageDisplayTop.value;
    final maxLeft =
        imageDisplayLeft.value + imageDisplayWidth.value - cropBoxWidth.value;
    final maxTop =
        imageDisplayTop.value + imageDisplayHeight.value - cropBoxHeight.value;
    cropBoxLeft.value = cropBoxLeft.value.clamp(minLeft, maxLeft);
    cropBoxTop.value = cropBoxTop.value.clamp(minTop, maxTop);
  }

  Rect convertScreenToImageCoordinates() {
    final matrix = transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();
    final translation = matrix.getTranslation();
    print('=== Crop Conversion Debug ===');
    print('Scale: $scale, Translation: ${translation.x}, ${translation.y}');
    print(
      'Image display: L=${imageDisplayLeft.value}, T=${imageDisplayTop.value}, W=${imageDisplayWidth.value}, H=${imageDisplayHeight.value}',
    );
    print(
      'Crop box: L=${cropBoxLeft.value}, T=${cropBoxTop.value}, W=${cropBoxWidth.value}, H=${cropBoxHeight.value}',
    );
    print('Image original: W=${imageWidth.value}, H=${imageHeight.value}');
    final cropBoxInOriginalCoords = Rect.fromLTWH(
      (cropBoxLeft.value - translation.x) / scale,
      (cropBoxTop.value - translation.y) / scale,
      cropBoxWidth.value / scale,
      cropBoxHeight.value / scale,
    );
    print(
      'Crop box in original coords: ${cropBoxInOriginalCoords.left}, ${cropBoxInOriginalCoords.top}, ${cropBoxInOriginalCoords.width}, ${cropBoxInOriginalCoords.height}',
    );
    final relativeLeft = cropBoxInOriginalCoords.left - imageDisplayLeft.value;
    final relativeTop = cropBoxInOriginalCoords.top - imageDisplayTop.value;
    print('Relative to image: L=$relativeLeft, T=$relativeTop');
    final scaleX = imageWidth.value / imageDisplayWidth.value;
    final scaleY = imageHeight.value / imageDisplayHeight.value;
    final pixelX = (relativeLeft * scaleX).clamp(
      0.0,
      imageWidth.value.toDouble(),
    );
    final pixelY = (relativeTop * scaleY).clamp(
      0.0,
      imageHeight.value.toDouble(),
    );
    final pixelWidth = (cropBoxInOriginalCoords.width * scaleX).clamp(
      1.0,
      imageWidth.value.toDouble() - pixelX,
    );
    final pixelHeight = (cropBoxInOriginalCoords.height * scaleY).clamp(
      1.0,
      imageHeight.value.toDouble() - pixelY,
    );
    print('Final pixels: X=$pixelX, Y=$pixelY, W=$pixelWidth, H=$pixelHeight');
    print('=============================');
    return Rect.fromLTWH(pixelX, pixelY, pixelWidth, pixelHeight);
  }

  void onBackTap() {
    if (hasChanges.value) {
      Get.dialog(
        AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'Do you want to save your changes before leaving?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                onSaveTap();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } else {
      Get.back();
    }
  }

  Future<void> onSaveTap() async {
    if (currentImage.value == null || originalImage.value == null) {
      errorToast('No image to save');
      return;
    }
    try {
      isProcessing.value = true;
      final cropRect = convertScreenToImageCoordinates();
      final x = cropRect.left.round();
      final y = cropRect.top.round();
      final width = cropRect.width.round();
      final height = cropRect.height.round();
      if (width < 10 || height < 10) {
        errorToast('Crop area is too small');
        isProcessing.value = false;
        return;
      }
      final croppedFile = await ImageProcessor.cropImage(
        imageFile: currentImage.value!,
        x: x,
        y: y,
        width: width,
        height: height,
        quality: 90,
      );
      if (croppedFile == null) {
        errorToast('Failed to crop image');
        isProcessing.value = false;
        return;
      }
      final croppedInfo = await ImageProcessor.getImageInfo(croppedFile);
      if (croppedInfo == null) {
        errorToast('Failed to get image info');
        isProcessing.value = false;
        return;
      }
      final savedFile = await ImageProcessor.saveImage(
        imageFile: croppedFile,
        width: croppedInfo['width'],
        height: croppedInfo['height'],
        extension: 'jpg',
      );
      if (savedFile != null) {
        await _saveToDatabase(
          originalPath: originalImage.value!.path,
          savedPath: savedFile.path,
          fileSize: (croppedInfo['sizeKB'] * 1024).toInt(),
          resolution: '${croppedInfo['width']}x${croppedInfo['height']}',
        );
        successToast('Image saved successfully');
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back(result: savedFile.path);
      } else {
        errorToast('Failed to save image');
      }
    } catch (e) {
      errorToast('Error: $e');
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
        hasBeauty: 0,
        hasCrop: 1,
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
    transformationController.dispose();
    super.onClose();
  }
}
