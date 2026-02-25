import 'package:get/get.dart';
import 'flo_bloom_settings_logic.dart';

class FloBloomSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomSettingsLogic());
  }
}
