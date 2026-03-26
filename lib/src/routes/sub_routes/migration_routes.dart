part of '../router_config.dart';

class MigrationMainRoute extends GoRouteData {
  const MigrationMainRoute();

  static final $parentNavigatorKey = _quickOpenNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MigrationMainScreen();
}

class MigrationSourceMangaRoute extends GoRouteData {
  const MigrationSourceMangaRoute({required this.sourceId});

  static final $parentNavigatorKey = _quickOpenNavigatorKey;
  final String sourceId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      MigrationSourceMangaScreen(sourceId: sourceId);
}

class MigrationGlobalSearchRoute extends GoRouteData {
  const MigrationGlobalSearchRoute({this.$extra});

  static final $parentNavigatorKey = _quickOpenNavigatorKey;
  final MigrationRouteData? $extra;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    if ($extra == null) return '/library/0';
    return null;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MigrationGlobalSearchScreen(sourceManga: $extra!.sourceMangas.first);
  }
}

class MigrationSourceSelectionRoute extends GoRouteData {
  const MigrationSourceSelectionRoute({this.$extra});

  static final $parentNavigatorKey = _quickOpenNavigatorKey;
  final MigrationRouteData? $extra;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    if ($extra == null) return '/library/0';
    return null;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MigrationSourceSelectionScreen(sourceMangas: $extra!.sourceMangas);
  }
}

class MigrationSearchRoute extends GoRouteData {
  const MigrationSearchRoute({this.$extra});

  static final $parentNavigatorKey = _quickOpenNavigatorKey;
  final MigrationSearchRouteData? $extra;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    if ($extra == null) return '/library/0';
    return null;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MigrationSearchScreen(
      sourceMangas: $extra!.sourceMangas,
      targetSource: $extra!.targetSource,
    );
  }
}

class MigrationBatchMatchRoute extends GoRouteData {
  const MigrationBatchMatchRoute({this.$extra});

  static final $parentNavigatorKey = _quickOpenNavigatorKey;
  final MigrationSearchRouteData? $extra;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    if ($extra == null) return '/library/0';
    return null;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MigrationBatchMatchScreen(
      sourceMangas: $extra!.sourceMangas,
      targetSource: $extra!.targetSource,
    );
  }
}

class MigrationPreviewRoute extends GoRouteData {
  const MigrationPreviewRoute({this.$extra});

  static final $parentNavigatorKey = _quickOpenNavigatorKey;
  final MigrationPreviewRouteData? $extra;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    if ($extra == null) return '/library/0';
    return null;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MigrationPreviewScreen(
      sourceManga: $extra!.sourceManga,
      targetManga: $extra!.targetManga,
      targetSource: $extra!.targetSource,
    );
  }
}

class MigrationProgressRoute extends GoRouteData {
  const MigrationProgressRoute({this.$extra});

  static final $parentNavigatorKey = _quickOpenNavigatorKey;
  final MigrationProgressRouteData? $extra;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    if ($extra == null) return '/library/0';
    return null;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MigrationProgressScreen(
      sourceManga: $extra!.sourceManga,
      targetManga: $extra!.targetManga,
      targetSource: $extra!.targetSource,
      options: $extra!.options,
    );
  }
}

class MigrationBatchProgressRoute extends GoRouteData {
  const MigrationBatchProgressRoute();

  static final $parentNavigatorKey = _quickOpenNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const MigrationBatchProgressScreen();
  }
}
