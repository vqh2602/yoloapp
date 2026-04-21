# Marineradar Module Patterns

Use this reference when generating or reviewing a new module in the Marineradar app. Keep examples portable so the skill can be copied to another machine without depending on local file lists.

## Standard Module Folder

Default layout:

```text
lib/app/modules/<module>/
├── <module>_binding.dart
├── <module>_controller.dart
├── <module>_screen.dart
├── <module>_screen_mobile.dart
└── widgets/
```

## Route Registration

The app uses `GetPage` entries in `lib/routes/routes.dart`.

Required additions:

- `import 'package:<package_name>/app/modules/<module>/<module>_binding.dart';`
- `import 'package:<package_name>/app/modules/<module>/<module>_screen.dart';`
- `GetPage(name: <Screen>.routeName, page: () => const <Screen>(), binding: <Binding>()),`

Resolve `<package_name>` from the `name:` field in `pubspec.yaml`.

Portable example:

```dart
GetPage(
  name: ExampleScreen.routeName,
  page: () => const ExampleScreen(),
  binding: ExampleBinding(),
),
```

## Common Screen Styles

### Responsive wrapper

Use for modules that wrap a mobile widget with `ResponsiveLayout`.

Portable example:

```dart
class ExampleScreen extends StatefulWidget {
  static String routeName =
      '${Env.config.APP_CONFIG.PREFIX_MODULE}/example-screen';

  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileResponsive: ExampleScreenMobile(),
      tabletResponsive: ExampleScreenMobile(),
      desktopResponsive: ExampleScreenMobile(),
    );
  }
}
```

Characteristics:

- `StatefulWidget`
- `routeName` usually uses `Env.config.APP_CONFIG.PREFIX_MODULE`
- `ResponsiveLayout` delegates to `<module>_screen_mobile.dart`

### SBase wrapper

Use for simpler modules that directly delegate to the mobile screen.

Portable example:

```dart
class ExampleScreen extends SBaseScreen {
  static const String routeName = '/example-screen';

  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends BaseState<ExampleScreen> {
  @override
  Widget build(BuildContext context) {
    return const ExampleScreenMobile();
  }
}
```

Characteristics:

- `SBaseScreen`
- `routeName` may be a fixed string
- Screen returns `const <module>_screen_mobile()`

## Controller Pattern

Minimum controller shape:

- Extend `GetxController`
- Mix in `StateMixin`
- Set an initial success state in `onInit`
- Keep async loading methods explicit

Portable example:

```dart
class ExampleController extends GetxController with StateMixin {
  @override
  Future<void> onInit() async {
    await loadInitialData();
    super.onInit();
  }

  Future<void> loadInitialData() async {
    change(null, status: RxStatus.loading());
    await Future<void>.delayed(Duration.zero);
    change(null, status: RxStatus.success());
  }
}
```

## Binding Pattern

Use `Get.lazyPut` with `fenix: true`.

Portable example:

```dart
class ExampleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExampleController>(
      () => ExampleController(),
      fenix: true,
    );
  }
}
```

## Widget Placement

Use `lib/app/modules/<module>/widgets/` when:

- the widget is only used by that module
- the widget depends tightly on that module's controller or models

Use `lib/app/widgets/` when:

- the widget can be reused by other modules
- the widget is a generic app-level component

## Review Checklist

- Module folder name is snake_case
- Route import and `GetPage` entry were added once
- Placeholder text was replaced before final delivery
- Large UI blocks were moved out of `screen_mobile.dart`
