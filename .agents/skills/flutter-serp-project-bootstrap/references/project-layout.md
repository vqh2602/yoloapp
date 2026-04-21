# Project Layout

Use this reference to create the initial folder structure and bootstrapping files.

## Target Tree

```text
lib/
├── app/
│   ├── bootstrap/
│   │   └── <app_module>.dart
│   ├── config/
│   │   ├── configurations.dart
│   │   ├── environment.dart
│   │   ├── environment_base.dart
│   │   ├── environment_dev.dart
│   │   ├── environment_uat.dart
│   │   └── environment_prod.dart
│   ├── di/
│   │   └── locator.dart
│   ├── navigation/
│   │   └── widgets/
│   ├── routes/
│   │   └── routes.dart
│   └── translations/
├── core/
│   ├── constants/
│   ├── models/
│   ├── network/
│   ├── repositories/
│   ├── services/
│   └── utils/
├── features/
│   └── <feature_name>/
├── shared/
│   ├── controllers/
│   ├── helpers/
│   ├── mixins/
│   ├── theme/
│   └── widgets/
├── firebase_options.dart
├── flavors.dart
├── main.dart
├── main_dev.dart
├── main_uat.dart
└── main_prod.dart
```

## Flavor Enum

Create a portable flavor selector:

```dart
enum Flavor { dev, uat, prod }

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return '<display_name_dev>';
      case Flavor.uat:
        return '<display_name_uat>';
      case Flavor.prod:
        return '<display_name_prod>';
    }
  }
}
```

## Flavor Entrypoints

Match the sample pattern:

```dart
import 'main.dart' as base;
import 'flavors.dart';

void main() {
  F.appFlavor = Flavor.dev;
  base.main();
}
```

Repeat for `uat` and `prod`.

## Environment Resolution

Use one `environment.dart` selector that returns the right config based on `F.name`.

Expected responsibilities:

- read the active flavor
- instantiate `EnvironmentDev`, `EnvironmentUat`, or `EnvironmentProd`
- optionally apply remote overrides

## Config Files

Create these three files first because all environment classes depend on them.

### `lib/app/config/configurations.dart`

Purpose:

- expose a global `Env.config`
- define the app-specific module config
- extend the shared/base config coming from your platform package if the project has one
- add project-specific sub-config groups such as map keys, weather keys, or feature callbacks

Portable skeleton:

```dart
import 'package:flutter/material.dart';
import 'package:<package_name>/app/navigation/widgets/s_bottom_bar.dart';
import 'package:serp_master_app_module/configurations/configurations.dart'
    as master_app;

class Env {
  static ModuleConfig config = ModuleConfig();

  static Widget Function()? baseBackground = () => const SizedBox();

  static Widget Function({required void Function() reloadFunction})?
  shareUserProfile;

  static Widget Function({
    required String activeId,
    required TickerProvider ticker,
    bool isTranparent,
  })?
  baseBottomBar = sBottomBar;
}

class ModuleConfig extends master_app.ModuleConfig {
  SubApiConfig SUB_API_CONFIG = SubApiConfig(
    primaryApi: '',
  );
}

class SubApiConfig {
  String flavor;
  String remoteConfigKey;
  bool isSubModule;

  SubApiConfig({
    this.flavor = 'dev',
    this.remoteConfigKey = '',
    this.isSubModule = false,
  });
}
```

Guidance:

- rename `SubApiConfig` fields to match the project domain
- keep secrets and endpoints parameterized per environment file
- only add fields that the new project actually needs

### `lib/app/config/environment_base.dart`

Purpose:

- provide a typed base class for all environment files
- inherit from `ModuleConfig` so each concrete environment can assign `APP_CONFIG`, `API_SERVICE_CONFIG`, `UI_CONFIG`, `FEATURE_FLAGS_CONFIG`, and custom sub-config values

Portable skeleton:

```dart
import 'configurations.dart';

class EnvironmentBase extends ModuleConfig {}
```

Guidance:

- keep this file thin
- do not duplicate environment values here
- use it only as the common typed base for `environment_dev.dart`, `environment_uat.dart`, and `environment_prod.dart`

### `lib/app/config/environment.dart`

Purpose:

- choose the active environment from the current flavor
- optionally apply remote overrides after loading the base environment

Portable skeleton:

```dart
import 'package:<package_name>/flavors.dart';
import 'environment_base.dart';
import 'environment_dev.dart' as env_dev;
import 'environment_prod.dart' as env_prod;
import 'environment_uat.dart' as env_uat;

Future<EnvironmentBase> updateRemoteConfig(EnvironmentBase config) async {
  return config;
}

Future<EnvironmentBase> getEnvironment() async {
  EnvironmentBase config;

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

  return await updateRemoteConfig(config);
}
```

Guidance:

- keep flavor resolution centralized here
- if Remote Config is not used, keep `updateRemoteConfig` as a pass-through
- all code outside config loading should call `await getEnvironment()` instead of instantiating env classes directly

### `lib/app/config/environment_dev.dart`

Purpose:

- define the development environment values
- point to dev APIs, dev labels, dev feature flags, and debug-friendly integrations

Portable skeleton:

```dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:serp_master_app_module/app/data/models/configs/api_service_config.dart';
import 'package:serp_master_app_module/app/data/models/configs/app_config.dart';
import 'package:serp_master_app_module/app/data/models/configs/feature_flags_config.dart';
import 'package:serp_master_app_module/app/data/models/configs/functionality_config.dart';
import 'package:serp_master_app_module/app/data/models/configs/ui_config.dart';

import 'configurations.dart';
import 'environment_base.dart';

class Environment extends EnvironmentBase {
  Environment() {
    APP_CONFIG = AppConfig(
      APPLICATION_CODE: '<application_code>',
      PACKAGE: '<package_name>',
      FIXED_TOKEN: '<fixed_token_or_placeholder>',
      APPLICATION_ID: '<application_id>',
      BUNDLEID: '<bundle_id>',
    );

    API_SERVICE_CONFIG = ApiConfig(
      APPLICATION_SERVICE_API: '<dev_application_service_api>',
      AUTHENTICATION_SERVICE_API: '<dev_auth_api>',
      FILE_SERVICE_API: '<dev_file_api>',
      NOTIFICATION_SERVICE_API: '<dev_notification_api>',
      BASE_SERVICE_API: '<dev_base_api>',
      USER_SERVICE_API: '<dev_user_api>',
      FILE_STORAGE_URL: '<dev_file_storage_url>',
      DICTIONARY_SERVICE_API: '<dev_dictionary_api>',
      SUB_API_SERVICE_CONFIG: null,
      SSO_WSO2_CLIENT_ID: '',
      SSO_WSO2_AUTH_DOMAIN: '',
      SSO_WSO2_CLIENTSECRET: '',
      SSO_WSO2_AUTHCODEPARAMS: {'prompt': 'login'},
    );

    UI_CONFIG = UiConfig(
      LOGIN_TITLE: 'Đăng Nhập',
      SUB_UI_CONFIG: '<display_name_dev>',
      backgroundLoginV2: const SizedBox.shrink(),
    );

    FUNCTIONALITY_CONFIG = FunctionalityConfig(
      SLOGGER: Logger(),
      SUPPORT_URL: '<support_url>',
    );

    FEATURE_FLAGS_CONFIG = FeatureFlagsConfig(
      SHOW_LOGIN_UI: 'v2',
      REQUIRED_AUTH: true,
      IS_HIDDEN_BOTTOMBAR: true,
    );

    SUB_API_CONFIG = SubApiConfig(
      flavor: 'dev',
      remoteConfigKey: '<dev_remote_config_key>',
    );
  }
}
```

### `lib/app/config/environment_uat.dart`

Purpose:

- define the UAT environment values
- keep structure identical to `environment_dev.dart`, changing only values and UAT-specific hooks

Portable skeleton:

```dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:serp_master_app_module/app/data/models/configs/api_service_config.dart';
import 'package:serp_master_app_module/app/data/models/configs/app_config.dart';
import 'package:serp_master_app_module/app/data/models/configs/feature_flags_config.dart';
import 'package:serp_master_app_module/app/data/models/configs/functionality_config.dart';
import 'package:serp_master_app_module/app/data/models/configs/ui_config.dart';

import 'configurations.dart';
import 'environment_base.dart';

class Environment extends EnvironmentBase {
  Environment() {
    APP_CONFIG = AppConfig(
      APPLICATION_CODE: '<application_code>',
      PACKAGE: '<package_name>',
      FIXED_TOKEN: '<fixed_token_or_placeholder>',
      APPLICATION_ID: '<application_id>',
      BUNDLEID: '<bundle_id>',
    );

    API_SERVICE_CONFIG = ApiConfig(
      APPLICATION_SERVICE_API: '<uat_application_service_api>',
      AUTHENTICATION_SERVICE_API: '<uat_auth_api>',
      FILE_SERVICE_API: '<uat_file_api>',
      NOTIFICATION_SERVICE_API: '<uat_notification_api>',
      BASE_SERVICE_API: '<uat_base_api>',
      USER_SERVICE_API: '<uat_user_api>',
      FILE_STORAGE_URL: '<uat_file_storage_url>',
      DICTIONARY_SERVICE_API: '<uat_dictionary_api>',
      SUB_API_SERVICE_CONFIG: null,
      SSO_WSO2_CLIENT_ID: '',
      SSO_WSO2_AUTH_DOMAIN: '',
      SSO_WSO2_CLIENTSECRET: '',
      SSO_WSO2_AUTHCODEPARAMS: {'prompt': 'login'},
    );

    UI_CONFIG = UiConfig(
      LOGIN_TITLE: 'Đăng Nhập',
      SUB_UI_CONFIG: '<display_name_uat>',
      backgroundLoginV2: const SizedBox.shrink(),
    );

    FUNCTIONALITY_CONFIG = FunctionalityConfig(
      SLOGGER: Logger(),
      SUPPORT_URL: '<support_url>',
    );

    FEATURE_FLAGS_CONFIG = FeatureFlagsConfig(
      SHOW_LOGIN_UI: 'v2',
      REQUIRED_AUTH: true,
      IS_HIDDEN_BOTTOMBAR: true,
    );

    SUB_API_CONFIG = SubApiConfig(
      flavor: 'uat',
      remoteConfigKey: '<uat_remote_config_key>',
    );
  }
}
```

### `lib/app/config/environment_prod.dart`

Purpose:

- define the production environment values
- keep the same structure as dev/uat, but with production-safe flags and production endpoints

Portable skeleton:

```dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:serp_master_app_module/app/data/models/configs/api_service_config.dart';
import 'package:serp_master_app_module/app/data/models/configs/app_config.dart';
import 'package:serp_master_app_module/app/data/models/configs/feature_flags_config.dart';
import 'package:serp_master_app_module/app/data/models/configs/functionality_config.dart';
import 'package:serp_master_app_module/app/data/models/configs/ui_config.dart';

import 'configurations.dart';
import 'environment_base.dart';

class Environment extends EnvironmentBase {
  Environment() {
    APP_CONFIG = AppConfig(
      APPLICATION_CODE: '<application_code>',
      PACKAGE: '<package_name>',
      FIXED_TOKEN: '<fixed_token_or_placeholder>',
      APPLICATION_ID: '<application_id>',
      BUNDLEID: '<bundle_id>',
    );

    API_SERVICE_CONFIG = ApiConfig(
      APPLICATION_SERVICE_API: '<prod_application_service_api>',
      AUTHENTICATION_SERVICE_API: '<prod_auth_api>',
      FILE_SERVICE_API: '<prod_file_api>',
      NOTIFICATION_SERVICE_API: '<prod_notification_api>',
      BASE_SERVICE_API: '<prod_base_api>',
      USER_SERVICE_API: '<prod_user_api>',
      FILE_STORAGE_URL: '<prod_file_storage_url>',
      DICTIONARY_SERVICE_API: '<prod_dictionary_api>',
      SUB_API_SERVICE_CONFIG: null,
      SSO_WSO2_CLIENT_ID: '',
      SSO_WSO2_AUTH_DOMAIN: '',
      SSO_WSO2_CLIENTSECRET: '',
      SSO_WSO2_AUTHCODEPARAMS: {'prompt': 'login'},
    );

    UI_CONFIG = UiConfig(
      LOGIN_TITLE: 'Đăng Nhập',
      SUB_UI_CONFIG: '<display_name_prod>',
      backgroundLoginV2: const SizedBox.shrink(),
    );

    FUNCTIONALITY_CONFIG = FunctionalityConfig(
      SLOGGER: Logger(),
      SUPPORT_URL: '<support_url>',
    );

    FEATURE_FLAGS_CONFIG = FeatureFlagsConfig(
      SHOW_LOGIN_UI: 'v2',
      REQUIRED_AUTH: true,
      IS_HIDDEN_BOTTOMBAR: true,
    );

    SUB_API_CONFIG = SubApiConfig(
      flavor: 'prod',
      remoteConfigKey: '<prod_remote_config_key>',
    );
  }
}
```

Guidance for all three files:

- keep the class name the same: `Environment`
- keep file shape consistent across flavors
- only change values, flags, and environment-specific hooks
- do not let one flavor introduce a different structure unless that difference is required by platform or product behavior

## Main Responsibilities

`lib/main.dart` should own:

- `WidgetsFlutterBinding.ensureInitialized()`
- Firebase initialization when enabled
- environment loading
- module bootstrap
- route composition
- theme setup
- DI setup
- localization setup
- global error/logging hooks
- `runApp(...)`

Do not scatter app bootstrap logic across many unrelated files.

## Main Skeleton

Start from a real bootstrap skeleton, not an empty `runApp(MyApp())`.

Portable skeleton:

```dart
import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:<package_name>/app/bootstrap/<app_module>.dart';
import 'package:<package_name>/app/config/configurations.dart';
import 'package:<package_name>/app/config/environment.dart';
import 'package:<package_name>/app/di/locator.dart';
import 'package:<package_name>/app/routes/routes.dart';
import 'package:<package_name>/app/translations/en_us.dart';
import 'package:<package_name>/app/translations/vi_vn.dart';
import 'package:<package_name>/firebase_options.dart';
import 'package:<package_name>/shared/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

Future<List<GetPage>> mainAppModule() async {
  final appModule = AppModule();
  Env.config = await getEnvironment();
  await appModule.initialize();

  final routes = <GetPage>[];
  routes.addAll(appModule.getRoute((routeName) => null));
  return routes;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final finalRoutes = <GetPage>[];
  finalRoutes.addAll(await mainAppModule());

  Env.config.UI_CONFIG.lightTheme = AppTheme.lightTheme.copyWith(
    textTheme: kIsWeb
        ? AppTheme.lightTheme.textTheme
        : Platform.isMacOS || Platform.isWindows
        ? AppTheme.lightTheme.textTheme
        : GoogleFonts.notoSansTextTheme(AppTheme.lightTheme.textTheme),
  );

  Env.config.UI_CONFIG.darkTheme = AppTheme.darkTheme.copyWith(
    textTheme: kIsWeb
        ? AppTheme.darkTheme.textTheme
        : Platform.isMacOS || Platform.isWindows
        ? AppTheme.darkTheme.textTheme
        : GoogleFonts.notoSansTextTheme(AppTheme.darkTheme.textTheme),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await setupLocator();
  await initializeDateFormatting('vi', null);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (exception, stackTrace) {
    return false;
  };

  runApp(AppRoot(routes: finalRoutes));
}

class AppRoot extends StatelessWidget {
  final List<GetPage> routes;

  const AppRoot({super.key, required this.routes});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: routes,
      theme: Env.config.UI_CONFIG.lightTheme,
      darkTheme: Env.config.UI_CONFIG.darkTheme,
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      translations: LocalizationService(
        vi: vi,
        en: en,
      ),
      initialRoute: '<initial_route>',
    );
  }
}
```

Adapt this skeleton as needed:

- remove Firebase if the new app does not use it yet
- add route composition from multiple modules only if the app is modular
- add debug overlays, notification init, remote config, and shared package setup only when the project needs them
- keep the bootstrap flow centralized in `main.dart`

## Route Ownership

Keep app routes under `lib/app/routes/routes.dart`.

Each feature should still own its own bindings, screens, and route names. The app route table only aggregates them.
