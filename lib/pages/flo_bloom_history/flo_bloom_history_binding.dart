import 'package:get/get.dart';
import 'flo_bloom_history_logic.dart';

class FloBloomHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FloBloomHistoryLogic());
  }
}
