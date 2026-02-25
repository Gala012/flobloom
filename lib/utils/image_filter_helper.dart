import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class _FilterParams {
  final String imagePath;
  final String filterName;
  final String outputPath;
  final int? thumbnailSize;
  _FilterParams({
    required this.imagePath,
    required this.filterName,
    required this.outputPath,
    this.thumbnailSize,
  });
}

Future<bool> _applyFilterInIsolate(_FilterParams params) async {
  try {
    final bytes = await File(params.imagePath).readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) return false;
    if (params.thumbnailSize != null) {
      image = img.copyResizeCropSquare(image, size: params.thumbnailSize!);
    }
    img.Image filteredImage;
    switch (params.filterName) {
      case 'None':
        filteredImage = image;
        break;
      case 'Rose Twilight':
        filteredImage = _applyRoseTwilight(image);
        break;
      case 'Cherry Dream':
        filteredImage = _applyCherryDream(image);
        break;
      case 'Pure B&W':
        filteredImage = _applyBlackWhite(image);
        break;
      case 'Vintage':
        filteredImage = _applyVintage(image);
        break;
      case 'Glamour':
        filteredImage = _applyGlamour(image);
        break;
      case 'Lavender':
        filteredImage = _applyLavender(image);
        break;
      case 'Moonlight':
        filteredImage = _applyMoonlight(image);
        break;
      case 'Warm Memory':
        filteredImage = _applyWarmMemory(image);
        break;
      default:
        filteredImage = image;
    }
    final encodedImage = img.encodeJpg(filteredImage, quality: 90);
    await File(params.outputPath).writeAsBytes(encodedImage);
    return true;
  } catch (e) {
    print('Error in isolate: $e');
    return false;
  }
}

img.Image _applyRoseTwilight(img.Image image) {
  final adjusted = img.adjustColor(image, saturation: 1.2, brightness: 1.05);
  for (var y = 0; y < adjusted.height; y++) {
    for (var x = 0; x < adjusted.width; x++) {
      final pixel = adjusted.getPixel(x, y);
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;
      final newR = (r * 1.15).clamp(0, 255).toInt();
      final newG = (g * 1.05).clamp(0, 255).toInt();
      final newB = (b * 0.95).clamp(0, 255).toInt();
      adjusted.setPixelRgba(x, y, newR, newG, newB, pixel.a.toInt());
    }
  }
  return adjusted;
}

img.Image _applyCherryDream(img.Image image) {
  final adjusted = img.adjustColor(image, saturation: 0.9, brightness: 1.1);
  for (var y = 0; y < adjusted.height; y++) {
    for (var x = 0; x < adjusted.width; x++) {
      final pixel = adjusted.getPixel(x, y);
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;
      final newR = (r * 1.1).clamp(0, 255).toInt();
      final newG = (g * 1.0).clamp(0, 255).toInt();
      final newB = (b * 1.05).clamp(0, 255).toInt();
      adjusted.setPixelRgba(x, y, newR, newG, newB, pixel.a.toInt());
    }
  }
  return adjusted;
}

img.Image _applyBlackWhite(img.Image image) {
  return img.grayscale(image);
}

img.Image _applyVintage(img.Image image) {
  final adjusted = img.adjustColor(image, saturation: 0.8);
  for (var y = 0; y < adjusted.height; y++) {
    for (var x = 0; x < adjusted.width; x++) {
      final pixel = adjusted.getPixel(x, y);
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;
      final newR = ((r * 0.393) + (g * 0.769) + (b * 0.189))
          .clamp(0, 255)
          .toInt();
      final newG = ((r * 0.349) + (g * 0.686) + (b * 0.168))
          .clamp(0, 255)
          .toInt();
      final newB = ((r * 0.272) + (g * 0.534) + (b * 0.131))
          .clamp(0, 255)
          .toInt();
      adjusted.setPixelRgba(x, y, newR, newG, newB, pixel.a.toInt());
    }
  }
  return adjusted;
}

img.Image _applyGlamour(img.Image image) {
  return img.adjustColor(
    image,
    saturation: 1.5,
    contrast: 1.1,
    brightness: 1.05,
  );
}

img.Image _applyLavender(img.Image image) {
  final adjusted = img.adjustColor(image, saturation: 0.9);
  for (var y = 0; y < adjusted.height; y++) {
    for (var x = 0; x < adjusted.width; x++) {
      final pixel = adjusted.getPixel(x, y);
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;
      final newR = (r * 1.05).clamp(0, 255).toInt();
      final newG = (g * 0.95).clamp(0, 255).toInt();
      final newB = (b * 1.1).clamp(0, 255).toInt();
      adjusted.setPixelRgba(x, y, newR, newG, newB, pixel.a.toInt());
    }
  }
  return adjusted;
}

img.Image _applyMoonlight(img.Image image) {
  final adjusted = img.adjustColor(image, saturation: 0.7, brightness: 1.08);
  for (var y = 0; y < adjusted.height; y++) {
    for (var x = 0; x < adjusted.width; x++) {
      final pixel = adjusted.getPixel(x, y);
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;
      final newR = (r * 0.95).clamp(0, 255).toInt();
      final newG = (g * 0.98).clamp(0, 255).toInt();
      final newB = (b * 1.08).clamp(0, 255).toInt();
      adjusted.setPixelRgba(x, y, newR, newG, newB, pixel.a.toInt());
    }
  }
  return adjusted;
}

img.Image _applyWarmMemory(img.Image image) {
  final adjusted = img.adjustColor(image, saturation: 0.85, brightness: 1.05);
  for (var y = 0; y < adjusted.height; y++) {
    for (var x = 0; x < adjusted.width; x++) {
      final pixel = adjusted.getPixel(x, y);
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;
      final newR = (r * 1.1).clamp(0, 255).toInt();
      final newG = (g * 1.05).clamp(0, 255).toInt();
      final newB = (b * 0.9).clamp(0, 255).toInt();
      adjusted.setPixelRgba(x, y, newR, newG, newB, pixel.a.toInt());
    }
  }
  return adjusted;
}

class ImageFilterHelper {
  static Future<File?> applyFilter({
    required File imageFile,
    required String filterName,
  }) async {
    try {
      final tempDir = imageFile.parent;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${tempDir.path}/temp_filter_$timestamp.jpg';
      final params = _FilterParams(
        imagePath: imageFile.path,
        filterName: filterName,
        outputPath: outputPath,
      );
      final success = await compute(_applyFilterInIsolate, params);
      if (success && await File(outputPath).exists()) {
        return File(outputPath);
      }
      return null;
    } catch (e) {
      print('Error applying filter: $e');
      return null;
    }
  }

  static Future<File?> generateThumbnail({
    required File imageFile,
    required String filterName,
    int size = 150,
  }) async {
    try {
      final tempDir = imageFile.parent;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath =
          '${tempDir.path}/thumb_${filterName.replaceAll(' ', '_')}_$timestamp.jpg';
      final params = _FilterParams(
        imagePath: imageFile.path,
        filterName: filterName,
        outputPath: outputPath,
        thumbnailSize: size,
      );
      final success = await compute(_applyFilterInIsolate, params);
      if (success && await File(outputPath).exists()) {
        return File(outputPath);
      }
      return null;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  static List<Map<String, dynamic>> getFilterList() {
    return [
      {'name': 'None', 'displayName': 'None'},
      {'name': 'Rose Twilight', 'displayName': 'Rose Twilight'},
      {'name': 'Cherry Dream', 'displayName': 'Cherry Dream'},
      {'name': 'Pure B&W', 'displayName': 'Pure B&W'},
      {'name': 'Vintage', 'displayName': 'Vintage'},
      {'name': 'Glamour', 'displayName': 'Glamour'},
      {'name': 'Lavender', 'displayName': 'Lavender'},
      {'name': 'Moonlight', 'displayName': 'Moonlight'},
      {'name': 'Warm Memory', 'displayName': 'Warm Memory'},
    ];
  }
}
