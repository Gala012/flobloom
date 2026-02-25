import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'flo_bloom_settings_logic.dart';

class FloBloomSettingsView extends GetView<FloBloomSettingsLogic> {
  const FloBloomSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FloBloomColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    _buildAppInfo(),
                    SizedBox(height: 24.h),
                    _buildStorageSection(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Settings',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: FloBloomColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: FloBloomColors.primaryDeep.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              gradient: FloBloomColors.primaryGradient,
              borderRadius: BorderRadius.circular(16.w),
            ),
            child: Icon(Icons.local_florist, size: 32.w, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FloBloom',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: FloBloomColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: FloBloomColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
          child: Text(
            'STORAGE',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: FloBloomColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.w),
            boxShadow: [
              BoxShadow(
                color: FloBloomColors.primaryDeep.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildSettingItem(
            Icons.cleaning_services,
            'Clear All Data',
            trailing: Icon(
              Icons.chevron_right,
              size: 18.w,
              color: FloBloomColors.textSecondary,
            ),
            onTap: controller.onClearAllDataTap,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String label, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        color: Colors.transparent,
        child: Row(
          children: [
            Icon(icon, size: 20.w, color: FloBloomColors.primaryDeep),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: FloBloomColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
