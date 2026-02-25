import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../components/flo_bloom_framed_image.dart';
import '../../config/frame_config.dart';
import '../../utils/colors.dart';
import 'flo_bloom_frame_editor_logic.dart';

class FloBloomFrameEditorView extends GetView<FloBloomFrameEditorLogic> {
  const FloBloomFrameEditorView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildImagePreview()),
                _buildFrameSelection(),
              ],
            ),
          ),
          Obx(() {
            if (!controller.isProcessing.value) return const SizedBox.shrink();
            return Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }),
        ],
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
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Obx(() {
          final image = controller.originalImage.value;
          final frame = controller.selectedFrame.value;
          final frameConfig = frame.isNotEmpty
              ? FrameConfigs.getFrame(frame)
              : null;
          const aspectRatio = 0.75;
          return AspectRatio(
            aspectRatio: aspectRatio,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                if (image == null) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16.w),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
                if (frame.isNotEmpty && frameConfig != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16.w),
                    child: FloBloomFramedImage(
                      frameName: frame,
                      imageProvider: FileImage(image),
                      width: w,
                      height: h,
                      imageFit: BoxFit.contain,
                    ),
                  );
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16.w),
                  child: Image.file(image, fit: BoxFit.contain),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFrameSelection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0), Colors.black, Colors.black],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Frames',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          _buildCategoryTabs(),
          SizedBox(height: 12.h),
          _buildFrameList(),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['simple', 'modern'];
    return Obx(
      () => Row(
        children: categories.map((category) {
          final isSelected = controller.selectedCategory.value == category;
          return GestureDetector(
            onTap: () => controller.onCategorySelect(category),
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: isSelected ? FloBloomColors.primaryGradient : null,
                color: isSelected ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.h),
              ),
              child: Text(
                category.capitalizeFirst ?? category,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFrameList() {
    return SizedBox(
      height: 96.h,
      child: Obx(() {
        final frames = controller.currentCategoryFrames;
        final selectedFrame = controller.selectedFrame.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: frames.length + 1,
          separatorBuilder: (_, __) => SizedBox(width: 10.w),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildNoneItem(selectedFrame.isEmpty);
            }
            final frameName = frames[index - 1];
            return _buildFrameItem(
              frameName: frameName,
              isSelected: selectedFrame == frameName,
            );
          },
        );
      }),
    );
  }

  Widget _buildNoneItem(bool isSelected) {
    return GestureDetector(
      onTap: () => controller.onFrameSelect(''),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12.w),
              border: Border.all(
                color: isSelected
                    ? FloBloomColors.primaryDeep
                    : Colors.grey[700]!,
                width: isSelected ? 2.5 : 1.5,
              ),
            ),
            child: Icon(
              Icons.hide_image_outlined,
              size: 28.w,
              color: isSelected
                  ? FloBloomColors.primaryLight
                  : Colors.grey[500],
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'None',
            style: TextStyle(
              fontSize: 11.sp,
              color: isSelected ? Colors.white : Colors.grey[500],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameItem({
    required String frameName,
    required bool isSelected,
  }) {
    final frameConfig = FrameConfigs.getFrame(frameName);
    final label = _frameLabel(frameName);
    return GestureDetector(
      onTap: () => controller.onFrameSelect(frameName),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12.w),
              border: Border.all(
                color: isSelected
                    ? FloBloomColors.primaryDeep
                    : Colors.grey[700]!,
                width: isSelected ? 2.5 : 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.w),
              child: frameConfig != null
                  ? Image.asset(
                      frameConfig.path,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.broken_image,
                        color: Colors.grey[600],
                        size: 28.w,
                      ),
                    )
                  : Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[600],
                      size: 28.w,
                    ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: isSelected ? Colors.white : Colors.grey[500],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _frameLabel(String frameName) {
    final numStr = frameName.replaceAll('frame_', '');
    final num = int.tryParse(numStr) ?? 0;
    return 'No.$num';
  }
}
