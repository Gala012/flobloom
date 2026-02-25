import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'flo_bloom_beauty_editor_logic.dart';
class FloBloomBeautyEditorView extends GetView<FloBloomBeautyEditorLogic> {
  const FloBloomBeautyEditorView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildImagePreview()),
            _buildBeautyControls(),
          ],
        ),
      ),
    );
  }
  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: controller.onBackTap,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_left, color: Colors.white, size: 24.w),
            ),
          ),
          Obx(() {
            final isProcessing = controller.isProcessing.value;
            return GestureDetector(
              onTap: isProcessing ? null : controller.onSaveTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: isProcessing
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.grey[600]!, Colors.grey[700]!],
                        )
                      : FloBloomColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20.h),
                ),
                child: isProcessing
                    ? SizedBox(
                        width: 40.w,
                        height: 20.h,
                        child: const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
  Widget _buildImagePreview() {
    return Obx(() {
      final image = controller.originalImage.value;
      final smoothValue = controller.smoothSkin.value;
      final brightenValue = controller.brighten.value;
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16.w),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16.w),
                    child: _applyGpuFilters(
                      child: Image.file(image, fit: BoxFit.contain),
                      smoothValue: smoothValue,
                      brightenValue: brightenValue,
                    ),
                  )
                : Center(
                    child: Icon(Icons.image, size: 80.w, color: Colors.white54),
                  ),
          ),
        ),
      );
    });
  }
  Widget _applyGpuFilters({
    required Widget child,
    required double smoothValue,
    required double brightenValue,
  }) {
    Widget result = child;
    if (brightenValue > 0) {
      final t = (brightenValue / 100) * (brightenValue / 100);
      final b = 1.0 + t * 0.6;
      final s = 1.0 - t * 0.18;
      const lumR = 0.213, lumG = 0.715, lumB = 0.072;
      result = ColorFiltered(
        colorFilter: ColorFilter.matrix([
          (lumR + (1 - lumR) * s) * b,
          (lumG - lumG * s) * b,
          (lumB - lumB * s) * b,
          0,
          0,
          (lumR - lumR * s) * b,
          (lumG + (1 - lumG) * s) * b,
          (lumB - lumB * s) * b,
          0,
          0,
          (lumR - lumR * s) * b,
          (lumG - lumG * s) * b,
          (lumB + (1 - lumB) * s) * b,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: result,
      );
    }
    if (smoothValue > 0) {
      final t = (smoothValue / 100) * (smoothValue / 100);
      final sigma = t * 1.5;
      result = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: result,
      );
      final brighten = 1.0 + t * 0.06;
      final soften = 1.0 - t * 0.04;
      result = ColorFiltered(
        colorFilter: ColorFilter.matrix([
          soften * brighten,
          0,
          0,
          0,
          0,
          0,
          soften * brighten,
          0,
          0,
          0,
          0,
          0,
          soften * brighten,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: result,
      );
    }
    return result;
  }
  Widget _buildBeautyControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0), Colors.black, Colors.black],
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 3.w,
                height: 14.h,
                decoration: BoxDecoration(
                  gradient: FloBloomColors.primaryGradient,
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Beauty',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildSliderControl(
            icon: Icons.mood_outlined,
            label: 'Smooth Skin',
            valueObs: controller.smoothSkin,
            onChanged: controller.onSmoothSkinChange,
          ),
          SizedBox(height: 10.h),
          _buildSliderControl(
            icon: Icons.wb_sunny_outlined,
            label: 'Brighten',
            valueObs: controller.brighten,
            onChanged: controller.onBrightenChange,
          ),
        ],
      ),
    );
  }
  Widget _buildSliderControl({
    required IconData icon,
    required String label,
    required RxDouble valueObs,
    required Function(double) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: FloBloomColors.primaryLight, size: 18.w),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: FloBloomColors.primaryDeep.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Text(
                        '${valueObs.value.toInt()}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: FloBloomColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Obx(
                () => SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3.h,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.w),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 16.w),
                    activeTrackColor: FloBloomColors.primaryDeep,
                    inactiveTrackColor: Colors.white.withOpacity(0.15),
                    thumbColor: FloBloomColors.primaryDeep,
                    overlayColor: FloBloomColors.primaryDeep.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: valueObs.value,
                    min: 0,
                    max: 100,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
