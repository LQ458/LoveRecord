import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/local/settings_service.dart';
import 'business_logic/providers/theme_provider.dart';
import 'business_logic/providers/locale_provider.dart';
import 'presentation/themes/romantic_themes.dart';
import 'l10n/app_localizations.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/create_record_screen.dart';
import 'presentation/screens/record_detail_screen.dart';
import 'presentation/screens/analytics_screen.dart';
import 'presentation/screens/test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化服务
  await Hive.initFlutter();
  await SettingsService.initialize();
  
  runApp(
    const ProviderScope(
      child: LoveRecordApp(),
    ),
  );
}

class LoveRecordApp extends ConsumerWidget {
  const LoveRecordApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final currentLocale = ref.watch(localeNotifierProvider);
    
    // 确保在语言或主题变化时强制重建整个应用
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: themeState.when(
        data: (state) {
          final romanticThemeData = RomanticThemes.getTheme(state.romanticTheme);
          final effectiveBrightness = _getEffectiveBrightness(state.brightnessMode);
          final themeData = romanticThemeData.toThemeData(brightness: effectiveBrightness);
          
          return currentLocale.when(
            data: (locale) => MaterialApp(
              key: ValueKey('app_${state.hashCode}_${locale.hashCode}'), // 为 MaterialApp 添加 key 以强制重建
              title: 'LoveRecord',
              debugShowCheckedModeBanner: false,
              theme: themeData,
              themeMode: effectiveBrightness == Brightness.light 
                  ? ThemeMode.light 
                  : ThemeMode.dark,
              locale: locale,
              home: _getInitialScreen(),
              routes: {
                '/home': (context) => const HomeScreen(),
                '/onboarding': (context) => const OnboardingScreen(),
                '/settings': (context) => const SettingsScreen(),
                '/create-record': (context) => const CreateRecordScreen(),
                '/analytics': (context) => const AnalyticsScreen(),
                '/test': (context) => const TestScreen(),
              },
              onGenerateRoute: (settings) {
                if (settings.name?.startsWith('/record/') == true) {
                  final recordId = settings.name!.substring(8); // 移除 '/record/' 前缀
                  return MaterialPageRoute(
                    builder: (context) => RecordDetailScreen(recordId: recordId),
                  );
                }
                return null;
              },
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
            loading: () => MaterialApp(
              locale: const Locale('zh', 'CN'),
              theme: themeData,
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
            error: (error, stack) => MaterialApp(
              locale: const Locale('zh', 'CN'),
              theme: themeData,
              home: Scaffold(
                body: Center(
                  child: Text('语言加载错误: $error'),
                ),
              ),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          );
        },
        loading: () => const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        error: (error, stack) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('主题加载错误: $error'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getInitialScreen() {
    if (SettingsService.isFirstLaunch) {
      return const OnboardingScreen();
    }
    return const HomeScreen();
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
}
