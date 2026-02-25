import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../flo_bloom_home/flo_bloom_home_logic.dart';
import '../flo_bloom_history/flo_bloom_history_logic.dart';

class FloBloomTabLogic extends GetxController {
  var currentIndex = 0.obs;
  @override
  void onInit() {
    super.onInit();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void changeTab(int index) {
    currentIndex.value = index;
    _refreshCurrentPage(index);
  }

  void _refreshCurrentPage(int index) {
    try {
      if (index == 0) {
        final homeLogic = Get.find<FloBloomHomeLogic>();
        homeLogic.refresh();
      } else if (index == 1) {
        final historyLogic = Get.find<FloBloomHistoryLogic>();
        historyLogic.refresh();
      }
    } catch (e) {
      print('Failed to refresh page: $e');
    }
  }
}
