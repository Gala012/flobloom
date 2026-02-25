import 'package:get/get.dart';
import 'flo_bloom_frame_editor_logic.dart';

class FloBloomFrameEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomFrameEditorLogic());
  }
}
