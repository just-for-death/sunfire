# Dependency upgrade plan

Staged upgrades avoid a single breaking PR. After each stage, run `flutter analyze`, then manually regression-test **reader**, **chapter downloads**, **GraphQL subscriptions** (updates / WebSocket), and **tracker** flows.

## Stage 1 — Patch / minor and GraphQL stability

- Run `flutter pub upgrade` within current major constraints.
- Move `graphql` and `graphql_flutter` from beta to **stable** when `graphql_codegen` and `build_runner` resolve cleanly with the chosen versions.
- Re-run codegen: `dart run build_runner build --delete-conflicting-outputs`.
- Verify `lib/src/graphql/schema.graphql` and generated Dart under `lib/**/*/__generated__/`.

## Stage 2 — Riverpod 3

- Upgrade `hooks_riverpod`, `flutter_riverpod`, `riverpod_annotation`, and `riverpod_generator` together per migration notes.
- Fix deprecations (`Ref` types, notifier patterns, etc.).
- Regenerate `*.g.dart` providers.

## Stage 3 — Routing

- Upgrade `go_router` and `go_router_builder` together; regenerate `router_config.g.dart`.
- Re-test deep links, shell routes, and Quick Open stack.

## Stage 4 — Platform plugins (as needed)

- `flutter_local_notifications`, `permission_handler`, `file_picker`, `package_info_plus`, and other majors — one cluster at a time, reading each plugin’s breaking changelog.

## Supply chain

- Git dependencies: always pin `ref:` to a full commit SHA (see `flutter_android_volume_keydown` in `pubspec.yaml`).
