import 'package:get/get.dart';

import 'flo_bloom_cloud_logic.dart';

class FloBloomCloudBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      FloBloomCloudLogic(),
      permanent: true,
    );
  }
}
