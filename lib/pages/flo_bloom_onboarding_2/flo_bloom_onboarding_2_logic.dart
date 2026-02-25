import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FloBloomOnboarding2Logic extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController bounceController;
  late Animation<double> bounceAnimation;
  late Animation<double> glowAnimation;
  @override
  void onInit() {
    super.onInit();
    _initAnimation();
  }

  void _initAnimation() {
    bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    bounceAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: bounceController, curve: Curves.easeInOut),
    );
    glowAnimation = Tween<double>(begin: 20.0, end: 40.0).animate(
      CurvedAnimation(parent: bounceController, curve: Curves.easeInOut),
    );
    bounceController.repeat(reverse: true);
  }

  @override
  void onClose() {
    bounceController.dispose();
    super.onClose();
  }

  void onNextTap() {
    Get.toNamed('/flo_bloom_onboarding_3');
  }

  void onSwipeLeft() {
    Get.toNamed('/flo_bloom_onboarding_3');
  }

  void onSwipeRight() {
    Get.back();
  }
}
