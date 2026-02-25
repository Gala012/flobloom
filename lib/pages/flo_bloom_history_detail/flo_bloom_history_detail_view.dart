import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'flo_bloom_history_detail_logic.dart';

class FloBloomHistoryDetailView extends GetView<FloBloomHistoryDetailLogic> {
  const FloBloomHistoryDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (controller.record.value == null) {
          return const Center(
            child: Text(
              'Record not found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(child: _buildImageDisplay()),
              _buildDetailsAndActions(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: controller.onBackTap,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_left, color: Colors.white, size: 24.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay() {
    final record = controller.record.value;
    if (record == null) return const SizedBox();
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          constraints: BoxConstraints(maxHeight: 500.h),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.w)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.w),
            child: Image.file(File(record.filePath), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsAndActions() {
    final record = controller.record.value;
    if (record == null) return const SizedBox();
    final effectTags = controller.getEffectTags();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0), Colors.black, Colors.black],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (effectTags.isNotEmpty)
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: effectTags
                  .map((tag) => _buildTag(tag['icon'], tag['label']))
                  .toList(),
            ),
          if (effectTags.isNotEmpty) SizedBox(height: 24.h),
          _buildMetadataRow(
            Icons.access_time,
            controller.formatDateTime(record.createTime),
          ),
          SizedBox(height: 8.h),
          _buildMetadataRow(Icons.image, record.resolution),
          SizedBox(height: 8.h),
          _buildMetadataRow(
            Icons.insert_drive_file,
            controller.formatFileSize(record.fileSize),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: controller.onSaveTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      gradient: FloBloomColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download, size: 18.w, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: controller.onShareTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share, size: 18.w, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: controller.onDeleteTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, size: 18.w, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: FloBloomColors.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.w, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: Colors.white.withOpacity(0.8)),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
