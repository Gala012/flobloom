import 'package:get/get.dart';
import 'flo_bloom_history_detail_logic.dart';

class FloBloomHistoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomHistoryDetailLogic());
  }
}
