import 'package:get/get.dart';
import 'flo_bloom_sticker_editor_logic.dart';

class FloBloomStickerEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomStickerEditorLogic());
  }
}
