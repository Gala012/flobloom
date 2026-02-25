import 'package:get/get.dart';
import 'flo_bloom_onboarding_1_logic.dart';

class FloBloomOnboarding1Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomOnboarding1Logic());
  }
}
