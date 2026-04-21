# Setup Sequence

Use this order to bootstrap a new project safely and keep it close to the sample.

## 1. Create The App Shell

Example:

```bash
flutter create <app_name>
cd <app_name>
```

If the team uses FVM, align Flutter first:

```bash
fvm use 3.41.6
fvm flutter --version
```

## 2. Create The Folder Structure

Before writing feature code, create:

- `lib/app/bootstrap`
- `lib/app/config`
- `lib/app/di`
- `lib/app/navigation/widgets`
- `lib/app/routes`
- `lib/app/translations`
- `lib/core/constants`
- `lib/core/models`
- `lib/core/network`
- `lib/core/repositories`
- `lib/core/services`
- `lib/core/utils`
- `lib/shared/controllers`
- `lib/shared/helpers`
- `lib/shared/mixins`
- `lib/shared/theme`
- `lib/shared/widgets`
- `lib/features`

## 3. Replace pubspec.yaml Baseline

Apply the dependency and tooling blocks from [dependency-stack.md](dependency-stack.md).

Then run:

```bash
flutter pub get
```

## 4. Add Flavor Files

Create:

- `lib/flavors.dart`
- `lib/main_dev.dart`
- `lib/main_uat.dart`
- `lib/main_prod.dart`

Keep each `main_<flavor>.dart` minimal and delegate to `base.main()`.

## 5. Add Environment Files

Create:

- `lib/app/config/configurations.dart`
- `lib/app/config/environment_base.dart`
- `lib/app/config/environment.dart`
- `lib/app/config/environment_dev.dart`
- `lib/app/config/environment_uat.dart`
- `lib/app/config/environment_prod.dart`

Create `configurations.dart`, `environment_base.dart`, and `environment.dart` first. Then add the flavor-specific environment files on top of that base.

Keep `environment_dev.dart`, `environment_uat.dart`, and `environment_prod.dart` structurally identical. Change values per environment, not file shape.

Parameterize:

- package name
- application code
- application ID
- bundle ID
- service base URLs
- flavor labels
- feature flags
- support URLs
- logging endpoints
- API keys

Never invent production secrets. Use placeholders when values are unknown.

## 6. Add Bootstrap, DI, And Routing

Create:

- `lib/app/bootstrap/<app_module>.dart`
- `lib/app/di/locator.dart`
- `lib/app/routes/routes.dart`

Wire them in `main.dart`, and start `main.dart` from the bootstrap skeleton in [project-layout.md](project-layout.md) instead of an empty starter file.

Use `GetX` for:

- route registration
- bindings
- shared dependency resolution

## 7. Generate Flavors

Mirror the sample flow:

```bash
flutter pub run flutter_flavorizr
```

After generation, verify the `main_<flavor>.dart` files still follow:

```dart
import 'main.dart' as base;
import 'flavors.dart';

void main() {
  F.appFlavor = Flavor.dev;
  base.main();
}
```

If flavorizr rewrites them differently, patch them back to the sample pattern.

## 8. Generate Launcher Icons

Make sure `assets/logo/logo.png` exists, then run:

```bash
flutter pub run flutter_launcher_icons
```

## 9. Configure Firebase If Needed

If the project uses push notifications, remote config, or Firebase analytics:

```bash
flutterfire configure
```

Then verify:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

## 10. Add First Run Verification

Run at least one flavor:

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

Verify:

- app boots
- environment resolves correctly
- routes compile
- DI initializes
- launcher icon is generated

## Design Preservation Rule

If the project is derived from the sample, preserve:

- theme direction
- spacing scale
- typography strategy
- widget composition patterns
- navigation structure

Only swap brand-specific content such as:

- app name
- logos
- bundle IDs
- service endpoints
- environment labels
