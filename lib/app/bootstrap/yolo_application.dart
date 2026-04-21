import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:yoloapp/app/config/configurations.dart';
import 'package:yoloapp/app/routes/routes.dart';
import 'package:yoloapp/app/translations/app_translations.dart';
import 'package:yoloapp/shared/theme/app_theme.dart';

/// Root application widget.
///
/// The project follows a Serp-style structure, so top-level app composition
/// stays inside `lib/app/` while features live in `lib/features/`.
class YoloApplication extends StatelessWidget {
  const YoloApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Env.config.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      translations: AppTranslations(),
      locale: const Locale('vi', 'VN'),
      fallbackLocale: const Locale('en', 'US'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
      initialRoute: AppPages.initialRoute,
      getPages: routes,
    );
  }
}
