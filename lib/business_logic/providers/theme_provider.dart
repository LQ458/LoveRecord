import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../presentation/themes/romantic_themes.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const String _themeKey = 'selected_romantic_theme';
  static const String _brightnessKey = 'theme_brightness';
  
  @override
  Future<ThemeState> build() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load saved theme
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    final romanticTheme = RomanticTheme.values[themeIndex.clamp(0, RomanticTheme.values.length - 1)];
    
    // Load saved brightness
    final brightnessIndex = prefs.getInt(_brightnessKey) ?? 0;
    final brightness = Brightness.values[brightnessIndex];
    
    return ThemeState(
      romanticTheme: romanticTheme,
      brightness: brightness,
    );
  }
  
  /// Change the romantic theme
  Future<void> changeRomanticTheme(RomanticTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
    
    final currentState = await future;
    final newState = currentState.copyWith(romanticTheme: theme);
    state = AsyncValue.data(newState);
  }
  
  /// Toggle between light and dark mode
  Future<void> toggleBrightness() async {
    final currentState = await future;
    final newBrightness = currentState.brightness == Brightness.light 
        ? Brightness.dark 
        : Brightness.light;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_brightnessKey, newBrightness.index);
    
    final newState = currentState.copyWith(brightness: newBrightness);
    state = AsyncValue.data(newState);
  }
  
  /// Set specific brightness
  Future<void> setBrightness(Brightness brightness) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_brightnessKey, brightness.index);
    
    final currentState = await future;
    final newState = currentState.copyWith(brightness: brightness);
    state = AsyncValue.data(newState);
  }
  
  /// Get current theme data
  ThemeData getCurrentThemeData() {
    return state.when(
      data: (themeState) {
        final romanticThemeData = RomanticThemes.getTheme(themeState.romanticTheme);
        return romanticThemeData.toThemeData(brightness: themeState.brightness);
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
  
  ThemeData _getDefaultThemeData() {
    final defaultTheme = RomanticThemes.getTheme(RomanticTheme.sweetheartBliss);
    return defaultTheme.toThemeData();
  }
}

/// Theme state data class
class ThemeState {
  final RomanticTheme romanticTheme;
  final Brightness brightness;
  
  const ThemeState({
    required this.romanticTheme,
    required this.brightness,
  });
  
  ThemeState copyWith({
    RomanticTheme? romanticTheme,
    Brightness? brightness,
  }) {
    return ThemeState(
      romanticTheme: romanticTheme ?? this.romanticTheme,
      brightness: brightness ?? this.brightness,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeState &&
          runtimeType == other.runtimeType &&
          romanticTheme == other.romanticTheme &&
          brightness == other.brightness;
  
  @override
  int get hashCode => romanticTheme.hashCode ^ brightness.hashCode;
  
  @override
  String toString() {
    return 'ThemeState{romanticTheme: $romanticTheme, brightness: $brightness}';
  }
}

/// Extension to get theme display information
extension RomanticThemeExtension on RomanticTheme {
  String get displayName {
    switch (this) {
      case RomanticTheme.sweetheartBliss:
        return '甜心幸福';
      case RomanticTheme.romanticDreams:
        return '浪漫梦境';
      case RomanticTheme.heartfeltHarmony:
        return '温馨和谐';
      case RomanticTheme.vintageRose:
        return '复古玫瑰';
      case RomanticTheme.modernLove:
        return '现代之爱';
      case RomanticTheme.twilightPassion:
        return '黄昏激情';
    }
  }
  
  String get description {
    return RomanticThemes.getTheme(this).description;
  }
  
  IconData get icon {
    return RomanticThemes.getTheme(this).icon;
  }
}

/// Provider for easy access to current theme data
@riverpod
ThemeData currentThemeData(CurrentThemeDataRef ref) {
  final themeState = ref.watch(themeNotifierProvider);
  return themeState.when(
    data: (state) {
      final romanticThemeData = RomanticThemes.getTheme(state.romanticTheme);
      return romanticThemeData.toThemeData(brightness: state.brightness);
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

ThemeData _getDefaultThemeData() {
  final defaultTheme = RomanticThemes.getTheme(RomanticTheme.sweetheartBliss);
  return defaultTheme.toThemeData();
}