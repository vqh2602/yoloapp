# Move-Only Rules

Use this reference when the migration must preserve behavior exactly.

## Non-Negotiables

- Do not change business rules.
- Do not change runtime conditions, branching, or side effects.
- Do not silently replace one pattern with another.
- Do not rename identifiers just for style.
- Do not combine file moves with unrelated cleanup.

## Safe Migration Process

### 1. Build a move map first

Write a table like:

```text
lib/services/auth_service.dart -> lib/core/services/auth_service.dart
lib/widgets/app_button.dart -> lib/shared/widgets/app_button.dart
lib/modules/login/* -> lib/features/auth/presentation/*
```

Do not start moving files until the mapping is coherent.

### 2. Move by dependency direction

Move lowest-level dependencies first:

- config, constants, errors
- infrastructure and services
- shared helpers/widgets
- feature modules
- app composition

If the codebase is heavily route-driven or DI-driven, it can be safer to move `app/` early for clarity, but still keep each batch small.

### 3. Repair only structural breakage

After each batch, fix only:

- imports
- exports
- file references
- registration tables
- route tables
- generated file relationships

Do not "improve" the implementation while fixing paths.

### 4. Verify after every batch

Minimum checks:

- analyzer or compiler passes
- tests related to moved areas still pass
- startup wiring still resolves moved modules

### 5. Use compatibility shims when needed

If the migration is too large for one atomic move, temporary compatibility files are allowed, such as:

- barrel exports re-exporting the new location
- temporary adapter imports
- staged move aliases

Remove the shims only after all imports point to the new structure.

## Red Flags

Stop and report separately if you find:

- cyclic dependencies that the old structure hid
- files that depend on both feature UI and app-wide infrastructure in both directions
- global singletons with path-sensitive initialization
- generated code or asset paths that require broader tooling changes
- a move that forces API or model changes

These are not simple structural moves anymore.

## Review Checklist

- Every changed file moved or had imports updated for the move
- No logic diff slipped into the migration
- New folders reflect dependency boundaries
- Shared code is actually shared
- Feature-owned code stayed with its feature
- Verification was run and results recorded
