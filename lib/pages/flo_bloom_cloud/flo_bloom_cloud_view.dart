import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'flo_bloom_cloud_logic.dart';

class FloBloomCloudView extends GetView<FloBloomCloudLogic> {
  const FloBloomCloudView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(
          () => controller.tmjpuio.value
              ? const CircularProgressIndicator(color: Colors.pinkAccent)
              : buildError(),
        ),
      ),
    );
  }

  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              controller.bcuog();
            },
            icon: const Icon(
              Icons.restart_alt,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }
}
