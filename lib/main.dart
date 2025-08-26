import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:developer' as developer;
import 'data/local/settings_service.dart';
import 'core/config/env_config.dart';
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
  // 设置全局错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    developer.log(
      'Flutter Error: ${details.exception}',
      name: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  try {
    developer.log('🚀 开始初始化应用...', name: 'Main');
    
    WidgetsFlutterBinding.ensureInitialized();
    developer.log('✅ Flutter绑定初始化完成', name: 'Main');
    
    // 初始化服务
    developer.log('📦 开始初始化Hive...', name: 'Main');
    await Hive.initFlutter();
    developer.log('✅ Hive初始化完成', name: 'Main');
    
    developer.log('🔧 开始初始化环境配置...', name: 'Main');
    await EnvConfig.initialize();
    developer.log('✅ 环境配置初始化完成', name: 'Main');
    
    developer.log('⚙️ 开始初始化设置服务...', name: 'Main');
    await SettingsService.initialize();
    developer.log('✅ 设置服务初始化完成', name: 'Main');
    
    // 直接设置配置（临时解决方案）
    const apiKey = 'sk-9a0a426475814fc48ef9ae955be93530';
    const provider = 'dashscope';
    
    developer.log('🔑 开始设置AI配置...', name: 'Main');
    await SettingsService.setApiKey(apiKey);
    await SettingsService.setAiProvider(provider);
    
    developer.log('✅ 已直接设置AI配置', name: 'Main');
    developer.log('Provider: $provider', name: 'Main');
    developer.log('API Key: ${apiKey.substring(0, 8)}...', name: 'Main');
    
    // 验证配置
    final currentApiKey = SettingsService.apiKey;
    final currentProvider = SettingsService.aiProvider;
    developer.log('验证 - SettingsService.apiKey: ${currentApiKey?.isNotEmpty == true ? "已配置(${currentApiKey!.length}字符)" : "未配置"}', name: 'Main');
    developer.log('验证 - SettingsService.aiProvider: $currentProvider', name: 'Main');
    
    developer.log('🎯 开始启动应用...', name: 'Main');
    runApp(
      ProviderScope(
        observers: [AppProviderObserver()],
        child: const LoveRecordApp(),
      ),
    );
    developer.log('✅ 应用启动完成', name: 'Main');
    
  } catch (e, stackTrace) {
    developer.log(
      '❌ 应用初始化失败: $e',
      name: 'Main',
      error: e,
      stackTrace: stackTrace,
    );
    
    // 尝试启动一个最小的错误显示应用
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('应用初始化失败', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('错误: $e', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // 重启应用
                    main();
                  },
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Provider观察者，用于调试
class AppProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    developer.log('Provider添加: ${provider.name ?? provider.runtimeType}', name: 'ProviderObserver');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    developer.log('Provider销毁: ${provider.name ?? provider.runtimeType}', name: 'ProviderObserver');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    developer.log('Provider更新: ${provider.name ?? provider.runtimeType}', name: 'ProviderObserver');
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    developer.log(
      'Provider错误: ${provider.name ?? provider.runtimeType} - $error',
      name: 'ProviderObserver',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

class LoveRecordApp extends ConsumerWidget {
  const LoveRecordApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      developer.log('🎨 开始构建LoveRecordApp...', name: 'LoveRecordApp');
      
      final themeState = ref.watch(themeNotifierProvider);
      final currentLocale = ref.watch(localeNotifierProvider);
      
      developer.log('📱 主题状态: ${themeState.runtimeType}', name: 'LoveRecordApp');
      developer.log('🌍 语言状态: ${currentLocale.runtimeType}', name: 'LoveRecordApp');
      
      // 确保在语言或主题变化时强制重建整个应用
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: themeState.when(
          data: (state) {
            try {
              developer.log('🎨 构建主题数据...', name: 'LoveRecordApp');
              final romanticThemeData = RomanticThemes.getTheme(state.romanticTheme);
              final effectiveBrightness = _getEffectiveBrightness(state.brightnessMode);
              final themeData = romanticThemeData.toThemeData(brightness: effectiveBrightness);
              developer.log('✅ 主题数据构建完成', name: 'LoveRecordApp');
              
              return currentLocale.when(
                data: (locale) {
                  try {
                    developer.log('🏠 构建MaterialApp，语言: $locale', name: 'LoveRecordApp');
                    final initialScreen = _getInitialScreen();
                    developer.log('🏠 初始屏幕: ${initialScreen.runtimeType}', name: 'LoveRecordApp');
                    
                    return MaterialApp(
                      key: ValueKey('app_${state.hashCode}_${locale.hashCode}'),
                      title: 'LoveRecord',
                      debugShowCheckedModeBanner: false,
                      theme: themeData,
                      themeMode: effectiveBrightness == Brightness.light 
                          ? ThemeMode.light 
                          : ThemeMode.dark,
                      locale: locale,
                      home: initialScreen,
                      routes: {
                        '/home': (context) => const HomeScreen(),
                        '/onboarding': (context) => const OnboardingScreen(),
                        '/settings': (context) => const SettingsScreen(),
                        '/create-record': (context) => const CreateRecordScreen(),
                        '/analytics': (context) => const AnalyticsScreen(),
                        '/test': (context) => const TestScreen(),
                      },
                      onGenerateRoute: (settings) {
                        try {
                          if (settings.name?.startsWith('/record/') == true) {
                            final recordId = settings.name!.substring(8);
                            return MaterialPageRoute(
                              builder: (context) => RecordDetailScreen(recordId: recordId),
                            );
                          }
                          return null;
                        } catch (e, stackTrace) {
                          developer.log(
                            '❌ 路由生成错误: $e',
                            name: 'LoveRecordApp',
                            error: e,
                            stackTrace: stackTrace,
                          );
                          return null;
                        }
                      },
                      localizationsDelegates: const [
                        AppLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      supportedLocales: AppLocalizations.supportedLocales,
                    );
                  } catch (e, stackTrace) {
                    developer.log(
                      '❌ MaterialApp构建错误: $e',
                      name: 'LoveRecordApp',
                      error: e,
                      stackTrace: stackTrace,
                    );
                    return _buildErrorApp('MaterialApp构建错误: $e');
                  }
                },
                loading: () {
                  developer.log('⏳ 语言加载中...', name: 'LoveRecordApp');
                  return MaterialApp(
                    locale: const Locale('zh', 'CN'),
                    theme: themeData,
                    home: const Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('正在加载语言设置...'),
                          ],
                        ),
                      ),
                    ),
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: AppLocalizations.supportedLocales,
                  );
                },
                error: (error, stack) {
                  developer.log(
                    '❌ 语言加载错误: $error',
                    name: 'LoveRecordApp',
                    error: error,
                    stackTrace: stack,
                  );
                  return _buildErrorApp('语言加载错误: $error');
                },
              );
            } catch (e, stackTrace) {
              developer.log(
                '❌ 主题构建错误: $e',
                name: 'LoveRecordApp',
                error: e,
                stackTrace: stackTrace,
              );
              return _buildErrorApp('主题构建错误: $e');
            }
          },
          loading: () {
            developer.log('⏳ 主题加载中...', name: 'LoveRecordApp');
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('正在加载主题设置...'),
                    ],
                  ),
                ),
              ),
            );
          },
          error: (error, stack) {
            developer.log(
              '❌ 主题加载错误: $error',
              name: 'LoveRecordApp',
              error: error,
              stackTrace: stack,
            );
            return _buildErrorApp('主题加载错误: $error');
          },
        ),
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ LoveRecordApp构建错误: $e',
        name: 'LoveRecordApp',
        error: e,
        stackTrace: stackTrace,
      );
      return _buildErrorApp('应用构建错误: $e');
    }
  }

  /// 构建错误显示应用
  MaterialApp _buildErrorApp(String errorMessage) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  '应用启动错误',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // 重启应用
                    main();
                  },
                  child: const Text('重新启动'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getInitialScreen() {
    try {
      developer.log('🏠 检查初始屏幕...', name: 'LoveRecordApp');
      final isFirstLaunch = SettingsService.isFirstLaunch;
      developer.log('🏠 是否首次启动: $isFirstLaunch', name: 'LoveRecordApp');
      
      if (isFirstLaunch) {
        developer.log('🏠 返回引导屏幕', name: 'LoveRecordApp');
        return const OnboardingScreen();
      }
      developer.log('🏠 返回主屏幕', name: 'LoveRecordApp');
      return const HomeScreen();
    } catch (e, stackTrace) {
      developer.log(
        '❌ 获取初始屏幕错误: $e',
        name: 'LoveRecordApp',
        error: e,
        stackTrace: stackTrace,
      );
      // 默认返回主屏幕
      return const HomeScreen();
    }
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
