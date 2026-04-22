import 'package:yoloapp/app/config/configurations.dart';

/// Lớp cơ sở định kiểu mỏng cho các tệp môi trường cụ thể theo flavor.
class EnvironmentBase extends EnvironmentConfig {
  const EnvironmentBase({
    required super.appName,
    required super.flavorName,
    required super.androidApplicationId,
    required super.iosBundleId,
    required super.defaultOfficialModelId,
    required super.supportNote,
    required super.docsNote,
    super.preferGpu,
  });
}
