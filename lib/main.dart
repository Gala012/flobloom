import 'package:flo_bloom/pages/flo_bloom_cloud/flo_bloom_cloud_binding.dart';
import 'package:flo_bloom/pages/flo_bloom_cloud/flo_bloom_cloud_view.dart';
import 'package:flo_bloom/pages/flo_bloom_effect_editor/flo_bloom_effect_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../pages/flo_bloom_tab/flo_bloom_tab_binding.dart';
import '../pages/flo_bloom_tab/flo_bloom_tab_view.dart';
import '../pages/flo_bloom_onboarding_1/flo_bloom_onboarding_1_binding.dart';
import '../pages/flo_bloom_onboarding_1/flo_bloom_onboarding_1_view.dart';
import '../pages/flo_bloom_onboarding_2/flo_bloom_onboarding_2_binding.dart';
import '../pages/flo_bloom_onboarding_2/flo_bloom_onboarding_2_view.dart';
import '../pages/flo_bloom_onboarding_3/flo_bloom_onboarding_3_binding.dart';
import '../pages/flo_bloom_onboarding_3/flo_bloom_onboarding_3_view.dart';
import '../pages/flo_bloom_filter_editor/flo_bloom_filter_editor_binding.dart';
import '../pages/flo_bloom_filter_editor/flo_bloom_filter_editor_view.dart';
import '../pages/flo_bloom_beauty_editor/flo_bloom_beauty_editor_binding.dart';
import '../pages/flo_bloom_beauty_editor/flo_bloom_beauty_editor_view.dart';
import '../pages/flo_bloom_sticker_editor/flo_bloom_sticker_editor_binding.dart';
import '../pages/flo_bloom_sticker_editor/flo_bloom_sticker_editor_view.dart';
import '../pages/flo_bloom_frame_editor/flo_bloom_frame_editor_binding.dart';
import '../pages/flo_bloom_frame_editor/flo_bloom_frame_editor_view.dart';
import '../pages/flo_bloom_crop_editor/flo_bloom_crop_editor_binding.dart';
import '../pages/flo_bloom_crop_editor/flo_bloom_crop_editor_view.dart';
import '../pages/flo_bloom_camera_watermark/flo_bloom_camera_watermark_binding.dart';
import '../pages/flo_bloom_camera_watermark/flo_bloom_camera_watermark_view.dart';
import '../pages/flo_bloom_effect_editor/flo_bloom_effect_editor_binding.dart';
import '../pages/flo_bloom_effect_editor/flo_bloom_effect_editor_view.dart';
import '../pages/flo_bloom_history_detail/flo_bloom_history_detail_binding.dart';
import '../pages/flo_bloom_history_detail/flo_bloom_history_detail_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'utils/colors.dart';

Color primaryColor = FloBloomColors.primaryDeep;
Color bgColor = FloBloomColors.background;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          getPages: Flo,
          initialRoute: '/',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: bgColor,
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              surface: Color(0xFFFFFFFF),
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0F0F0F),
              ),
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(size: 22, color: Color(0xFF0F0F0F)),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: Color(0xFFC9743B),
              unselectedItemColor: Color(0xFF292929),
              elevation: 0,
              backgroundColor: Color(0xFFFFFFFF),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            dividerTheme: DividerThemeData(
              thickness: 1,
              color: Colors.grey[200],
            ),
          ),
        );
      },
    );
  }
}
List<GetPage<dynamic>> Flo = [
  GetPage(
    name: '/',
    page: () => const FloBloomCloudView(),
    binding: FloBloomCloudBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flo_bloom_tab',
    page: () => const FloBloomTabView(),
    binding: FloBloomTabBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flo_bloom_onboarding_1',
    page: () => const FloBloomOnboarding1View(),
    binding: FloBloomOnboarding1Binding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flo_bloom_onboarding_2',
    page: () => const FloBloomOnboarding2View(),
    binding: FloBloomOnboarding2Binding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flo_bloom_onboarding_3',
    page: () => const FloBloomOnboarding3View(),
    binding: FloBloomOnboarding3Binding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flo_bloom_effect_data',
    page: () => const FloBloomEffectData(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flo_bloom_filter_editor',
    page: () => const FloBloomFilterEditorView(),
    binding: FloBloomFilterEditorBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flo_bloom_beauty_editor',
    page: () => const FloBloomBeautyEditorView(),
    binding: FloBloomBeautyEditorBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flo_bloom_sticker_editor',
    page: () => const FloBloomStickerEditorView(),
    binding: FloBloomStickerEditorBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flo_bloom_frame_editor',
    page: () => const FloBloomFrameEditorView(),
    binding: FloBloomFrameEditorBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flo_bloom_crop_editor',
    page: () => const FloBloomCropEditorView(),
    binding: FloBloomCropEditorBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flo_bloom_camera_watermark',
    page: () => const FloBloomCameraWatermarkView(),
    binding: FloBloomCameraWatermarkBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flo_bloom_effect_editor',
    page: () => const FloBloomEffectEditorView(),
    binding: FloBloomEffectEditorBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flo_bloom_history_detail',
    page: () => const FloBloomHistoryDetailView(),
    binding: FloBloomHistoryDetailBinding(),
    transition: Transition.cupertino,
    popGesture: true,
    preventDuplicates: false,
  ),
];