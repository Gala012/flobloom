import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'flo_bloom_sticker_editor_logic.dart';

class FloBloomStickerEditorView extends GetView<FloBloomStickerEditorLogic> {
  const FloBloomStickerEditorView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildImagePreview()),
                _buildStickerPanel(),
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
          GestureDetector(
            onTap: controller.onSaveTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: FloBloomColors.primaryGradient,
                borderRadius: BorderRadius.circular(20.h),
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: controller.deselectAll,
      child: LayoutBuilder(
        builder: (context, constraints) {
          controller.containerWidth = constraints.maxWidth;
          controller.containerHeight = constraints.maxHeight;
          return RepaintBoundary(
            key: controller.previewKey,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.black),
                Obx(() {
                  final f = controller.originalImage.value;
                  if (f == null) {
                    return Center(
                      child: Icon(
                        Icons.image,
                        size: 80.w,
                        color: FloBloomColors.primaryLight,
                      ),
                    );
                  }
                  return Image.file(f, fit: BoxFit.contain);
                }),
                Obx(
                  () => Stack(
                    children: controller.stickers
                        .map((s) => _buildStickerWidget(s))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStickerWidget(StickerItem sticker) {
    final double baseSize = 40.w;
    final double framePad = 6.w;
    final double handleR = 11.w;
    final double frameSize = baseSize + framePad * 2;
    final double totalSize = frameSize + handleR * 2;
    final cW = controller.containerWidth;
    final cH = controller.containerHeight;
    final left = sticker.x * cW - totalSize / 2;
    final top = sticker.y * cH - totalSize / 2;
    return Obx(() {
      final isSelected = controller.selectedStickerId.value == sticker.id;
      return Positioned(
        left: left,
        top: top,
        child: Transform.rotate(
          angle: sticker.rotation,
          child: Transform.scale(
            scale: sticker.scale,
            child: SizedBox(
              width: totalSize,
              height: totalSize,
              child: Stack(
                children: [
                  Positioned(
                    left: handleR,
                    top: handleR,
                    width: frameSize,
                    height: frameSize,
                    child: GestureDetector(
                      onTap: () => controller.onStickerTap(sticker.id),
                      onPanUpdate: (d) => controller.onStickerDrag(
                        sticker.id,
                        d.delta.dx,
                        d.delta.dy,
                      ),
                      child: Container(
                        decoration: isSelected
                            ? BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5.w,
                                ),
                                borderRadius: BorderRadius.circular(8.w),
                              )
                            : null,
                        child: Center(
                          child: sticker.isAnimated
                              ? _buildAnimatedEmoji(sticker, baseSize)
                              : Text(
                                  sticker.emoji,
                                  style: TextStyle(fontSize: baseSize),
                                ),
                        ),
                      ),
                    ),
                  ),
                  if (isSelected) ...[
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => controller.onStickerDelete(sticker.id),
                        child: _buildHandle(
                          Icons.close,
                          Colors.redAccent,
                          handleR,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onPanUpdate: (d) => controller.onStickerScale(
                          sticker.id,
                          d.delta.dx,
                          d.delta.dy,
                        ),
                        child: _buildHandle(
                          Icons.zoom_out_map,
                          FloBloomColors.primaryDeep,
                          handleR,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onPanUpdate: (d) =>
                            controller.onStickerRotate(sticker.id, d.delta.dx),
                        child: _buildHandle(
                          Icons.rotate_right,
                          FloBloomColors.primaryDeep,
                          handleR,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHandle(IconData icon, Color color, double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, size: radius * 1.2, color: Colors.white),
    );
  }

  Widget _buildAnimatedEmoji(StickerItem sticker, double baseSize) {
    return AnimatedBuilder(
      animation: controller.animationController,
      builder: (context, child) {
        final t = controller.animationController.value;
        final scale = 1.0 + 0.15 * math.sin(t * 2 * math.pi);
        final opacity = (0.7 + 0.3 * math.sin(t * 4 * math.pi)).clamp(0.0, 1.0);
        return Transform.scale(
          scale: scale,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: Text(sticker.emoji, style: TextStyle(fontSize: baseSize)),
    );
  }

  Widget _buildStickerPanel() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0), Colors.black, Colors.black],
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => Row(
              children: [
                _buildTabButton('Static'),
                SizedBox(width: 16.w),
                _buildTabButton('Animated'),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Obx(
            () => SizedBox(
              height: 156.h,
              child: controller.selectedTab.value == 'Static'
                  ? _buildStaticGrid()
                  : _buildAnimatedGrid(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final isSelected = controller.selectedTab.value == label;
    return GestureDetector(
      onTap: () => controller.onTabChange(label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            height: 2.h,
            width: 56.w,
            color: isSelected ? FloBloomColors.primaryDeep : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildStaticGrid() {
    return GridView.builder(
      scrollDirection: Axis.vertical,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.0,
      ),
      itemCount: FloBloomStickerEditorLogic.staticStickers.length,
      itemBuilder: (_, i) {
        final emoji = FloBloomStickerEditorLogic.staticStickers[i];
        return GestureDetector(
          onTap: () => controller.addSticker(emoji),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Center(
              child: Text(emoji, style: TextStyle(fontSize: 26.sp)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedGrid() {
    final items = FloBloomStickerEditorLogic.animatedStickers;
    return GridView.builder(
      scrollDirection: Axis.vertical,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return GestureDetector(
          onTap: () => controller.addSticker(item['emoji']!, isAnimated: true),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.w),
              border: Border.all(
                color: FloBloomColors.primaryLight.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item['emoji']!, style: TextStyle(fontSize: 24.sp)),
                SizedBox(height: 3.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.animation,
                      size: 9.sp,
                      color: FloBloomColors.primaryLight,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      item['name']!,
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: FloBloomColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
