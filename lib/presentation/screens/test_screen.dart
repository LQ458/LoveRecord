import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../../business_logic/providers/locale_provider.dart';
import '../../presentation/themes/romantic_themes.dart';

class TestScreen extends ConsumerWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final localeState = ref.watch(localeNotifierProvider);
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '主题和语言测试',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          Text('主题颜色: ${RomanticThemes.getTheme(state.romanticTheme).name}'),
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
                      data: (locale) => Text('语言: ${locale.languageCode}_${locale.countryCode}'),
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
                            ref.read(themeNotifierProvider.notifier).changeRomanticTheme(theme);
                          },
                          child: Text(theme.displayName),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final themeState = ref.read(themeNotifierProvider).valueOrNull;
                        if (themeState != null) {
                          final newMode = themeState.brightnessMode == ThemeBrightnessMode.dark 
                              ? ThemeBrightnessMode.light 
                              : ThemeBrightnessMode.dark;
                          ref.read(themeNotifierProvider.notifier).setBrightnessMode(newMode);
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
                            ref.read(localeNotifierProvider.notifier).changeLocale('zh_CN');
                          },
                          child: const Text('中文'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(localeNotifierProvider.notifier).changeLocale('en_US');
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
                    Text(
                      '测试文本',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
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