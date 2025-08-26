import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../../business_logic/providers/locale_provider.dart';
import '../../business_logic/providers/ai_provider.dart';
import '../../presentation/themes/romantic_themes.dart';
import '../../core/config/app_config.dart';
import '../../data/local/settings_service.dart';
import '../../services/ai/ai_service_factory.dart';

class TestScreen extends ConsumerWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final localeState = ref.watch(localeNotifierProvider);
    final aiService = ref.watch(aiServiceProvider);
    final aiNotifier = ref.watch(aIServiceNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '系统测试',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI服务测试
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI服务测试',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('AI提供商: ${AppConfig.aiProvider}'),
                    Text(
                      'API Key: ${AppConfig.aiApiKey.isNotEmpty ? "已配置" : "未配置"}',
                    ),
                    Text('服务状态: ${aiService != null ? "已初始化" : "未初始化"}'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('正在测试网络连接...')),
                              );

                              // 先测试基本网络连接
                              final dio = Dio();
                              final response = await dio.get(
                                'https://www.baidu.com',
                              );
                              print('网络测试 - 百度连接状态: ${response.statusCode}');

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '网络连接正常 (${response.statusCode})',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              print('网络测试失败: $e');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('网络连接失败: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('测试网络'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: aiService != null
                              ? () async {
                                  try {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('正在测试AI连接...'),
                                      ),
                                    );
                                    final result = await aiNotifier
                                        .testConnection();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            result ? 'AI连接测试成功！' : 'AI连接测试失败',
                                          ),
                                          backgroundColor: result
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('AI连接测试失败: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              : null,
                          child: const Text('测试连接'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('正在使用工厂方法测试AI服务...'),
                                ),
                              );

                              // 直接使用工厂方法创建服务，就像create_record_screen.dart中一样
                              final provider = SettingsService.aiProvider;
                              final apiKey = SettingsService.apiKey;

                              print('测试页面 - Provider: $provider');
                              print(
                                '测试页面 - API Key: ${apiKey?.isNotEmpty == true ? "已配置" : "未配置"}',
                              );

                              if (apiKey == null || apiKey.isEmpty) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'API Key未配置\n\nProvider: $provider\nAPI Key: 未配置',
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                }
                                return;
                              }

                              final aiService = AiServiceFactory.createService(
                                provider,
                                apiKey: apiKey,
                              );
                              final result = await aiService.generateText(
                                '你好，请简单介绍一下你自己',
                              );

                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('AI生成结果'),
                                    content: SingleChildScrollView(
                                      child: Text(result),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('确定'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('AI文本生成失败: $e'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('直接测试AI'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 当前主题信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前主题信息',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    themeState.when(
                      data: (state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('浪漫主题: ${state.romanticTheme.displayName}'),
                          Text('亮度模式: ${state.brightnessMode.displayName}'),
                          Text(
                            '主题颜色: ${RomanticThemes.getTheme(state.romanticTheme).name}',
                          ),
                        ],
                      ),
                      loading: () => const Text('加载中...'),
                      error: (error, stack) => Text('错误: $error'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 当前语言信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前语言信息',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    localeState.when(
                      data: (locale) => Text(
                        '语言: ${locale.languageCode}_${locale.countryCode}',
                      ),
                      loading: () => const Text('加载中...'),
                      error: (error, stack) => Text('错误: $error'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 主题切换按钮
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '主题切换测试',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: RomanticTheme.values.map((theme) {
                        return ElevatedButton(
                          onPressed: () {
                            ref
                                .read(themeNotifierProvider.notifier)
                                .changeRomanticTheme(theme);
                          },
                          child: Text(theme.displayName),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final themeState = ref
                            .read(themeNotifierProvider)
                            .valueOrNull;
                        if (themeState != null) {
                          final newMode =
                              themeState.brightnessMode ==
                                  ThemeBrightnessMode.dark
                              ? ThemeBrightnessMode.light
                              : ThemeBrightnessMode.dark;
                          ref
                              .read(themeNotifierProvider.notifier)
                              .setBrightnessMode(newMode);
                        }
                      },
                      child: const Text('切换深色/浅色模式'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 语言切换按钮
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '语言切换测试',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(localeNotifierProvider.notifier)
                                .changeLocale('zh_CN');
                          },
                          child: const Text('中文'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(localeNotifierProvider.notifier)
                                .changeLocale('en_US');
                          },
                          child: const Text('English'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 测试文本
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('测试文本', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      '这是一段测试文本，用于验证主题切换效果。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is a test text to verify theme switching effects.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
