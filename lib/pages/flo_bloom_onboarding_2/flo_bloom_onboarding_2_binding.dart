import 'package:get/get.dart';
import 'flo_bloom_onboarding_2_logic.dart';

class FloBloomOnboarding2Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomOnboarding2Logic());
  }
}
