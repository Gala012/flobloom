import 'package:get/get.dart';
import 'flo_bloom_effect_editor_logic.dart';

class FloBloomEffectEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomEffectEditorLogic());
  }
}
