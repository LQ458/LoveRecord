import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer' as developer;
import '../../data/local/settings_service.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Future<Locale> build() async {
    try {
      developer.log('🌍 开始加载语言设置...', name: 'LocaleNotifier');
      
      final languageCode = SettingsService.language;
      developer.log('🌍 当前语言代码: $languageCode', name: 'LocaleNotifier');
      
      final locale = _getLocaleFromLanguageCode(languageCode);
      developer.log('✅ 语言设置加载完成: $locale', name: 'LocaleNotifier');
      
      return locale;
    } catch (e, stackTrace) {
      developer.log(
        '❌ 语言设置加载失败: $e',
        name: 'LocaleNotifier',
        error: e,
        stackTrace: stackTrace,
      );
      
      // 返回默认语言
      return const Locale('zh', 'CN');
    }
  }

  /// Change the app locale
  Future<void> changeLocale(String languageCode) async {
    try {
      developer.log('🌍 开始更改语言: $languageCode', name: 'LocaleNotifier');
      
      await SettingsService.setLanguage(languageCode);
      final newLocale = _getLocaleFromLanguageCode(languageCode);
      state = AsyncValue.data(newLocale);
      
      developer.log('✅ 语言更改完成: $newLocale', name: 'LocaleNotifier');
      
      // 强制重建以应用新语言
      ref.invalidateSelf();
    } catch (e, stackTrace) {
      developer.log(
        '❌ 语言更改失败: $e',
        name: 'LocaleNotifier',
        error: e,
        stackTrace: stackTrace,
      );
      
      // 设置错误状态
      state = AsyncValue.error(e, stackTrace);
    }
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