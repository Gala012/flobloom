import 'package:get/get.dart';
import '../../utils/image_picker_helper.dart';
import '../../utils/index.dart';
import '../../db_flo_bloom/data.dart';
import '../../db_flo_bloom/db_flo_bloom_entity.dart';

class FloBloomHomeLogic extends GetxController {
  final _db = FloBloomDatabase();
  var inspirationRecords = <FloBloomRecord>[].obs;
  @override
  void onInit() {
    super.onInit();
    loadInspirationRecords();
  }

  Future<void> loadInspirationRecords() async {
    try {
      final allRecords = await _db.getAllRecords();
      inspirationRecords.value = allRecords.take(3).toList();
    } catch (e) {
      print('Failed to load inspiration records: $e');
    }
  }

  void onInspirationTap(int recordId) {
    Get.toNamed(
      '/flo_bloom_history_detail',
      arguments: recordId,
    )?.then((_) => loadInspirationRecords());
  }

  Future<void> refresh() async {
    await loadInspirationRecords();
  }

  Future<void> onPhotoFilterTap() async {
    try {
      final imageFile = await ImagePickerHelper.pickImage();
      if (imageFile != null) {
        Get.toNamed(
          '/flo_bloom_filter_editor',
          arguments: imageFile.path,
        )?.then((_) => loadInspirationRecords());
      }
    } catch (e) {
      errorToast('Failed to pick image: $e');
    }
  }

  Future<void> onFrameTap() async {
    try {
      final imageFile = await ImagePickerHelper.pickImage();
      if (imageFile != null) {
        Get.toNamed(
          '/flo_bloom_frame_editor',
          arguments: imageFile.path,
        )?.then((_) => loadInspirationRecords());
      }
    } catch (e) {
      errorToast('Failed to pick image: $e');
    }
  }

  Future<void> onStickerTap() async {
    try {
      final imageFile = await ImagePickerHelper.pickImage();
      if (imageFile != null) {
        Get.toNamed(
          '/flo_bloom_sticker_editor',
          arguments: imageFile.path,
        )?.then((_) => loadInspirationRecords());
      }
    } catch (e) {
      errorToast('Failed to pick image: $e');
    }
  }

  Future<void> onBeautyTap() async {
    try {
      final imageFile = await ImagePickerHelper.pickImage();
      if (imageFile != null) {
        Get.toNamed(
          '/flo_bloom_beauty_editor',
          arguments: imageFile.path,
        )?.then((_) => loadInspirationRecords());
      }
    } catch (e) {
      errorToast('Failed to pick image: $e');
    }
  }

  Future<void> onCropTap() async {
    try {
      final imageFile = await ImagePickerHelper.pickImage();
      if (imageFile != null) {
        Get.toNamed(
          '/flo_bloom_crop_editor',
          arguments: imageFile.path,
        )?.then((_) => loadInspirationRecords());
      }
    } catch (e) {
      errorToast('Failed to pick image: $e');
    }
  }

  Future<void> onEffectTap() async {
    try {
      final imageFile = await ImagePickerHelper.pickImage();
      if (imageFile != null) {
        Get.toNamed(
          '/flo_bloom_effect_editor',
          arguments: imageFile.path,
        )?.then((_) => loadInspirationRecords());
      }
    } catch (e) {
      errorToast('Failed to pick image: $e');
    }
  }

  void onCameraTap() {
    try {
      Get.toNamed(
        '/flo_bloom_camera_watermark',
      )?.then((_) => loadInspirationRecords());
    } catch (e) {
      errorToast('Failed to open camera: $e');
    }
  }
}
