import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'flo_bloom_effect_editor_logic.dart';
import 'particle_effect_painter.dart';

class FloBloomEffectEditorView extends GetView<FloBloomEffectEditorLogic> {
  const FloBloomEffectEditorView({super.key});
  static const _effects = [
    {'name': 'None', 'icon': Icons.block},
    {'name': 'Petals', 'icon': Icons.local_florist},
    {'name': 'Firefly', 'icon': Icons.lightbulb_outline},
    {'name': 'Stars', 'icon': Icons.star_outline},
    {'name': 'Hearts', 'icon': Icons.favorite_outline},
    {'name': 'Glow', 'icon': Icons.wb_sunny_outlined},
  ];
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
                Expanded(child: _buildImagePreview()),
                _buildEffectControls(),
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
          Row(
            children: [
              GestureDetector(
                onTap: controller.togglePlayPause,
                child: Obx(
                  () => Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.isPlaying.value
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 20.w,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: controller.onSaveTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 8.h,
                  ),
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
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: RepaintBoundary(
          key: controller.previewKey,
          child: Stack(
            children: [
              Obx(() {
                final f = controller.originalImage.value;
                if (f == null) {
                  return Container(
                    height: 480.h,
                    decoration: BoxDecoration(
                      color: FloBloomColors.accentGold1,
                      borderRadius: BorderRadius.circular(16.w),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 80.w,
                        color: FloBloomColors.primaryDeep,
                      ),
                    ),
                  );
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16.w),
                  child: Image.file(f, height: 480.h, fit: BoxFit.contain),
                );
              }),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.w),
                  child: Obx(() {
                    final effectType = controller.selectedEffect.value;
                    if (effectType == 'None') {
                      return const SizedBox.shrink();
                    }
                    return AnimatedBuilder(
                      animation: controller.particleController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: ParticleEffectPainter(
                            effectType: effectType,
                            animValue: controller.particleController.value,
                            density: controller.density.value,
                            speed: controller.speed.value,
                            opacity: controller.opacity.value,
                            particles: controller.particles,
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEffectControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0), Colors.black, Colors.black],
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Dynamic Effects',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 54.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _effects.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (_, i) {
                final e = _effects[i];
                return Obx(() {
                  final isSelected =
                      controller.selectedEffect.value == e['name'];
                  return GestureDetector(
                    onTap: () => controller.onEffectSelect(e['name'] as String),
                    child: Container(
                      width: 64.w,
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? FloBloomColors.primaryDeep.withOpacity(0.25)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? FloBloomColors.primaryDeep
                              : Colors.grey[700]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            e['icon'] as IconData,
                            size: 18.w,
                            color: isSelected
                                ? FloBloomColors.primaryLight
                                : Colors.grey[400],
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            e['name'] as String,
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          SizedBox(height: 8.h),
          _buildSlider(
            'Density',
            controller.density,
            controller.onDensityChange,
            () => controller.densityLabel,
          ),
          SizedBox(height: 4.h),
          _buildSlider(
            'Speed',
            controller.speed,
            controller.onSpeedChange,
            () => controller.speedLabel,
          ),
          SizedBox(height: 4.h),
          _buildSlider(
            'Opacity',
            controller.opacity,
            controller.onOpacityChange,
            () => controller.opacityLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    RxDouble valueObs,
    Function(double) onChanged,
    String Function() displayValue,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.white),
            ),
            Obx(
              () => Text(
                displayValue(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Obx(
          () => SliderTheme(
            data: SliderThemeData(
              trackHeight: 4.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.w),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16.w),
              activeTrackColor: FloBloomColors.primaryDeep,
              inactiveTrackColor: Colors.white.withOpacity(0.2),
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
    );
  }
}
