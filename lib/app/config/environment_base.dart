import 'package:yoloapp/app/config/configurations.dart';

/// Thin typed base class for flavor-specific environment files.
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
