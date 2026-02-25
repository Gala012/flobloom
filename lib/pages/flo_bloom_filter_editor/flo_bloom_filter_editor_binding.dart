import 'package:get/get.dart';
import 'flo_bloom_filter_editor_logic.dart';

class FloBloomFilterEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomFilterEditorLogic());
  }
}
