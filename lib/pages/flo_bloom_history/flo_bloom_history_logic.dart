import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../db_flo_bloom/data.dart';
import '../../db_flo_bloom/db_flo_bloom_entity.dart';
import '../../utils/index.dart';

class FloBloomHistoryLogic extends GetxController {
  final _db = FloBloomDatabase();
  var selectedTab = 'All'.obs;
  var records = <FloBloomRecord>[].obs;
  var isLoading = false.obs;
  var isBatchMode = false.obs;
  var selectedRecords = <int>[].obs;
  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  Future<void> loadRecords() async {
    try {
      isLoading.value = true;
      List<FloBloomRecord> allRecords;
      if (selectedTab.value == 'All') {
        allRecords = await _db.getAllRecords();
      } else if (selectedTab.value == 'Static') {
        allRecords = await _db.getRecordsByType(false);
      } else {
        allRecords = await _db.getRecordsByType(true);
      }
      records.value = allRecords;
    } catch (e) {
      errorToast('Failed to load records: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onTabChange(String tab) {
    selectedTab.value = tab;
    loadRecords();
  }

  void onWorkTap(int index) {
    if (isBatchMode.value) {
      toggleRecordSelection(records[index].id!);
    } else {
      Get.toNamed(
        '/flo_bloom_history_detail',
        arguments: records[index].id,
      )?.then((_) => loadRecords());
    }
  }

  void onWorkLongPress(int index) {
    if (!isBatchMode.value) {
      showQuickMenu(index);
    }
  }

  void showQuickMenu(int index) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Get.back();
                deleteRecord(records[index].id!);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Get.back();
                shareRecord(records[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteRecord(int id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final record = await _db.getRecordById(id);
        if (record != null) {
          await _db.deleteRecord(id);
          final file = File(record.filePath);
          if (await file.exists()) {
            await file.delete();
          }
          successToast('Record deleted successfully');
          loadRecords();
        }
      } catch (e) {
        errorToast('Failed to delete record: $e');
      }
    }
  }

  Future<void> shareRecord(FloBloomRecord record) async {
    try {
      final file = File(record.filePath);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(record.filePath)]);
      } else {
        errorToast('File not found');
      }
    } catch (e) {
      errorToast('Failed to share: $e');
    }
  }

  void toggleRecordSelection(int id) {
    if (selectedRecords.contains(id)) {
      selectedRecords.remove(id);
    } else {
      selectedRecords.add(id);
    }
  }

  Future<void> batchDelete() async {
    if (selectedRecords.isEmpty) {
      errorToast('No records selected');
      return;
    }
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Records'),
        content: Text(
          'Are you sure you want to delete ${selectedRecords.length} record(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        for (final id in selectedRecords) {
          final record = await _db.getRecordById(id);
          if (record != null) {
            await _db.deleteRecord(id);
            final file = File(record.filePath);
            if (await file.exists()) {
              await file.delete();
            }
          }
        }
        successToast('${selectedRecords.length} record(s) deleted');
        selectedRecords.clear();
        isBatchMode.value = false;
        loadRecords();
      } catch (e) {
        errorToast('Failed to delete records: $e');
      }
    }
  }

  Future<void> refresh() async {
    await loadRecords();
  }
}
