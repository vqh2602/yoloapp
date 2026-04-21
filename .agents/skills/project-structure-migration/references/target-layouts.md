# Target Layouts

Use this reference to choose a portable target structure before moving any files.

## Flutter-Oriented Example

```text
lib/
├── app/
│   ├── app.dart
│   ├── bootstrap/
│   ├── config/
│   ├── di/
│   ├── navigation/
│   ├── routes/
│   └── theme/
├── core/
│   ├── base/
│   ├── config/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── services/
│   ├── storage/
│   └── utils/
├── shared/
│   ├── extensions/
│   ├── models/
│   ├── widgets/
│   └── helpers/
└── features/
    ├── auth/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── dashboard/
        ├── data/
        ├── domain/
        └── presentation/
```

## Generic Source Layout

```text
src/
├── app/
│   ├── bootstrap/
│   ├── config/
│   ├── routing/
│   └── composition/
├── core/
│   ├── api/
│   ├── config/
│   ├── errors/
│   ├── logging/
│   ├── storage/
│   └── utils/
├── shared/
│   ├── components/
│   ├── helpers/
│   ├── hooks/
│   ├── styles/
│   └── types/
└── features/
    ├── users/
    ├── billing/
    └── reports/
```

## Mapping Heuristics

Typical current folders and likely destinations:

- `routes/`, `router/`, `navigation/` -> `app/routes/` or `app/navigation/`
- `theme/`, `app_theme/` -> `app/theme/`
- `services/` -> `core/services/` if cross-app, otherwise `features/<feature>/data/`
- `network/`, `api/`, `dio/`, `http/` -> `core/network/`
- `utils/`, `helpers/`, `extensions/` -> `core/` or `shared/` based on dependency direction
- `widgets/`, `components/` -> `shared/widgets/` unless feature-owned
- `screens/`, `pages/`, `controllers/`, `bloc/`, `viewmodels/` -> `features/<feature>/presentation/`
- `repositories/`, `datasources/`, `models/` -> `features/<feature>/data/` unless truly shared

## Decision Rules

Choose one target shape and stick to it for the entire migration.

Ask of each file:

1. Is it app composition only?
2. Is it foundational and feature-agnostic?
3. Is it reused by multiple features?
4. Is it owned by a single feature?

Map the file to the first matching category:

- app composition -> `app/`
- foundational -> `core/`
- cross-feature reusable -> `shared/`
- feature-owned -> `features/<feature>/`
