import 'package:flutter/material.dart';

/// Romantic theme variants for love records
enum RomanticTheme {
  sweetheartBliss,
  romanticDreams, 
  heartfeltHarmony,
  vintageRose,
  modernLove,
  twilightPassion,
}

class RomanticThemes {
  static const Map<RomanticTheme, RomanticThemeData> themes = {
    RomanticTheme.sweetheartBliss: RomanticThemeData(
      name: 'Sweetheart Bliss',
      description: '温柔甜蜜的粉色系',
      primary: Color(0xFFFF677D),
      secondary: Color(0xFFFFB3BA),
      background: Color(0xFFFFF8F9),
      surface: Color(0xFFFFEBED),
      accent: Color(0xFF392F5A),
      textPrimary: Color(0xFF2C1810),
      textSecondary: Color(0xFF6B4C57),
      gradient: [Color(0xFFFFB3BA), Color(0xFFFF677D)],
      icon: Icons.favorite,
    ),
    
    RomanticTheme.romanticDreams: RomanticThemeData(
      name: 'Romantic Dreams',
      description: '梦幻紫色渐变',
      primary: Color(0xFFCF9EE2),
      secondary: Color(0xFFD669AA),
      background: Color(0xFFF9F6FB),
      surface: Color(0xFFF0E6F7),
      accent: Color(0xFF926BB8),
      textPrimary: Color(0xFF2D1B3D),
      textSecondary: Color(0xFF6B4C77),
      gradient: [Color(0xFFF7BEEF), Color(0xFFCF9EE2)],
      icon: Icons.auto_awesome,
    ),
    
    RomanticTheme.heartfeltHarmony: RomanticThemeData(
      name: 'Heartfelt Harmony',
      description: '温暖橙粉色调',
      primary: Color(0xFFFF6F61),
      secondary: Color(0xFFFF9A8D),
      background: Color(0xFFFFFAF9),
      surface: Color(0xFFFFF0EE),
      accent: Color(0xFFEAB8C9),
      textPrimary: Color(0xFF3D1A0F),
      textSecondary: Color(0xFF8B4A42),
      gradient: [Color(0xFFF7C6C7), Color(0xFFFF6F61)],
      icon: Icons.favorite_border,
    ),
    
    RomanticTheme.vintageRose: RomanticThemeData(
      name: 'Vintage Rose',
      description: '复古玫瑰金',
      primary: Color(0xFFE8B4B8),
      secondary: Color(0xFFD4A5A5),
      background: Color(0xFFFDF8F6),
      surface: Color(0xFFF5EEEC),
      accent: Color(0xFF8B6F6F),
      textPrimary: Color(0xFF4A3333),
      textSecondary: Color(0xFF7A5555),
      gradient: [Color(0xFFF2E2E2), Color(0xFFE8B4B8)],
      icon: Icons.local_florist,
    ),
    
    RomanticTheme.modernLove: RomanticThemeData(
      name: 'Modern Love',
      description: '现代简约爱情',
      primary: Color(0xFFFF4081),
      secondary: Color(0xFFFF80AB),
      background: Color(0xFFFFFBFE),
      surface: Color(0xFFFFF0F3),
      accent: Color(0xFF7B1FA2),
      textPrimary: Color(0xFF1A0B14),
      textSecondary: Color(0xFF6B2C5C),
      gradient: [Color(0xFFFF80AB), Color(0xFFFF4081)],
      icon: Icons.favorite_rounded,
    ),
    
    RomanticTheme.twilightPassion: RomanticThemeData(
      name: 'Twilight Passion',
      description: '黄昏激情紫',
      primary: Color(0xFF8E24AA),
      secondary: Color(0xFFAB47BC),
      background: Color(0xFFFAF8FB),
      surface: Color(0xFFF3EDF5),
      accent: Color(0xFFE91E63),
      textPrimary: Color(0xFF2A1B2E),
      textSecondary: Color(0xFF614A6B),
      gradient: [Color(0xFFE1BEE7), Color(0xFF8E24AA)],
      icon: Icons.nightlight_round,
    ),
  };
  
  static RomanticThemeData getTheme(RomanticTheme theme) {
    return themes[theme]!;
  }
  
  static List<RomanticThemeData> getAllThemes() {
    return themes.values.toList();
  }
}

class RomanticThemeData {
  final String name;
  final String description;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final List<Color> gradient;
  final IconData icon;
  
  const RomanticThemeData({
    required this.name,
    required this.description,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.gradient,
    required this.icon,
  });
  
  /// Convert to Flutter ThemeData
  ThemeData toThemeData({Brightness brightness = Brightness.light}) {
    // 自然黑色系Dark Theme配色方案
    final isDark = brightness == Brightness.dark;
    
    // 深色模式下的自然灰色系
    final adjustedBackground = isDark ? const Color(0xFF121212) : background;  // 深灰背景
    final adjustedSurface = isDark ? const Color(0xFF1E1E1E) : surface;        // 表面灰
    final adjustedCardColor = isDark ? const Color(0xFF2D2D2D) : surface;      // 卡片灰
    final adjustedElevatedColor = isDark ? const Color(0xFF424242) : surface;  // 提升灰
    
    // 文字颜色 - 自然对比度
    final adjustedTextPrimary = isDark ? const Color(0xFFE0E0E0) : textPrimary;    // 主要文字
    final adjustedTextSecondary = isDark ? const Color(0xFFB0B0B0) : textSecondary; // 次要文字
    final adjustedTextTertiary = isDark ? const Color(0xFF757575) : textSecondary;  // 第三级文字
    
    // 深色模式保持主题色，但用于细节设计
    final adjustedPrimary = isDark ? primary : primary;      // 保持主题色
    final adjustedSecondary = isDark ? secondary : secondary;  // 保持主题色
    
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: adjustedPrimary,
      secondary: adjustedSecondary,
      surface: adjustedSurface,
      background: adjustedBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: adjustedTextPrimary,
      onBackground: adjustedTextPrimary,
      error: isDark ? const Color(0xFFCF6679) : Colors.red,
      onError: Colors.white,
      // 添加更多现代ColorScheme属性
      surfaceVariant: adjustedCardColor,
      onSurfaceVariant: adjustedTextSecondary,
      outline: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
      outlineVariant: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0),
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: primary,
      scaffoldBackgroundColor: adjustedBackground,
      cardColor: adjustedSurface,
      
      // App Bar Theme - 现代设计
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? adjustedBackground : adjustedSurface,
        foregroundColor: adjustedTextPrimary,
        elevation: 0, // 移除阴影，减少割裂感
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: adjustedTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        // 添加现代分割线
        surfaceTintColor: Colors.transparent,
      ),
      
      // Card Theme - 现代设计
      cardTheme: CardThemeData(
        color: adjustedCardColor,
        elevation: isDark ? 0 : 1.0, // 深色模式无阴影
        shadowColor: isDark ? Colors.transparent : primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        // 添加现代边框
        surfaceTintColor: Colors.transparent,
      ),
      
      // Elevated Button Theme - 现代设计
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: adjustedPrimary,
          foregroundColor: Colors.white,
          elevation: isDark ? 0 : 1,
          shadowColor: isDark ? Colors.transparent : adjustedPrimary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          // 添加现代属性
          surfaceTintColor: Colors.transparent,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: adjustedPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input Decoration Theme - 现代设计
      inputDecorationTheme: InputDecorationTheme(
        fillColor: adjustedCardColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: adjustedPrimary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
        // 添加现代属性
        hintStyle: TextStyle(color: adjustedTextTertiary),
      ),
      
      // Chip Theme - 现代设计
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF424242) : secondary.withOpacity(0.1),
        selectedColor: adjustedPrimary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFFE0E0E0) : adjustedTextPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        // 添加现代属性
        side: BorderSide.none,
        elevation: 0,
      ),
      
      // Text Theme
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: adjustedTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: adjustedTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: adjustedTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: adjustedTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: adjustedTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: adjustedTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: adjustedTextSecondary,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          color: adjustedTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  /// Create a linear gradient decoration
  BoxDecoration createGradientDecoration({
    double borderRadius = 16,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: withShadow ? [
        BoxShadow(
          color: primary.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ] : null,
    );
  }
  
  /// Helper method to darken a color for dark mode
  Color _darkenColor(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * factor).clamp(0.0, 1.0)).toColor();
  }
  
  /// Helper method to lighten a color for dark mode
  Color _lightenColor(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + (1.0 - hsl.lightness) * factor).clamp(0.0, 1.0)).toColor();
  }
  
  /// Helper method to adjust color for dark mode - modern approach
  Color _adjustColorForDark(Color color) {
    final hsl = HSLColor.fromColor(color);
    // 在深色模式下，增加饱和度和亮度，但保持色调
    return hsl
        .withSaturation((hsl.saturation * 1.2).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 1.3).clamp(0.0, 0.8))
        .toColor();
  }
}