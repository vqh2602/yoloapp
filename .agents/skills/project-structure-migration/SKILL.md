---
name: project-structure-migration
description: Plan and execute safe codebase structure migrations that reorganize an existing project into folders such as app/, core/, shared/, and features/ without changing runtime behavior or business logic. Use when asked to modernize project layout, regroup folders, move files into a cleaner architecture, or split bootstrap/core/shared/feature code while preserving the existing implementation.
---

# Project Structure Migration

Use this skill to reorganize a codebase into a clearer architecture while keeping behavior unchanged. The goal is move-only migration: move files, regroup folders, update imports/exports/registrations, and keep logic intact.

## Core Rule

Treat this as a structural migration, not a refactor.

Allowed:

- move files and folders
- rename folders for clearer grouping
- update imports, exports, route registrations, DI registrations, and path-based config
- add temporary barrel files or compatibility exports when needed to stage the migration

Not allowed unless the user explicitly asks:

- changing algorithms or control flow
- rewriting state management or dependency injection patterns
- changing API shapes, DTO fields, models, or persistence behavior
- merging business logic just because files are being moved
- "cleaning up" unrelated code during the migration

## Workflow

1. Inventory the current structure and identify what is bootstrap, core infrastructure, shared reusable code, and feature-specific code.
2. Choose the target layout before moving anything. Read [references/target-layouts.md](references/target-layouts.md) for portable examples.
3. Translate the current tree into a move plan: `old path -> new path`.
4. Move in small batches that compile independently.
5. After each batch, update imports, exports, route wiring, DI wiring, generated part files, and path-based references.
6. Run the narrowest relevant verification after each batch: analyzer, tests, or at least a compile check.
7. Stop if preserving behavior would require real logic refactors. Surface that separately instead of hiding it inside the migration.

## Safe Sequencing

Prefer this order:

1. App bootstrap and composition
2. Core infrastructure
3. Shared cross-feature code
4. Feature modules
5. Barrel exports and cleanup

Reason:

- `app/` becomes the top-level composition root
- `core/` should settle before features depend on its new paths
- `shared/` should contain only reusable cross-feature code
- `features/` should be moved after the common layers are stable

## Layer Intent

Use these meanings unless the project already has a strong alternative convention:

- `app/`: app entry, routing, DI bootstrap, theme, navigation shell, startup flow, top-level configuration assembly
- `core/`: foundational services, networking, storage, constants, errors, base classes, platform wrappers, environment config, non-UI utilities needed across the app
- `shared/`: reusable widgets, shared presentation helpers, common extensions, shared UI resources, app-wide helpers that are not feature-owned
- `features/`: feature-specific screens, controllers, view models, use cases, repositories, models, widgets, and local helpers

If a file is only used by one feature, keep it inside that feature. Do not move it to `shared/` just because it looks generic.

## Migration Rules

- Preserve public class and function names unless a rename is required to avoid a collision created by the move itself.
- Prefer moving a folder intact before splitting internals further.
- Keep feature-internal widgets close to the feature.
- Move shared utilities out only when they are truly cross-feature.
- If a file depends on presentation-only code, it does not belong in `core/`.
- If `core/` starts importing feature code, stop and revisit the boundaries.
- If the current project uses generated files, part files, build runners, codegen, or asset lookups, update those path relationships immediately after the move.

Read [references/move-only-rules.md](references/move-only-rules.md) when the migration is large or risky.

## Output Expectations

When using this skill on a real migration:

- provide the target tree first
- provide the move mapping in batches
- implement only structural changes
- report any places where a true logic refactor would be required
- separate "done safely by moving" from "blocked without behavior change"

## Portable Trigger Examples

Use this skill for requests like:

- "Reorganize this project into app/core/shared/features without changing logic."
- "Move this old codebase to a cleaner architecture and keep behavior the same."
- "Group files into core and feature folders only; do not refactor business logic."
- "Modernize folder structure, but keep existing controllers/services working as-is."
