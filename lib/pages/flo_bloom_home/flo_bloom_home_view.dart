import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'flo_bloom_home_logic.dart';

class FloBloomHomeView extends GetView<FloBloomHomeLogic> {
  const FloBloomHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9E8F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildMainFeatureButton(),
                    SizedBox(height: 24.h),
                    _buildQuickTools(),
                    SizedBox(height: 24.h),
                    _buildInspiration(),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8B7C8), Color(0xFFD89AB5)],
              ),
            ),
            child: Icon(Icons.local_florist, color: Colors.white, size: 20.w),
          ),
          SizedBox(width: 12.w),
          Text(
            'FloBloom',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A2E3A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFeatureButton() {
    return GestureDetector(
      onTap: controller.onPhotoFilterTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 32.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8B7C8), Color(0xFFD89AB5)],
          ),
          borderRadius: BorderRadius.circular(24.w),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD89AB5).withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.add, size: 24.w, color: Colors.white),
            SizedBox(height: 8.h),
            Text(
              'Photo Filter',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK TOOLS',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8C6F7F),
          ),
        ),
        SizedBox(height: 12.h),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 16.w,
          childAspectRatio: 0.92,
          children: [
            _buildToolCard(Icons.border_all, 'Frame', controller.onFrameTap),
            _buildToolCard(Icons.mood, 'Sticker', controller.onStickerTap),
            _buildToolCard(
              Icons.auto_fix_high,
              'Beauty',
              controller.onBeautyTap,
            ),
            _buildToolCard(Icons.crop, 'Crop', controller.onCropTap),
            _buildToolCard(
              Icons.auto_awesome,
              'Effect',
              controller.onEffectTap,
            ),
            _buildToolCard(Icons.camera_alt, 'Camera', controller.onCameraTap),
          ],
        ),
      ],
    );
  }

  Widget _buildToolCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.w),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD89AB5).withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                color: Color(0xFFF4D7E0),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20.w, color: const Color(0xFFD89AB5)),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4A2E3A)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspiration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INSPIRATION',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8C6F7F),
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          if (controller.inspirationRecords.isEmpty) {
            return SizedBox(
              height: 192.h,
              child: Center(
                child: Text(
                  'No works yet',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF8C6F7F),
                  ),
                ),
              ),
            );
          }
          return SizedBox(
            height: 192.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.inspirationRecords.length,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final record = controller.inspirationRecords[index];
                return GestureDetector(
                  onTap: () => controller.onInspirationTap(record.id!),
                  child: Container(
                    width: 128.w,
                    height: 192.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.w),
                      image: DecorationImage(
                        image: FileImage(File(record.filePath)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
