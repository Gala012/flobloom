import 'package:get/get.dart';
import 'flo_bloom_crop_editor_logic.dart';

class FloBloomCropEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomCropEditorLogic());
  }
}
