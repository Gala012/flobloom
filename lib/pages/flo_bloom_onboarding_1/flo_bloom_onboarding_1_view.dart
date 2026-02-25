import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'flo_bloom_onboarding_1_logic.dart';

class FloBloomOnboarding1View extends GetView<FloBloomOnboarding1Logic> {
  const FloBloomOnboarding1View({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9E8F0), Color(0xFFE8B7C8), Color(0xFFF4D7E0)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: controller.onNextTap,
            onPanEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx < -500) {
                controller.onSwipeLeft();
              }
            },
            child: Column(
              children: [
                Expanded(child: _buildContent()),
                _buildPageIndicator(),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 128.w,
          height: 128.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: FloBloomColors.primaryGradient,
          ),
          child: Icon(Icons.camera_alt, size: 64.w, color: Colors.white),
        ),
        SizedBox(height: 32.h),
        Text(
          'Photo Editing',
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.bold,
            color: FloBloomColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'One-tap stunning results',
          style: TextStyle(
            fontSize: 18.sp,
            color: FloBloomColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: FloBloomColors.primaryDeep,
            borderRadius: BorderRadius.circular(4.h),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: FloBloomColors.accentGold2,
            borderRadius: BorderRadius.circular(4.h),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: FloBloomColors.accentGold2,
            borderRadius: BorderRadius.circular(4.h),
          ),
        ),
      ],
    );
  }
}
