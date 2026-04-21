---
name: flutter-serp-project-bootstrap
description: Create a new Flutter application that follows the Serp-style architecture used by the sample project: app/, core/, shared/, features/, GetX routing and bindings, environment configs, flavors via flutter_flavorizr, launcher icons via flutter_launcher_icons, and the core Serp dependency stack. Use when asked to start a new Flutter app from this architectural baseline, bootstrap a new white-label project from the sample, or reproduce the sample project structure without redesigning the UI or changing the established design system.
---

# Flutter Serp Project Bootstrap

Use this skill to create a new Flutter project that stays close to the sample project structure and tooling while remaining portable for other apps.

## Core Rule

Bootstrap the project structure and tooling without inventing a new design system.

Required behavior:

- preserve the sample architecture shape
- preserve the design direction when the new project is based on an existing sample
- keep theme, widget patterns, and UI composition aligned with the sample unless the user explicitly requests redesign
- parameterize app names, package IDs, bundle IDs, API endpoints, logos, and secret values

Do not:

- redesign screens because the project is new
- replace the existing state-management approach
- swap out core Serp packages unless the user asks
- mix project bootstrap with unrelated refactors
- preload feature-specific packages that the new app does not need yet

## Workflow

1. Confirm the new app name, Dart package name, Android application ID, iOS bundle ID, and flavor display names.
2. Create the Flutter app shell.
3. Apply the target folder structure from [references/project-layout.md](references/project-layout.md).
4. Add the minimum dependency stack and tool configs from [references/dependency-stack.md](references/dependency-stack.md).
5. Add flavors, environment files, flavor entrypoints, routing, DI, and bootstrap wiring.
6. Add launcher icon assets and run icon generation.
7. Run flavor generation and patch the generated `main_<flavor>.dart` files to delegate to `base.main()`, matching the sample pattern.
8. Add Firebase setup only if the project needs push, remote config, or analytics.
9. Verify that the app runs for at least one flavor before adding feature code.

## Architecture Target

Use this baseline layout:

- `lib/app/` for app composition, config, DI, navigation, routes, translations, and bootstrap
- `lib/core/` for services, repositories, network, constants, models, and utilities
- `lib/shared/` for shared widgets, theme, helpers, controllers, and mixins
- `lib/features/` for feature-owned screens, controllers, bindings, and widgets

If the user asks for a brand-new project, create the architecture first and then add features. Do not start from a flat `lib/` layout and "clean it up later".

## Key Files

Create and wire these files early:

- `lib/main.dart`
- `lib/main_dev.dart`
- `lib/main_uat.dart`
- `lib/main_prod.dart`
- `lib/flavors.dart`
- `lib/app/config/configurations.dart`
- `lib/app/config/environment.dart`
- `lib/app/config/environment_dev.dart`
- `lib/app/config/environment_uat.dart`
- `lib/app/config/environment_prod.dart`
- `lib/app/bootstrap/<app_module>.dart`
- `lib/app/di/locator.dart`
- `lib/app/routes/routes.dart`

Use portable placeholders for app-specific values.

## Flavor and Tooling Rules

- Use `flutter_flavorizr` to manage `dev`, `uat`, and `prod`.
- Use `flutter_launcher_icons` for launcher icons.
- Keep the flavor enum and `main_<flavor>.dart` pattern close to the sample.
- If the team uses FVM, align with the sample Flutter version before bootstrapping.
- Keep generated config files out of secret scanning where appropriate.

Read [references/setup-sequence.md](references/setup-sequence.md) before executing a full project bootstrap.

## Design Preservation

When the new app is derived from an existing sample:

- reuse the same design primitives first
- only swap brand assets, names, and environment values
- keep spacing, typography strategy, navigation patterns, and major layouts consistent
- do not create a new visual direction unless asked

## Output Expectations

When using this skill, provide:

- the target tree
- the bootstrapping order
- the exact dependency/config blocks to add
- the list of files to create
- any required placeholders the user must fill in

If a value is project-specific and unknown, leave a clear placeholder instead of inventing production credentials.

Start with the minimum baseline package set. Pull optional dependencies from the sample only when the requested feature set needs them.
