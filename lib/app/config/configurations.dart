/// Điểm truy cập toàn cục cho cấu hình môi trường hiện tại.
class Env {
  static late EnvironmentConfig config;

  static void register(EnvironmentConfig value) {
    config = value;
  }
}

/// Cấu hình ứng dụng dùng chung cho tất cả các flavor.
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
