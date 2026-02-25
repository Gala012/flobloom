class FrameConfig {
  final String path;
  final String category;
  final FrameInset inset;
  final FrameContentArea contentArea;
  final FrameSize size;
  const FrameConfig({
    required this.path,
    required this.category,
    required this.inset,
    required this.contentArea,
    required this.size,
  });
}

class FrameInset {
  final double top;
  final double bottom;
  final double left;
  final double right;
  const FrameInset({
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });
}

class FrameContentArea {
  final double widthRatio;
  final double heightRatio;
  const FrameContentArea({required this.widthRatio, required this.heightRatio});
}

class FrameSize {
  final int width;
  final int height;
  const FrameSize({required this.width, required this.height});
}

class FrameConfigs {
  static const Map<String, FrameConfig> frames = {
    'frame_001': FrameConfig(
      path: 'assets/frames/simple/frame_001.png',
      category: 'simple',
      inset: FrameInset(top: 0.0997, bottom: 0.0997, left: 0.1, right: 0.1),
      contentArea: FrameContentArea(widthRatio: 0.8, heightRatio: 0.8005),
      size: FrameSize(width: 1920, height: 1544),
    ),
    'frame_002': FrameConfig(
      path: 'assets/frames/simple/frame_002.png',
      category: 'simple',
      inset: FrameInset(top: 0.1, bottom: 0.1, left: 0.0997, right: 0.0997),
      contentArea: FrameContentArea(widthRatio: 0.8007, heightRatio: 0.8),
      size: FrameSize(width: 1846, height: 1920),
    ),
    'frame_010': FrameConfig(
      path: 'assets/frames/simple/frame_010.png',
      category: 'simple',
      inset: FrameInset(top: 0.1, bottom: 0.1, left: 0.1, right: 0.1),
      contentArea: FrameContentArea(widthRatio: 0.8, heightRatio: 0.8),
      size: FrameSize(width: 1920, height: 1440),
    ),
    'frame_012': FrameConfig(
      path: 'assets/frames/simple/frame_012.png',
      category: 'simple',
      inset: FrameInset(top: 0.1, bottom: 0.1, left: 0.1005, right: 0.1),
      contentArea: FrameContentArea(widthRatio: 0.7995, heightRatio: 0.8),
      size: FrameSize(width: 1920, height: 1920),
    ),
    'frame_014': FrameConfig(
      path: 'assets/frames/simple/frame_014.png',
      category: 'simple',
      inset: FrameInset(top: 0.125, bottom: 0.0996, left: 0.0833, right: 0.1),
      contentArea: FrameContentArea(widthRatio: 0.8167, heightRatio: 0.7754),
      size: FrameSize(width: 1920, height: 1104),
    ),
    'frame_015': FrameConfig(
      path: 'assets/frames/simple/frame_015.png',
      category: 'simple',
      inset: FrameInset(top: 0.1766, bottom: 0.1766, left: 0.0984, right: 0.1),
      contentArea: FrameContentArea(widthRatio: 0.8016, heightRatio: 0.6467),
      size: FrameSize(width: 1920, height: 1104),
    ),
    'frame_016': FrameConfig(
      path: 'assets/frames/simple/frame_016.png',
      category: 'simple',
      inset: FrameInset(
        top: 0.0734,
        bottom: 0.1083,
        left: 0.0643,
        right: 0.095,
      ),
      contentArea: FrameContentArea(widthRatio: 0.8407, heightRatio: 0.8182),
      size: FrameSize(width: 1632, height: 1920),
    ),
    'frame_017': FrameConfig(
      path: 'assets/frames/simple/frame_017.png',
      category: 'simple',
      inset: FrameInset(
        top: 0.0859,
        bottom: 0.0859,
        left: 0.0836,
        right: 0.0836,
      ),
      contentArea: FrameContentArea(widthRatio: 0.8328, heightRatio: 0.8281),
      size: FrameSize(width: 1340, height: 1920),
    ),
    'frame_003': FrameConfig(
      path: 'assets/frames/modern/frame_003.png',
      category: 'modern',
      inset: FrameInset(top: 0.2108, bottom: 0.21, left: 0.149, right: 0.1484),
      contentArea: FrameContentArea(widthRatio: 0.7026, heightRatio: 0.5792),
      size: FrameSize(width: 1920, height: 1357),
    ),
    'frame_004': FrameConfig(
      path: 'assets/frames/modern/frame_004.png',
      category: 'modern',
      inset: FrameInset(top: 0.1586, bottom: 0.1617, left: 0.1, right: 0.1),
      contentArea: FrameContentArea(widthRatio: 0.8, heightRatio: 0.6797),
      size: FrameSize(width: 1920, height: 1280),
    ),
    'frame_005': FrameConfig(
      path: 'assets/frames/modern/frame_005.png',
      category: 'modern',
      inset: FrameInset(top: 0.1, bottom: 0.1, left: 0.1, right: 0.1),
      contentArea: FrameContentArea(widthRatio: 0.8, heightRatio: 0.8),
      size: FrameSize(width: 1280, height: 1920),
    ),
    'frame_006': FrameConfig(
      path: 'assets/frames/modern/frame_006.png',
      category: 'modern',
      inset: FrameInset(
        top: 0.1599,
        bottom: 0.1604,
        left: 0.1999,
        right: 0.1999,
      ),
      contentArea: FrameContentArea(widthRatio: 0.6003, heightRatio: 0.6797),
      size: FrameSize(width: 1536, height: 1920),
    ),
    'frame_007': FrameConfig(
      path: 'assets/frames/modern/frame_007.png',
      category: 'modern',
      inset: FrameInset(
        top: 0.0714,
        bottom: 0.0667,
        left: 0.0995,
        right: 0.0646,
      ),
      contentArea: FrameContentArea(widthRatio: 0.8359, heightRatio: 0.862),
      size: FrameSize(width: 1920, height: 1920),
    ),
    'frame_008': FrameConfig(
      path: 'assets/frames/modern/frame_008.png',
      category: 'modern',
      inset: FrameInset(top: 0.1, bottom: 0.1, left: 0.0997, right: 0.0997),
      contentArea: FrameContentArea(widthRatio: 0.8007, heightRatio: 0.8),
      size: FrameSize(width: 1846, height: 1920),
    ),
  };
  static FrameConfig? getFrame(String frameName) {
    return frames[frameName];
  }

  static List<String> getFramesByCategory(String category) {
    return frames.entries
        .where((entry) => entry.value.category == category)
        .map((entry) => entry.key)
        .toList();
  }

  static List<String> getAllFrameNames() {
    return frames.keys.toList();
  }
}
