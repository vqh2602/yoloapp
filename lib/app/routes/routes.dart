import 'package:get/get.dart';
import 'package:yoloapp/features/yolo_lab/yolo_lab_binding.dart';
import 'package:yoloapp/features/yolo_lab/yolo_lab_page.dart';

class AppPages {
  static const String initialRoute = YoloLabPage.routeName;
}

List<GetPage> routes = [
  GetPage(
    name: YoloLabPage.routeName,
    page: () => const YoloLabPage(),
    binding: YoloLabBinding(),
  ),
];
