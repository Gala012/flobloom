import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/image_processor.dart';
import '../../utils/image_filter_helper.dart';
import '../../utils/index.dart';
import '../../db_flo_bloom/data.dart';
import '../../db_flo_bloom/db_flo_bloom_entity.dart';

class FloBloomFilterEditorLogic extends GetxController {
  final _db = FloBloomDatabase();
  Rx<File?> originalImage = Rx<File?>(null);
  Rx<File?> currentImage = Rx<File?>(null);
  Rx<File?> filteredImage = Rx<File?>(null);
  var selectedFilter = 'None'.obs;
  final filterList = <Map<String, dynamic>>[].obs;
  final filterThumbnails = <String, File>{}.obs;
  final isProcessing = false.obs;
  final isLoadingFilter = false.obs;
  final hasChanges = false.obs;
  String? _pendingFilter;
  @override
  void onInit() {
    super.onInit();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    filterList.value = ImageFilterHelper.getFilterList();
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
        currentImage.value = file;
        filteredImage.value = file;
        _generateFilterThumbnails(file);
      } else {
        errorToast('Image file not found');
        Get.back();
      }
    } catch (e) {
      errorToast('Failed to load image: $e');
      Get.back();
    }
  }

  Future<void> _generateFilterThumbnails(File imageFile) async {
    await Future.wait(
      filterList.map((filter) async {
        final filterName = filter['name'] as String;
        if (filterName == 'None') {
          filterThumbnails[filterName] = imageFile;
          return;
        }
        final thumb = await ImageFilterHelper.generateThumbnail(
          imageFile: imageFile,
          filterName: filterName,
        );
        if (thumb != null) {
          filterThumbnails[filterName] = thumb;
        }
      }),
    );
  }

  Future<void> onFilterSelect(String filterName) async {
    if (selectedFilter.value == filterName) return;
    if (originalImage.value == null) return;
    if (isLoadingFilter.value) {
      _pendingFilter = filterName;
      return;
    }
    try {
      isLoadingFilter.value = true;
      selectedFilter.value = filterName;
      if (filterName == 'None') {
        if (filteredImage.value != null &&
            filteredImage.value!.path != originalImage.value!.path) {
          try {
            await filteredImage.value!.delete();
          } catch (e) {
            print('Failed to delete previous filtered image: $e');
          }
        }
        filteredImage.value = originalImage.value;
        currentImage.value = originalImage.value;
        hasChanges.value = false;
        isLoadingFilter.value = false;
        _processPendingFilter();
        return;
      }
      final filtered = await ImageFilterHelper.applyFilter(
        imageFile: originalImage.value!,
        filterName: filterName,
      );
      if (filtered != null) {
        if (filteredImage.value != null &&
            filteredImage.value!.path != originalImage.value!.path &&
            filteredImage.value!.path != filtered.path) {
          try {
            await filteredImage.value!.delete();
          } catch (e) {
            print('Failed to delete previous filtered image: $e');
          }
        }
        filteredImage.value = filtered;
        currentImage.value = filtered;
        hasChanges.value = true;
      } else {
        errorToast('Failed to apply filter');
        currentImage.value = filteredImage.value ?? originalImage.value;
      }
    } catch (e) {
      errorToast('Error applying filter: $e');
    } finally {
      isLoadingFilter.value = false;
      _processPendingFilter();
    }
  }

  void _processPendingFilter() {
    if (_pendingFilter != null) {
      final pending = _pendingFilter;
      _pendingFilter = null;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (pending != null) {
          onFilterSelect(pending);
        }
      });
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
        _cleanup();
        Get.back();
      }
    } else {
      _cleanup();
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
      final imageInfo = await ImageProcessor.getImageInfo(currentImage.value!);
      if (imageInfo == null) {
        errorToast('Failed to get image info');
        isProcessing.value = false;
        return;
      }
      final savedFile = await ImageProcessor.saveImage(
        imageFile: currentImage.value!,
        width: imageInfo['width'],
        height: imageInfo['height'],
        extension: 'jpg',
      );
      if (savedFile != null) {
        await _saveToDatabase(
          originalPath: originalImage.value!.path,
          savedPath: savedFile.path,
          fileSize: (imageInfo['sizeKB'] * 1024).toInt(),
          resolution: '${imageInfo['width']}x${imageInfo['height']}',
        );
        successToast('Image saved successfully');
        await Future.delayed(const Duration(milliseconds: 500));
        _cleanup();
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
        filterName: selectedFilter.value != 'None'
            ? selectedFilter.value
            : null,
        hasBeauty: 0,
        hasCrop: 0,
        hasFrame: 0,
        hasWatermark: 0,
      );
      await _db.insertRecord(record);
    } catch (e) {
      print('Failed to save record to database: $e');
    }
  }

  void _cleanup() {
    try {
      if (filteredImage.value != null &&
          filteredImage.value!.path != originalImage.value?.path) {
        filteredImage.value!.delete().catchError((e) {
          print('Failed to delete filtered image: $e');
          return filteredImage.value!;
        });
      }
      for (final entry in filterThumbnails.entries) {
        if (entry.key != 'None' &&
            entry.value.path != originalImage.value?.path) {
          entry.value.delete().catchError((e) {
            print('Failed to delete thumbnail: $e');
            return entry.value;
          });
        }
      }
      filterThumbnails.clear();
    } catch (e) {
      print('Cleanup error: $e');
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
    _cleanup();
    super.onClose();
  }
}
