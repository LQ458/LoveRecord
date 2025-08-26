// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentThemeDataHash() => r'c452c471db465bdb574bb7d3967760d60f6df7ad';

/// Provider for easy access to current theme data
///
/// Copied from [currentThemeData].
@ProviderFor(currentThemeData)
final currentThemeDataProvider = AutoDisposeProvider<ThemeData>.internal(
  currentThemeData,
  name: r'currentThemeDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentThemeDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentThemeDataRef = AutoDisposeProviderRef<ThemeData>;
String _$currentRomanticThemeDataHash() =>
    r'4f3ba687093bbb357c05453540c570fbd790b414';

/// Provider for current romantic theme data
///
/// Copied from [currentRomanticThemeData].
@ProviderFor(currentRomanticThemeData)
final currentRomanticThemeDataProvider =
    AutoDisposeProvider<RomanticThemeData>.internal(
  currentRomanticThemeData,
  name: r'currentRomanticThemeDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentRomanticThemeDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentRomanticThemeDataRef = AutoDisposeProviderRef<RomanticThemeData>;
String _$themeNotifierHash() => r'28230628a61280a71daa70fa9a3b68548ba0a1e1';

/// See also [ThemeNotifier].
@ProviderFor(ThemeNotifier)
final themeNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ThemeNotifier, ThemeState>.internal(
  ThemeNotifier.new,
  name: r'themeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeNotifier = AutoDisposeAsyncNotifier<ThemeState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
