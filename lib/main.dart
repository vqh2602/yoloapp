import 'package:flutter/widgets.dart';
import 'package:yoloapp/app/bootstrap/yolo_application.dart';
import 'package:yoloapp/app/config/configurations.dart';
import 'package:yoloapp/app/config/environment.dart';
import 'package:yoloapp/app/di/locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = await getEnvironment();
  Env.register(environment);
  await setupLocator();

  runApp(const YoloApplication());
}
