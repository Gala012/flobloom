import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'flo_bloom_crop_editor_logic.dart';

class _CropRatio {
  final String label;
  final int? rW;
  final int? rH;
  const _CropRatio(this.label, [this.rW, this.rH]);
  double get aspectRatio => (rW != null && rH != null) ? rW! / rH! : 3 / 4;
}

class FloBloomCropEditorView extends GetView<FloBloomCropEditorLogic> {
  const FloBloomCropEditorView({super.key});
  static const _ratios = [
    _CropRatio('Original'),
    _CropRatio('1:1', 1, 1),
    _CropRatio('2:3', 2, 3),
    _CropRatio('3:4', 3, 4),
    _CropRatio('4:5', 4, 5),
    _CropRatio('9:16', 9, 16),
    _CropRatio('16:9', 16, 9),
    _CropRatio('3:2', 3, 2),
    _CropRatio('4:3', 4, 3),
    _CropRatio('5:4', 5, 4),
  ];
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Obx(() {
                  final hasImage = controller.currentImage.value != null;
                  return hasImage
                      ? _buildCropArea()
                      : _buildNoImagePlaceholder();
                }),
              ),
              _buildRatioSelection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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

  Widget _buildNoImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.crop,
            size: 80.w,
            color: FloBloomColors.primaryDeep.withOpacity(0.5),
          ),
          SizedBox(height: 24.h),
          Text(
            'No image selected',
            style: TextStyle(fontSize: 18.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCropArea() {
    return Obx(() {
      final displayImage = controller.currentImage.value;
      if (displayImage == null) return const SizedBox.shrink();
      return SizedBox(
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.updateContainerSize(
                constraints.maxWidth,
                constraints.maxHeight,
              );
            });
            return Stack(
              children: [
                InteractiveViewer(
                  transformationController: controller.transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  panEnabled: true,
                  scaleEnabled: true,
                  boundaryMargin: const EdgeInsets.all(500),
                  constrained: false,
                  child: Container(
                    width: constraints.maxWidth,
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: _buildImageWithMeasurement(
                      displayImage,
                      constraints,
                    ),
                  ),
                ),
                _buildCropOverlay(),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _buildImageWithMeasurement(
    File imageFile,
    BoxConstraints constraints,
  ) {
    return Image.file(
      imageFile,
      fit: BoxFit.contain,
      width: constraints.maxWidth,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame == null) return child;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null && renderBox.hasSize) {
            final displayRect = Rect.fromLTWH(
              0,
              0,
              renderBox.size.width,
              renderBox.size.height,
            );
            controller.updateImageDisplayRect(displayRect);
          }
        });
        return child;
      },
    );
  }

  Widget _buildCropOverlay() {
    return Obx(() {
      if (controller.cropBoxWidth.value == 0 ||
          controller.cropBoxHeight.value == 0) {
        return const SizedBox.shrink();
      }
      final cropLeft = controller.cropBoxLeft.value;
      final cropTop = controller.cropBoxTop.value;
      final cropBoxWidth = controller.cropBoxWidth.value;
      final cropBoxHeight = controller.cropBoxHeight.value;
      return Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CropMaskPainter(
                  cropRect: Rect.fromLTWH(
                    cropLeft,
                    cropTop,
                    cropBoxWidth,
                    cropBoxHeight,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: cropLeft,
            top: cropTop,
            width: cropBoxWidth,
            height: cropBoxHeight,
            child: GestureDetector(
              onScaleStart: controller.onCropBoxScaleStart,
              onScaleUpdate: controller.onCropBoxScaleUpdate,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: FloBloomColors.primaryDeep,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  IgnorePointer(child: _buildGridLines()),
                  ..._buildCornerHandles(),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildGridLines() {
    return Column(
      children: List.generate(
        3,
        (i) => Expanded(
          child: Row(
            children: List.generate(
              3,
              (j) => Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: FloBloomColors.primaryDeep.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCornerHandles() {
    return [
      Positioned(top: -10.w, left: -10.w, child: _buildHandle('topLeft')),
      Positioned(top: -10.w, right: -10.w, child: _buildHandle('topRight')),
      Positioned(bottom: -10.w, left: -10.w, child: _buildHandle('bottomLeft')),
      Positioned(
        bottom: -10.w,
        right: -10.w,
        child: _buildHandle('bottomRight'),
      ),
    ];
  }

  Widget _buildHandle(String corner) {
    return GestureDetector(
      onPanStart: (details) {
        controller.onCornerResizeStart(details.globalPosition, corner);
      },
      onPanUpdate: (details) {
        controller.onCornerResizeUpdate(details.globalPosition, corner);
      },
      onPanEnd: (_) {
        controller.onCornerResizeEnd();
      },
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: FloBloomColors.primaryDeep,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.open_in_full, size: 14.w, color: Colors.white),
      ),
    );
  }

  Widget _buildRatioSelection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0), Colors.black, Colors.black],
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
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
                'Crop Ratio',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 76.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _ratios.length,
              itemBuilder: (context, index) {
                final ratio = _ratios[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _ratios.length - 1 ? 6.w : 0,
                  ),
                  child: Obx(() {
                    final isSelected =
                        controller.selectedRatio.value == ratio.label;
                    return _buildRatioItem(ratio, isSelected);
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioItem(_CropRatio ratio, bool isSelected) {
    const double maxDim = 28;
    final double ar = ratio.aspectRatio;
    final double shapeW = ar >= 1 ? maxDim : maxDim * ar;
    final double shapeH = ar >= 1 ? maxDim / ar : maxDim;
    return GestureDetector(
      onTap: () => controller.onRatioSelect(ratio.label),
      child: Container(
        width: 58.w,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? FloBloomColors.primaryDeep.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.h),
          border: isSelected
              ? Border.all(
                  color: FloBloomColors.primaryDeep.withOpacity(0.45),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: (maxDim + 4).w,
              height: (maxDim + 4).w,
              child: Center(
                child: Container(
                  width: shapeW.w,
                  height: shapeH.w,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? FloBloomColors.primaryDeep
                          : Colors.white.withOpacity(0.5),
                      width: isSelected ? 2 : 1.5,
                    ),
                    color: isSelected
                        ? FloBloomColors.primaryDeep.withOpacity(0.15)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              ratio.label,
              style: TextStyle(
                fontSize: 10.sp,
                color: isSelected
                    ? FloBloomColors.primaryLight
                    : Colors.white.withOpacity(0.65),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropMaskPainter extends CustomPainter {
  final Rect cropRect;
  _CropMaskPainter({required this.cropRect});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, cropRect.top), paint);
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        cropRect.bottom,
        size.width,
        size.height - cropRect.bottom,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, cropRect.top, cropRect.left, cropRect.height),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        cropRect.right,
        cropRect.top,
        size.width - cropRect.right,
        cropRect.height,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CropMaskPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}
