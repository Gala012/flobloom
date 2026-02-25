import 'package:get/get.dart';
import 'flo_bloom_home_logic.dart';

class FloBloomHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomHomeLogic());
  }
}
