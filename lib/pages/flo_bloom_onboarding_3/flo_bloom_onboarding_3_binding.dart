import 'package:get/get.dart';
import 'flo_bloom_onboarding_3_logic.dart';

class FloBloomOnboarding3Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomOnboarding3Logic());
  }
}
