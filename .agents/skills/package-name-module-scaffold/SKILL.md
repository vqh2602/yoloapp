---
name: marineradar-module-scaffold
description: Scaffold a new Marineradar Flutter/GetX module under lib/app/modules with screen.dart, screen_mobile.dart, controller.dart, binding.dart, an optional widgets folder, and route registration in lib/routes/routes.dart. Use when asked to create a new screen folder, add controller and binding files, wire a new router entry, or generate the initial boilerplate for a module in this repo.
---

# Marineradar Module Scaffold

Use this skill to create a new screen/module in the Marineradar app with the same baseline structure used by existing GetX modules.

## Workflow

1. Confirm the target repo has `pubspec.yaml` and `lib/routes/routes.dart`.
2. Read [references/project-patterns.md](references/project-patterns.md) if the nearby module style is unclear.
3. Run the scaffold script:

```bash
python3 scripts/scaffold_module.py \
  --project-root /path/to/marineradar \
  --module analytics_overview \
  --route-segment analytics-overview
```

The script reads the Dart package name from `pubspec.yaml`, so generated imports are not hard-coded to one app name.

4. Review the generated files and adapt the boilerplate to the nearest existing module if the feature is not a standard screen.
5. Keep screen-only widgets inside `lib/app/modules/<module>/widgets/`.
6. Move reusable widgets to `lib/app/widgets/`.
7. If the UI becomes large, split rendering into smaller widgets instead of keeping everything in `<module>_screen_mobile.dart`.

## Defaults

- Create `lib/app/modules/<module>/<module>_screen.dart`
- Create `lib/app/modules/<module>/<module>_screen_mobile.dart`
- Create `lib/app/modules/<module>/<module>_controller.dart`
- Create `lib/app/modules/<module>/<module>_binding.dart`
- Create `lib/app/modules/<module>/widgets/`
- Add imports and a `GetPage` entry to `lib/routes/routes.dart`
- Use the responsive wrapper style by default

## Screen Styles

Use the default responsive style for most modules:

```bash
python3 scripts/scaffold_module.py \
  --project-root /path/to/marineradar \
  --module vessel_alerts \
  --route-segment vessel-alerts \
  --screen-style responsive
```

Use the `sbase` style when the module should behave like `statistics` or `user_sessions`:

```bash
python3 scripts/scaffold_module.py \
  --project-root /path/to/marineradar \
  --module vessel_reports \
  --route-segment vessel-reports \
  --screen-style sbase
```

## Rules

- Normalize module names to snake_case.
- Prefer `route-segment` in kebab-case unless the surrounding feature already uses another convention.
- Do not create shared widgets inside a module folder.
- Do not move existing routes around unless the file already needs cleanup.
- If a matching module already exists, stop and merge into that module instead of scaffolding a duplicate.

## Generated Boilerplate

The script creates:

- A route-aware screen entrypoint
- A mobile screen with a minimal `SBaseScreen` body
- A `GetxController` using `StateMixin`
- A `Bindings` class with `Get.lazyPut(..., fenix: true)`

After scaffolding, replace the placeholder texts and fill controller logic with real data loading.

## Files To Check

- `lib/routes/routes.dart`
- `lib/app/modules/<module>/`
- Nearby modules with similar behavior
