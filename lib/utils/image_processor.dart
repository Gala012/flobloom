import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageProcessor {
  static Future<Map<String, dynamic>?> getImageInfo(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      final fileSize = await imageFile.length();
      return {
        'width': image.width,
        'height': image.height,
        'sizeKB': fileSize / 1024,
      };
    } catch (e) {
      print('Error getting image info: $e');
      return null;
    }
  }

  static Future<File?> cropImage({
    required File imageFile,
    required int x,
    required int y,
    required int width,
    required int height,
    int quality = 90,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) return null;
      final cropX = x.clamp(0, originalImage.width - 1);
      final cropY = y.clamp(0, originalImage.height - 1);
      final cropWidth = width.clamp(1, originalImage.width - cropX);
      final cropHeight = height.clamp(1, originalImage.height - cropY);
      final croppedImage = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempPath = path.join(tempDir.path, 'temp_crop_$timestamp.jpg');
      final encodedImage = img.encodeJpg(croppedImage, quality: quality);
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(encodedImage);
      return tempFile;
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  static Future<File?> rotateImage({
    required File imageFile,
    required int angle,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) return null;
      img.Image rotatedImage;
      switch (angle) {
        case 90:
          rotatedImage = img.copyRotate(originalImage, angle: 90);
          break;
        case 180:
          rotatedImage = img.copyRotate(originalImage, angle: 180);
          break;
        case 270:
          rotatedImage = img.copyRotate(originalImage, angle: 270);
          break;
        default:
          rotatedImage = originalImage;
      }
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempPath = path.join(tempDir.path, 'temp_rotate_$timestamp.jpg');
      final encodedImage = img.encodeJpg(rotatedImage, quality: 90);
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(encodedImage);
      return tempFile;
    } catch (e) {
      print('Error rotating image: $e');
      return null;
    }
  }

  static Future<File?> flipImage({
    required File imageFile,
    required bool horizontal,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) return null;
      final flippedImage = horizontal
          ? img.flipHorizontal(originalImage)
          : img.flipVertical(originalImage);
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempPath = path.join(tempDir.path, 'temp_flip_$timestamp.jpg');
      final encodedImage = img.encodeJpg(flippedImage, quality: 90);
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(encodedImage);
      return tempFile;
    } catch (e) {
      print('Error flipping image: $e');
      return null;
    }
  }

  static Future<File?> saveImage({
    required File imageFile,
    required int width,
    required int height,
    required String extension,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'flo_bloom_$timestamp.$extension';
      final savePath = path.join(appDir.path, fileName);
      Uint8List encodedImage;
      if (extension.toLowerCase() == 'png') {
        encodedImage = Uint8List.fromList(img.encodePng(image));
      } else {
        encodedImage = Uint8List.fromList(img.encodeJpg(image, quality: 90));
      }
      final savedFile = File(savePath);
      await savedFile.writeAsBytes(encodedImage);
      return savedFile;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  static Future<Uint8List?> generateThumbnail({
    required File imageFile,
    int maxSize = 200,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      final thumbnail = img.copyResize(
        image,
        width: image.width > image.height ? maxSize : null,
        height: image.height >= image.width ? maxSize : null,
      );
      return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 80));
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }
}
