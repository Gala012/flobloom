import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'flo_bloom_onboarding_2_logic.dart';

class FloBloomOnboarding2View extends GetView<FloBloomOnboarding2Logic> {
  const FloBloomOnboarding2View({super.key});
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
              final dx = details.velocity.pixelsPerSecond.dx;
              if (dx < -500) {
                controller.onSwipeLeft();
              } else if (dx > 500) {
                controller.onSwipeRight();
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
        AnimatedBuilder(
          animation: controller.bounceController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, controller.bounceAnimation.value),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: FloBloomColors.primaryLight.withOpacity(
                        0.6 + controller.glowAnimation.value / 200,
                      ),
                      blurRadius: controller.glowAnimation.value,
                      spreadRadius: controller.glowAnimation.value / 4,
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 128.w,
                      height: 128.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: FloBloomColors.primaryGradient,
                      ),
                      child: Icon(Icons.star, size: 64.w, color: Colors.white),
                    ),
                    Positioned(
                      top: -8.h,
                      right: -8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.w),
                          boxShadow: [
                            BoxShadow(
                              color: FloBloomColors.primaryDeep.withOpacity(
                                0.4,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: FloBloomColors.primaryDeep,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(height: 32.h),
        Text(
          'Trending Stickers',
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.bold,
            color: FloBloomColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Make editing easier',
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
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: FloBloomColors.accentGold2,
            borderRadius: BorderRadius.circular(4.h),
          ),
        ),
        SizedBox(width: 8.w),
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
      ],
    );
  }
}
