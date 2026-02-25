import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'flo_bloom_history_logic.dart';

class FloBloomHistoryView extends GetView<FloBloomHistoryLogic> {
  const FloBloomHistoryView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FloBloomColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterTabs(),
            Expanded(child: _buildHistoryGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My History',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: FloBloomColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Obx(
        () => Row(
          children: [
            _buildTabButton('All'),
            SizedBox(width: 12.w),
            _buildTabButton('Static'),
            SizedBox(width: 12.w),
            _buildTabButton('Animated'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final isSelected = controller.selectedTab.value == label;
    return GestureDetector(
      onTap: () => controller.onTabChange(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: isSelected ? FloBloomColors.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20.h),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : FloBloomColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.records.isEmpty) {
        return _buildEmptyState();
      }
      return Padding(
        padding: EdgeInsets.all(24.w),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.75,
          ),
          itemCount: controller.records.length,
          itemBuilder: (context, index) {
            final record = controller.records[index];
            final isSelected = controller.selectedRecords.contains(record.id);
            return GestureDetector(
              onTap: () => controller.onWorkTap(index),
              onLongPress: () => controller.onWorkLongPress(index),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.w),
                  border: controller.isBatchMode.value && isSelected
                      ? Border.all(color: FloBloomColors.primaryDeep, width: 3)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: FloBloomColors.primaryDeep.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.w),
                              ),
                              image: DecorationImage(
                                image: FileImage(File(record.filePath)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (record.isAnimated == 1)
                            Positioned(
                              top: 8.h,
                              right: 8.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12.w),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.play_arrow,
                                      size: 12.w,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'GIF',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (controller.isBatchMode.value)
                            Positioned(
                              top: 8.h,
                              left: 8.w,
                              child: Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? FloBloomColors.primaryDeep
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: FloBloomColors.primaryDeep,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: 16.w,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12.w,
                            color: FloBloomColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _formatDate(record.createTime),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: FloBloomColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80.w,
            color: FloBloomColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No records yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: FloBloomColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start creating now',
            style: TextStyle(
              fontSize: 14.sp,
              color: FloBloomColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
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
}
