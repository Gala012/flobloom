import 'package:get/get.dart';
import 'flo_bloom_beauty_editor_logic.dart';
class FloBloomBeautyEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomBeautyEditorLogic());
  }
}
