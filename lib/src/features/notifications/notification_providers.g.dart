// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationServiceHash() =>
    r'9a5232aa4e85bbc0de7ac1ae53885fd402be5f9b';

/// See also [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider = Provider<NotificationService>.internal(
  notificationService,
  name: r'notificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationServiceRef = ProviderRef<NotificationService>;
String _$chapterUpdateNotifierHash() =>
    r'304bd1a564f229408048c1aab29fa0a56ec406a8';

/// See also [ChapterUpdateNotifier].
@ProviderFor(ChapterUpdateNotifier)
final chapterUpdateNotifierProvider =
    NotifierProvider<ChapterUpdateNotifier, void>.internal(
  ChapterUpdateNotifier.new,
  name: r'chapterUpdateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chapterUpdateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChapterUpdateNotifier = Notifier<void>;
String _$extensionUpdateNotifierHash() =>
    r'a7a39aa7e76fdc45952313a1d6fe67726c6f20de';

/// See also [ExtensionUpdateNotifier].
@ProviderFor(ExtensionUpdateNotifier)
final extensionUpdateNotifierProvider =
    NotifierProvider<ExtensionUpdateNotifier, void>.internal(
  ExtensionUpdateNotifier.new,
  name: r'extensionUpdateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$extensionUpdateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExtensionUpdateNotifier = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
