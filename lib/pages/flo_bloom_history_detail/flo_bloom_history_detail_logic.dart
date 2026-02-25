import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../db_flo_bloom/data.dart';
import '../../db_flo_bloom/db_flo_bloom_entity.dart';
import '../../utils/index.dart';

class FloBloomHistoryDetailLogic extends GetxController {
  final _db = FloBloomDatabase();
  Rx<FloBloomRecord?> record = Rx<FloBloomRecord?>(null);
  var isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    loadRecord();
  }

  Future<void> loadRecord() async {
    try {
      isLoading.value = true;
      final recordId = Get.arguments as int?;
      if (recordId == null) {
        errorToast('Invalid record ID');
        Get.back();
        return;
      }
      final loadedRecord = await _db.getRecordById(recordId);
      if (loadedRecord == null) {
        errorToast('Record not found');
        Get.back();
        return;
      }
      final file = File(loadedRecord.filePath);
      if (!await file.exists()) {
        errorToast('File not found');
        await _db.deleteRecord(recordId);
        Get.back();
        return;
      }
      record.value = loadedRecord;
    } catch (e) {
      errorToast('Failed to load record: $e');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  void onBackTap() {
    Get.back();
  }

  Future<void> onSaveTap() async {
    final rec = record.value;
    if (rec == null) return;
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        errorToast('Storage permission denied');
        return;
      }
      final file = File(rec.filePath);
      final bytes = await file.readAsBytes();
      final result = await ImageGallerySaver.saveImage(bytes);
      if (result != null && result['isSuccess'] == true) {
        successToast('Saved to gallery successfully');
      } else {
        errorToast('Failed to save to gallery');
      }
    } catch (e) {
      errorToast('Failed to save: $e');
    }
  }

  Future<void> onShareTap() async {
    final rec = record.value;
    if (rec == null) return;
    try {
      final file = File(rec.filePath);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(rec.filePath)]);
      } else {
        errorToast('File not found');
      }
    } catch (e) {
      errorToast('Failed to share: $e');
    }
  }

  Future<void> onDeleteTap() async {
    final rec = record.value;
    if (rec == null) return;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
          'Are you sure you want to delete this record? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _db.deleteRecord(rec.id!);
        final file = File(rec.filePath);
        if (await file.exists()) {
          await file.delete();
        }
        successToast('Record deleted successfully');
        Get.back(result: true);
      } catch (e) {
        errorToast('Failed to delete: $e');
      }
    }
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String formatDateTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${_getMonthName(date.month)} ${date.day}, ${date.year} ${_formatTime(date)}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<Map<String, dynamic>> getEffectTags() {
    final rec = record.value;
    if (rec == null) return [];
    final tags = <Map<String, dynamic>>[];
    if (rec.filterName != null) {
      tags.add({'icon': Icons.palette, 'label': rec.filterName!});
    }
    if (rec.hasBeauty == 1) {
      tags.add({'icon': Icons.auto_fix_high, 'label': 'Beauty'});
    }
    if (rec.hasCrop == 1) {
      tags.add({'icon': Icons.crop, 'label': 'Crop'});
    }
    if (rec.hasFrame == 1) {
      tags.add({'icon': Icons.border_all, 'label': 'Frame'});
    }
    if (rec.stickers != null && rec.stickers!.isNotEmpty) {
      tags.add({'icon': Icons.mood, 'label': 'Stickers'});
    }
    if (rec.effectName != null) {
      tags.add({'icon': Icons.auto_awesome, 'label': rec.effectName!});
    }
    if (rec.hasWatermark == 1) {
      tags.add({'icon': Icons.text_fields, 'label': 'Watermark'});
    }
    return tags;
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
