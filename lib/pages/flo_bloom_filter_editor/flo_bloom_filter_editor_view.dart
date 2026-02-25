import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'flo_bloom_filter_editor_logic.dart';

class FloBloomFilterEditorView extends GetView<FloBloomFilterEditorLogic> {
  const FloBloomFilterEditorView({super.key});
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
            _buildFilterSelection(),
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
      final image = controller.currentImage.value;
      final isLoading = controller.isLoadingFilter.value;
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16.w),
                ),
                child: image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16.w),
                        child: Image.file(image, fit: BoxFit.contain),
                      )
                    : Center(
                        child: Icon(
                          Icons.image,
                          size: 80.w,
                          color: Colors.white54,
                        ),
                      ),
              ),
              if (isLoading)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFilterSelection() {
    return Obx(() {
      final filters = controller.filterList;
      final originalImage = controller.originalImage.value;
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
              'Filters',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 92.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (context, index) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final filterName = filter['name'] as String;
                  return Obx(() {
                    final isSelected =
                        controller.selectedFilter.value == filterName;
                    final thumbFile =
                        controller.filterThumbnails[filterName] ??
                        originalImage;
                    return GestureDetector(
                      onTap: () => controller.onFilterSelect(filterName),
                      child: Column(
                        children: [
                          Container(
                            width: 64.w,
                            height: 64.w,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12.w),
                              border: Border.all(
                                color: isSelected
                                    ? FloBloomColors.primaryDeep
                                    : Colors.grey[700]!,
                                width: 2,
                              ),
                            ),
                            child: thumbFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10.w),
                                    child: Image.file(
                                      thumbFile,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 32.w,
                                      color: Colors.white54,
                                    ),
                                  ),
                          ),
                          SizedBox(height: 8.h),
                          SizedBox(
                            width: 70.w,
                            child: Text(
                              filter['displayName'] as String,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
