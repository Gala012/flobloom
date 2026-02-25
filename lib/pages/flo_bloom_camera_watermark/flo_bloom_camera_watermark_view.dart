import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'flo_bloom_camera_watermark_logic.dart';

class FloBloomCameraWatermarkView
    extends GetView<FloBloomCameraWatermarkLogic> {
  const FloBloomCameraWatermarkView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildPreviewArea()),
                _buildBottomControls(),
              ],
            ),
            Obx(
              () => controller.isProcessing.value
                  ? Container(
                      color: Colors.black54,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: FloBloomColors.primaryLight,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.onBackTap,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_left, color: Colors.white, size: 24.w),
            ),
          ),
          Expanded(child: SizedBox()),
          Center(
            child: Text(
              'Camera Watermark',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildPreviewArea() {
    return Obx(() => _buildPreviewContent());
  }

  Widget _buildPreviewContent() {
    if (!controller.isInitialized.value) {
      return Container(
        width: double.infinity,
        color: Colors.grey[900],
        child: Center(
          child: CircularProgressIndicator(color: FloBloomColors.primaryLight),
        ),
      );
    }
    if (controller.isCaptured.value && controller.capturedFile.value != null) {
      return RepaintBoundary(
        key: controller.previewKey,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              controller.capturedFile.value!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            _buildDraggableWatermark(),
          ],
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: 100,
              height: 100 / controller.cameraController!.value.aspectRatio,
              child: CameraPreview(controller.cameraController!),
            ),
          ),
        ),
        _buildDraggableWatermark(),
      ],
    );
  }

  Widget _buildDraggableWatermark() {
    return Obx(
      () => Positioned(
        left: 12.w + controller.watermarkOffset.value.dx,
        bottom: 12.h - controller.watermarkOffset.value.dy,
        child: GestureDetector(
          onPanUpdate: controller.onWatermarkDragUpdate,
          child: _buildWatermarkCard(),
        ),
      ),
    );
  }

  Widget _buildWatermarkCard() {
    return Container(
      constraints: BoxConstraints(maxWidth: 230.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.68),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: const BoxDecoration(
              gradient: FloBloomColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on, color: Colors.white, size: 16.w),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Check-in Watermark',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                Obx(
                  () => _buildInfoRow(
                    Icons.access_time,
                    controller.formattedTime.value,
                  ),
                ),
                SizedBox(height: 3.h),
                Obx(
                  () => _buildInfoRow(
                    Icons.location_on,
                    controller.isLoadingLocation.value
                        ? 'Locating...'
                        : controller.address.value,
                  ),
                ),
                SizedBox(height: 3.h),
                Obx(
                  () => _buildInfoRow(
                    Icons.explore,
                    controller.isLoadingLocation.value
                        ? '--'
                        : controller.coordText.value,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.drag_indicator, color: Colors.white38, size: 16.w),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Icon(icon, size: 11.w, color: Colors.white70),
        ),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white.withOpacity(0.85),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Obx(() {
      if (!controller.isInitialized.value) {
        return SizedBox(height: 110.h);
      }
      if (controller.isCaptured.value) {
        return _buildCapturedControls();
      }
      return _buildCameraControls();
    });
  }

  Widget _buildCameraControls() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, size: 13.w, color: Colors.white38),
              SizedBox(width: 4.w),
              Text(
                'Drag watermark to reposition',
                style: TextStyle(fontSize: 11.sp, color: Colors.white38),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Obx(
            () => GestureDetector(
              onTap: controller.isCapturing.value
                  ? null
                  : controller.onCaptureTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: controller.isCapturing.value ? 66.w : 70.w,
                height: controller.isCapturing.value ? 66.w : 70.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.25),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: controller.isCapturing.value
                    ? Padding(
                        padding: EdgeInsets.all(18.w),
                        child: const CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.camera_alt, color: Colors.black, size: 28.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedControls() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 28.h),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: controller.onRetakeTap,
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(25.h),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, color: Colors.white, size: 18.w),
                    SizedBox(width: 6.w),
                    Text(
                      'Retake',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              onTap: controller.onSaveTap,
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  gradient: FloBloomColors.primaryGradient,
                  borderRadius: BorderRadius.circular(25.h),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_alt, color: Colors.white, size: 18.w),
                    SizedBox(width: 6.w),
                    Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
