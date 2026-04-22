import 'package:get/get.dart';
import 'package:yoloapp/features/intro/intro_video_page.dart';
import 'package:yoloapp/features/yolo_lab/yolo_lab_binding.dart';
import 'package:yoloapp/features/yolo_lab/yolo_lab_screen.dart';

class AppPages {
  static const String initialRoute = IntroVideoPage.routeName;
}

List<GetPage> routes = [
  GetPage(
    name: IntroVideoPage.routeName,
    page: () => const IntroVideoPage(),
  ),
  GetPage(
    name: YoloLabPage.routeName,
    page: () => const YoloLabPage(),
    binding: YoloLabBinding(),
  ),
];
