// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentLocaleHash() => r'dc5710073b4ba4c547204271375c7d8c3a62e3b6';

/// Provider for easy access to current locale
///
/// Copied from [currentLocale].
@ProviderFor(currentLocale)
final currentLocaleProvider = AutoDisposeProvider<Locale>.internal(
  currentLocale,
  name: r'currentLocaleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentLocaleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentLocaleRef = AutoDisposeProviderRef<Locale>;
String _$localeManagerHash() => r'4793c825cddfe85d48478a998cfd762fa41d47f4';

/// See also [LocaleManager].
@ProviderFor(LocaleManager)
final localeManagerProvider =
    AutoDisposeAsyncNotifierProvider<LocaleManager, Locale>.internal(
  LocaleManager.new,
  name: r'localeManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localeManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocaleManager = AutoDisposeAsyncNotifier<Locale>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
