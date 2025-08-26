import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '../../presentation/themes/romantic_themes.dart';

part 'theme_provider.g.dart';

/// Enum for theme brightness mode
enum ThemeBrightnessMode {
  light,
  dark,
  system,
}

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const String _themeKey = 'selected_romantic_theme';
  static const String _brightnessKey = 'theme_brightness_mode';
  
  @override
  Future<ThemeState> build() async {
    try {
      developer.log('🎨 开始加载主题设置...', name: 'ThemeNotifier');
      
      final prefs = await SharedPreferences.getInstance();
      developer.log('✅ SharedPreferences获取成功', name: 'ThemeNotifier');
      
      // Load saved theme
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      final romanticTheme = RomanticTheme.values[themeIndex.clamp(0, RomanticTheme.values.length - 1)];
      developer.log('🎨 加载的主题: $romanticTheme (index: $themeIndex)', name: 'ThemeNotifier');
      
      // Load saved brightness mode
      final brightnessModeIndex = prefs.getInt(_brightnessKey) ?? 2; // Default to system
      final brightnessMode = ThemeBrightnessMode.values[brightnessModeIndex.clamp(0, ThemeBrightnessMode.values.length - 1)];
      developer.log('🌙 加载的亮度模式: $brightnessMode (index: $brightnessModeIndex)', name: 'ThemeNotifier');
      
      final themeState = ThemeState(
        romanticTheme: romanticTheme,
        brightnessMode: brightnessMode,
      );
      
      developer.log('✅ 主题设置加载完成', name: 'ThemeNotifier');
      return themeState;
    } catch (e, stackTrace) {
      developer.log(
        '❌ 主题设置加载失败: $e',
        name: 'ThemeNotifier',
        error: e,
        stackTrace: stackTrace,
      );
      
      // 返回默认主题设置
      return const ThemeState(
        romanticTheme: RomanticTheme.sweetheartBliss,
        brightnessMode: ThemeBrightnessMode.system,
      );
    }
  }
  
  /// Change the romantic theme
  Future<void> changeRomanticTheme(RomanticTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
    
    final currentState = await future;
    final newState = currentState.copyWith(romanticTheme: theme);
    state = AsyncValue.data(newState);
  }
  
  /// Set brightness mode
  Future<void> setBrightnessMode(ThemeBrightnessMode brightnessMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_brightnessKey, brightnessMode.index);
    
    final currentState = await future;
    final newState = currentState.copyWith(brightnessMode: brightnessMode);
    state = AsyncValue.data(newState);
  }
  
  /// Get current theme data
  ThemeData getCurrentThemeData() {
    return state.when(
      data: (themeState) {
        final romanticThemeData = RomanticThemes.getTheme(themeState.romanticTheme);
        final effectiveBrightness = _getEffectiveBrightness(themeState.brightnessMode);
        return romanticThemeData.toThemeData(brightness: effectiveBrightness);
      },
      loading: () => _getDefaultThemeData(),
      error: (_, __) => _getDefaultThemeData(),
    );
  }
  
  /// Get current romantic theme data
  RomanticThemeData getCurrentRomanticThemeData() {
    return state.when(
      data: (themeState) => RomanticThemes.getTheme(themeState.romanticTheme),
      loading: () => RomanticThemes.getTheme(RomanticTheme.sweetheartBliss),
      error: (_, __) => RomanticThemes.getTheme(RomanticTheme.sweetheartBliss),
    );
  }
  
  /// Get effective brightness based on mode and system preference
  Brightness _getEffectiveBrightness(ThemeBrightnessMode mode) {
    switch (mode) {
      case ThemeBrightnessMode.light:
        return Brightness.light;
      case ThemeBrightnessMode.dark:
        return Brightness.dark;
      case ThemeBrightnessMode.system:
        // Get system brightness from MediaQuery
        final window = WidgetsBinding.instance.window;
        return window.platformBrightness;
    }
  }
  
  ThemeData _getDefaultThemeData() {
    final defaultTheme = RomanticThemes.getTheme(RomanticTheme.sweetheartBliss);
    return defaultTheme.toThemeData();
  }
}

/// Theme state data class
class ThemeState {
  final RomanticTheme romanticTheme;
  final ThemeBrightnessMode brightnessMode;
  
  const ThemeState({
    required this.romanticTheme,
    required this.brightnessMode,
  });
  
  ThemeState copyWith({
    RomanticTheme? romanticTheme,
    ThemeBrightnessMode? brightnessMode,
  }) {
    return ThemeState(
      romanticTheme: romanticTheme ?? this.romanticTheme,
      brightnessMode: brightnessMode ?? this.brightnessMode,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeState &&
          runtimeType == other.runtimeType &&
          romanticTheme == other.romanticTheme &&
          brightnessMode == other.brightnessMode;
  
  @override
  int get hashCode => romanticTheme.hashCode ^ brightnessMode.hashCode;
  
  @override
  String toString() {
    return 'ThemeState{romanticTheme: $romanticTheme, brightnessMode: $brightnessMode}';
  }
}

/// Extension to get theme display information
extension RomanticThemeExtension on RomanticTheme {
  String get displayName {
    switch (this) {
      case RomanticTheme.sweetheartBliss:
        return 'Sweetheart Bliss';
      case RomanticTheme.romanticDreams:
        return 'Romantic Dreams';
      case RomanticTheme.heartfeltHarmony:
        return 'Heartfelt Harmony';
      case RomanticTheme.vintageRose:
        return 'Vintage Rose';
      case RomanticTheme.modernLove:
        return 'Modern Love';
      case RomanticTheme.twilightPassion:
        return 'Twilight Passion';
    }
  }
  
  String get description {
    return RomanticThemes.getTheme(this).description;
  }
  
  IconData get icon {
    return RomanticThemes.getTheme(this).icon;
  }
}

/// Extension for brightness mode display
extension ThemeBrightnessModeExtension on ThemeBrightnessMode {
  String get displayName {
    switch (this) {
      case ThemeBrightnessMode.light:
        return 'Light';
      case ThemeBrightnessMode.dark:
        return 'Dark';
      case ThemeBrightnessMode.system:
        return 'System';
    }
  }
  
  IconData get icon {
    switch (this) {
      case ThemeBrightnessMode.light:
        return Icons.light_mode;
      case ThemeBrightnessMode.dark:
        return Icons.dark_mode;
      case ThemeBrightnessMode.system:
        return Icons.brightness_auto;
    }
  }
  
  String get description {
    switch (this) {
      case ThemeBrightnessMode.light:
        return 'Always use light theme';
      case ThemeBrightnessMode.dark:
        return 'Always use dark theme';
      case ThemeBrightnessMode.system:
        return 'Follow system setting';
    }
  }
}

/// Provider for easy access to current theme data
@riverpod
ThemeData currentThemeData(CurrentThemeDataRef ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.when(
    data: (state) {
      final romanticThemeData = RomanticThemes.getTheme(state.romanticTheme);
      final effectiveBrightness = _getEffectiveBrightness(state.brightnessMode);
      return romanticThemeData.toThemeData(brightness: effectiveBrightness);
    },
    loading: () => _getDefaultThemeData(),
    error: (_, __) => _getDefaultThemeData(),
  );
}

/// Provider for current romantic theme data
@riverpod
RomanticThemeData currentRomanticThemeData(CurrentRomanticThemeDataRef ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.when(
    data: (state) => RomanticThemes.getTheme(state.romanticTheme),
    loading: () => RomanticThemes.getTheme(RomanticTheme.sweetheartBliss),
    error: (_, __) => RomanticThemes.getTheme(RomanticTheme.sweetheartBliss),
  );
}

/// Helper function to get effective brightness
Brightness _getEffectiveBrightness(ThemeBrightnessMode mode) {
  switch (mode) {
    case ThemeBrightnessMode.light:
      return Brightness.light;
    case ThemeBrightnessMode.dark:
      return Brightness.dark;
    case ThemeBrightnessMode.system:
      final window = WidgetsBinding.instance.window;
      return window.platformBrightness;
  }
}

ThemeData _getDefaultThemeData() {
  final defaultTheme = RomanticThemes.getTheme(RomanticTheme.sweetheartBliss);
  return defaultTheme.toThemeData();
}