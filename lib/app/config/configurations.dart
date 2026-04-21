/// Global access point for the active environment configuration.
class Env {
  static late EnvironmentConfig config;

  static void register(EnvironmentConfig value) {
    config = value;
  }
}

/// Shared app configuration used by all flavors.
class EnvironmentConfig {
  const EnvironmentConfig({
    required this.appName,
    required this.flavorName,
    required this.androidApplicationId,
    required this.iosBundleId,
    required this.defaultOfficialModelId,
    required this.supportNote,
    required this.docsNote,
    this.preferGpu = true,
  });

  final String appName;
  final String flavorName;
  final String androidApplicationId;
  final String iosBundleId;
  final String defaultOfficialModelId;
  final String supportNote;
  final String docsNote;
  final bool preferGpu;
}
