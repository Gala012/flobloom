import 'package:get/get.dart';
import 'flo_bloom_camera_watermark_logic.dart';

class FloBloomCameraWatermarkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomCameraWatermarkLogic());
  }
}
