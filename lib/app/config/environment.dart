import 'package:yoloapp/app/config/environment_base.dart';
import 'package:yoloapp/app/config/environment_dev.dart' as env_dev;
import 'package:yoloapp/app/config/environment_prod.dart' as env_prod;
import 'package:yoloapp/app/config/environment_uat.dart' as env_uat;
import 'package:yoloapp/flavors.dart';

Future<EnvironmentBase> updateRemoteConfig(EnvironmentBase config) async {
  // Firebase Remote Config cố tình không được kích hoạt trong bản bootstrap này.
  return config;
}

Future<EnvironmentBase> getEnvironment() async {
  late final EnvironmentBase config;

  switch (F.name.toLowerCase()) {
    case 'dev':
      config = env_dev.Environment();
      break;
    case 'uat':
      config = env_uat.Environment();
      break;
    case 'prod':
      config = env_prod.Environment();
      break;
    default:
      config = env_dev.Environment();
      break;
  }

  return updateRemoteConfig(config);
}
