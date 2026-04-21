import 'package:yoloapp/app/config/environment_base.dart';

class Environment extends EnvironmentBase {
  Environment()
    : super(
        appName: 'YoloApp Dev',
        flavorName: 'dev',
        androidApplicationId: 'com.bachkhoa.yoloapp',
        iosBundleId: 'com.bachkhoa.yoloapp',
        defaultOfficialModelId: 'yolo26n',
        supportNote: 'Bản dev dùng để thử model chính thức hoặc model từ tệp.',
        docsNote:
            'Ưu tiên model detect khi thử camera live. Model custom nên kèm metadata để package tự suy ra task.',
      );
}
