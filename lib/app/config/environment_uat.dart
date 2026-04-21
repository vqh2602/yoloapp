import 'package:yoloapp/app/config/environment_base.dart';

class Environment extends EnvironmentBase {
  Environment()
    : super(
        appName: 'YoloApp UAT',
        flavorName: 'uat',
        androidApplicationId: 'com.bachkhoa.yoloapp',
        iosBundleId: 'com.bachkhoa.yoloapp',
        defaultOfficialModelId: 'yolo26n',
        supportNote: 'Bản UAT dành cho kiểm thử người dùng nội bộ.',
        docsNote:
            'Hãy xác minh định dạng model theo nền tảng: Android dùng .tflite, iOS dùng CoreML export phù hợp.',
      );
}
