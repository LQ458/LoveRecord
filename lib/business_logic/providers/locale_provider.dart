import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/local/settings_service.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Future<Locale> build() async {
    final languageCode = SettingsService.language;
    return _getLocaleFromLanguageCode(languageCode);
  }

  /// Change the app locale
  Future<void> changeLocale(String languageCode) async {
    await SettingsService.setLanguage(languageCode);
    state = AsyncValue.data(_getLocaleFromLanguageCode(languageCode));
    // 强制重建以应用新语言
    ref.invalidateSelf();
  }

  /// Get locale from language code
  Locale _getLocaleFromLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'zh_CN':
        return const Locale('zh', 'CN');
      case 'en_US':
        return const Locale('en', 'US');
      default:
        return const Locale('zh', 'CN'); // Default to Chinese
    }
  }

  /// Get language code from locale
  String getLanguageCodeFromLocale(Locale locale) {
    if (locale.languageCode == 'zh') {
      return 'zh_CN';
    } else if (locale.languageCode == 'en') {
      return 'en_US';
    }
    return 'zh_CN';
  }
}

/// Provider for easy access to current locale
@riverpod
Locale currentLocale(CurrentLocaleRef ref) {
  final localeAsync = ref.watch(localeNotifierProvider);
  return localeAsync.when(
    data: (locale) => locale,
    loading: () => const Locale('zh', 'CN'),
    error: (_, __) => const Locale('zh', 'CN'),
  );
}