import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../flo_bloom_home/flo_bloom_home_view.dart';
import '../flo_bloom_history/flo_bloom_history_view.dart';
import '../flo_bloom_settings/flo_bloom_settings_view.dart';
import 'flo_bloom_tab_logic.dart';

class FloBloomTabView extends GetView<FloBloomTabLogic> {
  const FloBloomTabView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FloBloomColors.background,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            FloBloomHomeView(),
            FloBloomHistoryView(),
            FloBloomSettingsView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => _buildBottomNavigationBar()),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: FloBloomColors.primaryDeep.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h).copyWith(bottom: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(
                icon: Icons.home,
                label: 'Home',
                index: 0,
                isActive: controller.currentIndex.value == 0,
              ),
              _buildTabItem(
                icon: Icons.history,
                label: 'History',
                index: 1,
                isActive: controller.currentIndex.value == 1,
              ),
              _buildTabItem(
                icon: Icons.settings,
                label: 'Settings',
                index: 2,
                isActive: controller.currentIndex.value == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24.w,
                color: isActive
                    ? FloBloomColors.primaryDeep
                    : FloBloomColors.textSecondary,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive
                      ? FloBloomColors.primaryDeep
                      : FloBloomColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
