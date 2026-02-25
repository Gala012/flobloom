class FloBloomRecord {
  final int? id;
  final String filePath;
  final String originalPath;
  final int createTime;
  final int fileSize;
  final String resolution;
  final int isAnimated;
  final String? filterName;
  final String? stickers;
  final String? effectName;
  final int hasBeauty;
  final int hasCrop;
  final int hasFrame;
  final int hasWatermark;
  FloBloomRecord({
    this.id,
    required this.filePath,
    required this.originalPath,
    required this.createTime,
    required this.fileSize,
    required this.resolution,
    required this.isAnimated,
    this.filterName,
    this.stickers,
    this.effectName,
    required this.hasBeauty,
    required this.hasCrop,
    required this.hasFrame,
    required this.hasWatermark,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_path': filePath,
      'original_path': originalPath,
      'create_time': createTime,
      'file_size': fileSize,
      'resolution': resolution,
      'is_animated': isAnimated,
      'filter_name': filterName,
      'stickers': stickers,
      'effect_name': effectName,
      'has_beauty': hasBeauty,
      'has_crop': hasCrop,
      'has_frame': hasFrame,
      'has_watermark': hasWatermark,
    };
  }

  factory FloBloomRecord.fromMap(Map<String, dynamic> map) {
    return FloBloomRecord(
      id: map['id'] as int?,
      filePath: map['file_path'] as String,
      originalPath: map['original_path'] as String,
      createTime: map['create_time'] as int,
      fileSize: map['file_size'] as int,
      resolution: map['resolution'] as String,
      isAnimated: map['is_animated'] as int,
      filterName: map['filter_name'] as String?,
      stickers: map['stickers'] as String?,
      effectName: map['effect_name'] as String?,
      hasBeauty: map['has_beauty'] as int,
      hasCrop: map['has_crop'] as int,
      hasFrame: map['has_frame'] as int,
      hasWatermark: map['has_watermark'] as int,
    );
  }
  FloBloomRecord copyWith({
    int? id,
    String? filePath,
    String? originalPath,
    int? createTime,
    int? fileSize,
    String? resolution,
    int? isAnimated,
    String? filterName,
    String? stickers,
    String? effectName,
    int? hasBeauty,
    int? hasCrop,
    int? hasFrame,
    int? hasWatermark,
  }) {
    return FloBloomRecord(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      originalPath: originalPath ?? this.originalPath,
      createTime: createTime ?? this.createTime,
      fileSize: fileSize ?? this.fileSize,
      resolution: resolution ?? this.resolution,
      isAnimated: isAnimated ?? this.isAnimated,
      filterName: filterName ?? this.filterName,
      stickers: stickers ?? this.stickers,
      effectName: effectName ?? this.effectName,
      hasBeauty: hasBeauty ?? this.hasBeauty,
      hasCrop: hasCrop ?? this.hasCrop,
      hasFrame: hasFrame ?? this.hasFrame,
      hasWatermark: hasWatermark ?? this.hasWatermark,
    );
  }
}
