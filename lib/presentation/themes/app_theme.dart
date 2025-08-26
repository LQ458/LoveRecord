import 'package:flutter/material.dart';

/// 应用主题数据类
class AppTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final Color textSecondaryColor;
  final Color accentColor;
  final Color errorColor;
  final Color successColor;
  final Color warningColor;
  final Color dividerColor;
  final Color cardColor;
  final Color shadowColor;

  const AppTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.textSecondaryColor,
    required this.accentColor,
    required this.errorColor,
    required this.successColor,
    required this.warningColor,
    required this.dividerColor,
    required this.cardColor,
    required this.shadowColor,
  });

  /// 浅色主题
  static const AppTheme light = AppTheme(
    primaryColor: Color(0xFF2196F3),
    secondaryColor: Color(0xFF03DAC6),
    backgroundColor: Color(0xFFF5F5F5),
    surfaceColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF212121),
    textSecondaryColor: Color(0xFF757575),
    accentColor: Color(0xFFFF4081),
    errorColor: Color(0xFFD32F2F),
    successColor: Color(0xFF388E3C),
    warningColor: Color(0xFFFFA000),
    dividerColor: Color(0xFFE0E0E0),
    cardColor: Color(0xFFFFFFFF),
    shadowColor: Color(0x1F000000),
  );

  /// 深色主题
  static const AppTheme dark = AppTheme(
    primaryColor: Color(0xFFBB86FC),
    secondaryColor: Color(0xFF03DAC6),
    backgroundColor: Color(0xFF121212),
    surfaceColor: Color(0xFF1E1E1E),
    textColor: Color(0xFFFFFFFF),
    textSecondaryColor: Color(0xFFB3B3B3),
    accentColor: Color(0xFFFF4081),
    errorColor: Color(0xFFCF6679),
    successColor: Color(0xFF4CAF50),
    warningColor: Color(0xFFFFB74D),
    dividerColor: Color(0xFF424242),
    cardColor: Color(0xFF1E1E1E),
    shadowColor: Color(0x3F000000),
  );

  /// 温暖主题
  static const AppTheme warm = AppTheme(
    primaryColor: Color(0xFFFF7043),
    secondaryColor: Color(0xFFFFB74D),
    backgroundColor: Color(0xFFFFF8E1),
    surfaceColor: Color(0xFFFFFDE7),
    textColor: Color(0xFF3E2723),
    textSecondaryColor: Color(0xFF5D4037),
    accentColor: Color(0xFFFF5722),
    errorColor: Color(0xFFD84315),
    successColor: Color(0xFF4CAF50),
    warningColor: Color(0xFFFF9800),
    dividerColor: Color(0xFFFFCC02),
    cardColor: Color(0xFFFFFDE7),
    shadowColor: Color(0x1F000000),
  );

  /// 专业主题
  static const AppTheme professional = AppTheme(
    primaryColor: Color(0xFF1976D2),
    secondaryColor: Color(0xFF424242),
    backgroundColor: Color(0xFFFAFAFA),
    surfaceColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF212121),
    textSecondaryColor: Color(0xFF757575),
    accentColor: Color(0xFF1976D2),
    errorColor: Color(0xFFD32F2F),
    successColor: Color(0xFF388E3C),
    warningColor: Color(0xFFFFA000),
    dividerColor: Color(0xFFE0E0E0),
    cardColor: Color(0xFFFFFFFF),
    shadowColor: Color(0x1F000000),
  );

  /// 活力主题
  static const AppTheme vibrant = AppTheme(
    primaryColor: Color(0xFFE91E63),
    secondaryColor: Color(0xFF9C27B0),
    backgroundColor: Color(0xFFFCE4EC),
    surfaceColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF212121),
    textSecondaryColor: Color(0xFF757575),
    accentColor: Color(0xFFFF5722),
    errorColor: Color(0xFFD32F2F),
    successColor: Color(0xFF4CAF50),
    warningColor: Color(0xFFFFA000),
    dividerColor: Color(0xFFE0E0E0),
    cardColor: Color(0xFFFFFFFF),
    shadowColor: Color(0x1F000000),
  );

  /// 创建Material主题数据
  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: _isDarkTheme() ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        onPrimary: _isDarkTheme() ? Colors.black : Colors.white,
        secondary: secondaryColor,
        onSecondary: _isDarkTheme() ? Colors.black : Colors.white,
        error: errorColor,
        onError: _isDarkTheme() ? Colors.black : Colors.white,
        surface: surfaceColor,
        onSurface: textColor,
        outline: dividerColor,
        shadow: shadowColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerColor: dividerColor,
      textTheme: TextTheme(
        displayLarge: TextStyle(color: textColor),
        displayMedium: TextStyle(color: textColor),
        displaySmall: TextStyle(color: textColor),
        headlineLarge: TextStyle(color: textColor),
        headlineMedium: TextStyle(color: textColor),
        headlineSmall: TextStyle(color: textColor),
        titleLarge: TextStyle(color: textColor),
        titleMedium: TextStyle(color: textColor),
        titleSmall: TextStyle(color: textColor),
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        bodySmall: TextStyle(color: textSecondaryColor),
        labelLarge: TextStyle(color: textColor),
        labelMedium: TextStyle(color: textColor),
        labelSmall: TextStyle(color: textSecondaryColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
        shadowColor: shadowColor,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: _isDarkTheme() ? Colors.black : Colors.white,
          elevation: 2,
          shadowColor: shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor),
        ),
        labelStyle: TextStyle(color: textSecondaryColor),
        hintStyle: TextStyle(color: textSecondaryColor),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: primaryColor,
        disabledColor: dividerColor,
        labelStyle: TextStyle(color: textColor),
        secondaryLabelStyle: TextStyle(color: _isDarkTheme() ? Colors.black : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: _isDarkTheme() ? Colors.black : Colors.white,
        elevation: 6,
      ),
    );
  }

  /// 判断是否为深色主题
  bool _isDarkTheme() {
    return this == dark;
  }

  /// 创建自定义主题
  AppTheme copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? textColor,
    Color? textSecondaryColor,
    Color? accentColor,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    Color? dividerColor,
    Color? cardColor,
    Color? shadowColor,
  }) {
    return AppTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      textColor: textColor ?? this.textColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
      accentColor: accentColor ?? this.accentColor,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      dividerColor: dividerColor ?? this.dividerColor,
      cardColor: cardColor ?? this.cardColor,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }
} 