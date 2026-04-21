# Dependency And Tooling Stack

Use this reference to bootstrap a new project from the sample without blindly copying every feature-specific package from the sample `pubspec.yaml`.

## Minimum Baseline Dependencies

Use this baseline for a brand-new project. Add feature packages later only when the project actually needs them.

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  get: ^4.7.3
  logger: ^2.7.0
  serp_core_modules:
    hosted: https://pub.bkholding.vn/
    version: ^15.4.6
  serp_ui_package:
    hosted: https://pub.bkholding.vn/
    version: ^11.5.2
  serp_debug_overlay:
    hosted: https://pub.bkholding.vn/
    version: ^12.0.3
  serp_master_app_module:
    hosted: https://pub.bkholding.vn/
    version: ^8.7.8
  serp_notification_service:
    hosted: https://pub.bkholding.vn/
    version: ^11.0.2
  font_awesome_flutter:
    hosted: https://pub.bkholding.vn/
    version: ^10.7.1
  serp_auth_service:
    hosted: https://pub.bkholding.vn/
    version: ^11.0.0
  lucide_icons_flutter: ^3.1.12
  animated_bottom_navigation_bar:
    git:
      url: https://github.com/TijnvandenEijnde/animated-bottom-navigation-bar-flutter.git
      ref: 876392cd06afbaf1f777a6428fb0ed7823d0a967
  dio: ^5.9.2
  intl: ^0.20.2
  toastification: ^3.0.3
  google_fonts: ^8.0.2
```

If the team uses local package overrides during development, add them as commented `path:` alternatives rather than replacing the hosted baseline by default.

## Optional Feature Packages

Add these only when the new project needs the related capability:

```yaml

# Rarely needed for a fresh bootstrap
  firebase_core: ^4.5.0
```

Do not add optional packages "just in case". Start lean and add them when the feature set requires them.

## Dev Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  flutter_flavorizr: ^2.4.2
  flutter_launcher_icons: ^0.14.4
  fake_async: ^1.3.3
```

## Flutter Assets And Generation

```yaml
flutter:
  assets:
    - assets/logo/
    - assets/images/
    - assets/rive/
    - assets/lotties/
    - assets/ca/

  uses-material-design: true

```

For a new project, keep only the folders you actually use. Do not copy all sample asset folders by default.

## Flavorizr Block

Use the same three-flavor pattern, but parameterize names and IDs:

```yaml
flavorizr:
  flavors:
    dev:
      app:
        name: <display_name_dev>
        icon: assets/logo/logo.png
      android:
        applicationId: <android_application_id>
      ios:
        bundleId: <ios_bundle_id>
      macos:
        bundleId: <macos_bundle_id>

    uat:
      app:
        name: <display_name_uat>
        icon: assets/logo/logo.png
      android:
        applicationId: <android_application_id>
      ios:
        bundleId: <ios_bundle_id>
      macos:
        bundleId: <macos_bundle_id>

    prod:
      app:
        name: <display_name_prod>
        icon: assets/logo/logo.png
      android:
        applicationId: <android_application_id>
      ios:
        bundleId: <ios_bundle_id>
      macos:
        bundleId: <macos_bundle_id>
```

## Secret Exclusions

```yaml
false_secrets:
  - /**/google-services.json
  - /**/GoogleService-Info.plist
  - /**/service_account.json
  - /**/firebase_options.dart
```

## Launcher Icons

```yaml
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  remove_alpha_ios: true
  image_path: "assets/logo/logo.png"
  adaptive_icon_background: "#ffffff"
  adaptive_icon_foreground: "assets/logo/logo.png"
  min_sdk_android: 24
```

Use the provided brand logo if available. If not, leave a clear TODO for the correct asset path.
