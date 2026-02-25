import 'package:get/get.dart';

class FloBloomOnboarding3Logic extends GetxController {
  void onGetStartedTap() {
    Get.offAllNamed('/flo_bloom_tab');
  }

  void onSwipeRight() {
    Get.back();
  }
}
