import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business_logic/providers/record_provider.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../widgets/enhanced_ai_features.dart';
import '../widgets/loading_widget.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsNotifierProvider);
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '情感分析',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(recordsNotifierProvider);
            },
          ),
        ],
      ),
      body: recordsAsync.when(
        data: (records) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                MoodTrackerWidget(
                  onMoodSubmitted: (mood, intensity) {
                    // TODO: Save mood data
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('心情已记录: $mood (强度: ${intensity.toInt()})'),
                        backgroundColor: Theme.of(context).brightness == Brightness.dark 
                            ? const Color(0xFF424242) 
                            : const Color(0xFFF5F5F5),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                EnhancedAIFeaturesWidget(records: records),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text('加载失败: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(recordsNotifierProvider);
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}