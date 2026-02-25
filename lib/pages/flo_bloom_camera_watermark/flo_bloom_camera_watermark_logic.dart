import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as filePath;
import 'package:path_provider/path_provider.dart';
import '../../db_flo_bloom/data.dart';
import '../../db_flo_bloom/db_flo_bloom_entity.dart';
import '../../utils/index.dart';

class FloBloomCameraWatermarkLogic extends GetxController {
  final _db = FloBloomDatabase();
  final previewKey = GlobalKey();
  CameraController? cameraController;
  var isInitialized = false.obs;
  var isCaptured = false.obs;
  var isCapturing = false.obs;
  Rx<File?> capturedFile = Rx<File?>(null);
  var photoTime = DateTime.now().obs;
  var formattedTime = ''.obs;
  var address = '--'.obs;
  var coordText = '--N --E'.obs;
  var isLoadingLocation = false.obs;
  var watermarkOffset = Offset.zero.obs;
  final isProcessing = false.obs;
  Timer? _clockTimer;
  @override
  void onInit() {
    super.onInit();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _updateFormattedTime();
    _startClockTimer();
    _initCamera();
    _fetchLocation();
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    cameraController?.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.onClose();
  }

  void _startClockTimer() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isCaptured.value) {
        photoTime.value = DateTime.now();
        _updateFormattedTime();
      }
    });
  }

  void _updateFormattedTime() {
    final now = photoTime.value;
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final weekday = weekdays[now.weekday - 1];
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    formattedTime.value =
        '${now.year}/${now.month}/${now.day} $h:$m:$s ($weekday)';
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorToast('No camera available');
        Get.back();
        return;
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await cameraController!.initialize();
      isInitialized.value = true;
    } catch (e) {
      debugPrint('Camera init error: $e');
      errorToast('Failed to initialize camera');
      Get.back();
    }
  }

  Future<void> _fetchLocation() async {
    try {
      isLoadingLocation.value = true;
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final lat = position.latitude;
      final lng = position.longitude;
      final latStr = '${lat.abs().toStringAsFixed(2)}°${lat >= 0 ? 'N' : 'S'}';
      final lngStr = '${lng.abs().toStringAsFixed(2)}°${lng >= 0 ? 'E' : 'W'}';
      coordText.value = '$latStr $lngStr';
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = <String>[
            if (place.locality != null && place.locality!.isNotEmpty)
              place.locality!,
            if (place.administrativeArea != null &&
                place.administrativeArea!.isNotEmpty)
              place.administrativeArea!,
            if (place.country != null && place.country!.isNotEmpty)
              place.country!,
          ];
          address.value = parts.isNotEmpty ? parts.join(', ') : '--';
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('Location error: $e');
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> onCaptureTap() async {
    if (cameraController == null ||
        !cameraController!.value.isInitialized ||
        isCapturing.value)
      return;
    try {
      isCapturing.value = true;
      _clockTimer?.cancel();
      photoTime.value = DateTime.now();
      _updateFormattedTime();
      final xFile = await cameraController!.takePicture();
      capturedFile.value = File(xFile.path);
      isCaptured.value = true;
    } catch (e) {
      debugPrint('Capture error: $e');
      errorToast('Failed to capture photo');
      _startClockTimer();
    } finally {
      isCapturing.value = false;
    }
  }

  void onRetakeTap() {
    capturedFile.value = null;
    isCaptured.value = false;
    watermarkOffset.value = Offset.zero;
    _startClockTimer();
  }

  void onWatermarkDragUpdate(DragUpdateDetails details) {
    final current = watermarkOffset.value;
    watermarkOffset.value = Offset(
      current.dx + details.delta.dx,
      current.dy + details.delta.dy,
    );
  }

  Future<void> onBackTap() async {
    if (isCaptured.value) {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('Do you want to save this photo before leaving?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (result == true) {
        await onSaveTap();
      } else if (result == false) {
        Get.back();
      }
    } else {
      Get.back();
    }
  }

  Future<void> onSaveTap() async {
    if (capturedFile.value == null) {
      errorToast('No photo to save');
      return;
    }
    if (isProcessing.value) return;
    try {
      isProcessing.value = true;
      await Future.delayed(const Duration(milliseconds: 80));
      final context = previewKey.currentContext;
      if (context == null || !context.mounted) {
        errorToast('Failed to capture image');
        return;
      }
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        errorToast('Failed to capture image');
        return;
      }
      final uiImage = await renderObject.toImage(pixelRatio: 2.0);
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      uiImage.dispose();
      if (byteData == null) {
        errorToast('Failed to encode image');
        return;
      }
      final pngBytes = byteData.buffer.asUint8List();
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savePath = filePath.join(
        appDir.path,
        'flo_bloom_watermark_$timestamp.png',
      );
      final savedFile = File(savePath);
      await savedFile.writeAsBytes(pngBytes);
      await _saveToDatabase(savedFile);
      successToast('Image saved successfully');
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back(result: savedFile.path);
    } catch (e) {
      debugPrint('Save error: $e');
      errorToast('Failed to save: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _saveToDatabase(File savedFile) async {
    try {
      final bytes = await savedFile.readAsBytes();
      final image = img.decodeImage(bytes);
      final fileSize = await savedFile.length();
      await _db.insertRecord(
        FloBloomRecord(
          filePath: savedFile.path,
          originalPath: capturedFile.value!.path,
          createTime: DateTime.now().millisecondsSinceEpoch,
          fileSize: fileSize.toInt(),
          resolution: image != null ? '${image.width}x${image.height}' : '0x0',
          isAnimated: 0,
          hasBeauty: 0,
          hasCrop: 0,
          hasFrame: 0,
          hasWatermark: 1,
        ),
      );
    } catch (e) {
      debugPrint('Failed to save record: $e');
    }
  }
}
