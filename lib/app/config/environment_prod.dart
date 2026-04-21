import 'package:yoloapp/app/config/environment_base.dart';

class Environment extends EnvironmentBase {
  Environment()
    : super(
        appName: 'YoloApp',
        flavorName: 'prod',
        androidApplicationId: 'com.bachkhoa.yoloapp',
        iosBundleId: 'com.bachkhoa.yoloapp',
        defaultOfficialModelId: 'yolo26n',
        supportNote:
            'Bản production cần xác minh lại giấy phép AGPL của package trước khi phát hành thương mại.',
        docsNote:
            'Model detect chạy ổn định nhất cho luồng camera trực tiếp. Các task khác có thể chuyển qua dropdown task.',
      );
}
