import 'package:flutter/material.dart';
import 'package:flo_bloom/config/frame_config.dart';

class FloBloomFramedImage extends StatelessWidget {
  final String frameName;
  final ImageProvider imageProvider;
  final double width;
  final double height;
  final BoxFit imageFit;
  const FloBloomFramedImage({
    super.key,
    required this.frameName,
    required this.imageProvider,
    required this.width,
    required this.height,
    this.imageFit = BoxFit.cover,
  });
  @override
  Widget build(BuildContext context) {
    final frameConfig = FrameConfigs.getFrame(frameName);
    if (frameConfig == null) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.red),
        ),
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: height * frameConfig.inset.top,
                bottom: height * frameConfig.inset.bottom,
                left: width * frameConfig.inset.left,
                right: width * frameConfig.inset.right,
              ),
              child: ClipRect(
                child: Image(image: imageProvider, fit: imageFit),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(frameConfig.path, fit: BoxFit.fill),
          ),
        ],
      ),
    );
  }
}

class FloBloomFrameSelector extends StatelessWidget {
  final String category;
  final String? selectedFrame;
  final Function(String frameName) onFrameSelected;
  final double itemSize;
  const FloBloomFrameSelector({
    super.key,
    required this.category,
    this.selectedFrame,
    required this.onFrameSelected,
    this.itemSize = 80.0,
  });
  @override
  Widget build(BuildContext context) {
    final frameNames = FrameConfigs.getFramesByCategory(category);
    return SizedBox(
      height: itemSize + 20,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: frameNames.length,
        itemBuilder: (context, index) {
          final frameName = frameNames[index];
          final frameConfig = FrameConfigs.getFrame(frameName);
          final isSelected = frameName == selectedFrame;
          if (frameConfig == null) return const SizedBox.shrink();
          return GestureDetector(
            onTap: () => onFrameSelected(frameName),
            child: Container(
              width: itemSize,
              height: itemSize,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(frameConfig.path, fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }
}
