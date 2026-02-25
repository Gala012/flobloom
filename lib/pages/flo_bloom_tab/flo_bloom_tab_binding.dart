import 'package:get/get.dart';
import '../flo_bloom_home/flo_bloom_home_binding.dart';
import '../flo_bloom_history/flo_bloom_history_binding.dart';
import '../flo_bloom_settings/flo_bloom_settings_binding.dart';
import 'flo_bloom_tab_logic.dart';

class FloBloomTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomTabLogic());
    FloBloomHomeBinding().dependencies();
    FloBloomHistoryBinding().dependencies();
    FloBloomSettingsBinding().dependencies();
  }
}
