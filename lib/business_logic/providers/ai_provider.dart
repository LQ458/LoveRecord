import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../services/ai/ai_service.dart';
import '../../services/ai/ai_service_factory.dart';
import '../../data/local/settings_service.dart';
import '../../core/config/app_config.dart';

part 'ai_provider.g.dart';

@riverpod
AIService? aiService(AiServiceRef ref) {
  // 优先使用用户设置，如果没有设置则使用环境配置
  final provider = SettingsService.aiProvider.isNotEmpty 
      ? SettingsService.aiProvider 
      : AppConfig.defaultAiProvider;
  
  if (provider == 'mock') {
    return AiServiceFactory.createService('mock');
  }
  
  // 根据不同AI提供商获取相应的API凭证
  String? apiKey;
  String? clientSecret;
  
  switch (provider) {
    case 'dashscope':
      // DashScope 使用 DASHSCOPE_API_KEY 或 AI_API_KEY
      apiKey = SettingsService.apiKey?.isNotEmpty == true 
          ? SettingsService.apiKey! 
          : (AppConfig.getDashScopeApiKey().isNotEmpty ? AppConfig.getDashScopeApiKey() : AppConfig.aiApiKey);
      break;
    case 'ernie_bot':
      // Baidu ERNIE Bot 使用 Client ID 和 Client Secret
      apiKey = AppConfig.getBaiduClientId();
      clientSecret = AppConfig.getBaiduClientSecret();
      break;
    default:
      // 默认使用 AI_API_KEY
      apiKey = SettingsService.apiKey?.isNotEmpty == true 
          ? SettingsService.apiKey! 
          : AppConfig.aiApiKey;
  }
  
  if (apiKey.isNotEmpty) {
    try {
      return AiServiceFactory.createService(provider, apiKey: apiKey, clientSecret: clientSecret);
    } catch (e) {
      // 如果创建服务失败，返回null
      return null;
    }
  }
  
  // 如果没有配置API Key，返回null
  return null;
}

@riverpod
class AIServiceNotifier extends _$AIServiceNotifier {
  @override
  AIService? build() {
    return ref.watch(aiServiceProvider);
  }

  /// 测试AI服务连接
  Future<bool> testConnection() async {
    final service = state;
    if (service == null) {
      throw Exception('AI服务未配置\n\n请在设置中配置AI服务的API Key');
    }
    return await service.testConnection();
  }

  /// 分析内容
  Future<ContentAnalysis> analyzeContent(String content) async {
    final service = state;
    if (service == null) {
      throw Exception('AI服务未配置\n\n请在设置中配置AI服务的API Key');
    }
    return await service.analyzeContent(content);
  }

  /// 分析情感
  Future<EmotionAnalysis> analyzeEmotion(String content) async {
    final service = state;
    if (service == null) {
      throw Exception('AI服务未配置\n\n请在设置中配置AI服务的API Key');
    }
    return await service.analyzeEmotion(content);
  }

  /// 生成摘要
  Future<String> generateSummary(String content) async {
    final service = state;
    if (service == null) {
      throw Exception('AI服务未配置\n\n请在设置中配置AI服务的API Key');
    }
    return await service.generateSummary(content);
  }

  /// 提取关键词
  Future<List<String>> extractKeywords(String content) async {
    final service = state;
    if (service == null) {
      throw Exception('AI服务未配置\n\n请在设置中配置AI服务的API Key');
    }
    return await service.extractKeywords(content);
  }

  /// 生成标题建议
  Future<List<String>> generateTitleSuggestions(String content) async {
    final service = state;
    if (service == null) {
      throw Exception('AI服务未配置\n\n请在设置中配置AI服务的API Key');
    }
    return await service.generateTitleSuggestions(content);
  }

  /// 聊天对话
  Future<String> chat(String message, List<String> context) async {
    final service = state;
    if (service == null) {
      throw Exception('AI服务未配置\n\n请在设置中配置AI服务的API Key');
    }
    return await service.chat(message, context);
  }

  /// 分析图片
  Future<String> analyzeImage(String imagePath) async {
    final service = state;
    if (service == null) {
      throw Exception('AI服务未配置\n\n请在设置中配置AI服务的API Key');
    }
    return await service.analyzeImage(imagePath);
  }

  /// 生成文本
  Future<String> generateText(String prompt) async {
    final service = state;
    if (service == null) {
      throw Exception('AI服务未配置\n\n请在设置中配置AI服务的API Key');
    }
    return await service.generateText(prompt);
  }
}