import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/index.dart';
import '../../db_flo_bloom/data.dart';

class FloBloomSettingsLogic extends GetxController {
  final _db = FloBloomDatabase();
  Future<void> onClearAllDataTap() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your works, cache, and app data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _clearAllData();
        successToast('All data cleared successfully');
      } catch (e) {
        errorToast('Failed to clear data: $e');
      }
    }
  }

  Future<void> _clearAllData() async {
    try {
      final records = await _db.getAllRecords();
      for (final record in records) {
        try {
          final file = File(record.filePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Failed to delete file ${record.filePath}: $e');
        }
      }
      await _db.deleteAllRecords();
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        final List<FileSystemEntity> entities = tempDir.listSync();
        for (final entity in entities) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e) {
            print('Failed to delete ${entity.path}: $e');
          }
        }
      }
      final cacheDir = await getApplicationCacheDirectory();
      if (await cacheDir.exists()) {
        final List<FileSystemEntity> entities = cacheDir.listSync();
        for (final entity in entities) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e) {
            print('Failed to delete ${entity.path}: $e');
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
