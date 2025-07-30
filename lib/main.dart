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
    
    return themeState.when(
      data: (state) {
        final romanticThemeData = RomanticThemes.getTheme(state.romanticTheme);
        final themeData = romanticThemeData.toThemeData(brightness: state.brightness);
        
        return MaterialApp(
          title: 'LoveRecord',
          debugShowCheckedModeBanner: false,
          theme: themeData,
          themeMode: state.brightness == Brightness.light 
              ? ThemeMode.light 
              : ThemeMode.dark,
          locale: currentLocale.when(
            data: (locale) => locale,
            loading: () => const Locale('zh', 'CN'),
            error: (_, __) => const Locale('zh', 'CN'),
          ),
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
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
      loading: () => MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Theme loading error: $error'),
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
}
