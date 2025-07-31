import 'ernie_bot_service.dart';
import 'mock_ai_service.dart';
import 'ai_service.dart';

class AiServiceFactory {
  static AIService createService(String provider, {
    String? apiKey,
    String? clientSecret,
  }) {
    switch (provider) {
      case 'ernie_bot':
        if (apiKey == null || apiKey.isEmpty) {
          throw Exception('文心一言需要提供API Key（Client ID）');
        }
        return ErnieBotService(apiKey: apiKey, clientSecret: clientSecret);
        
      case 'mock':
        return MockAIService();
        
      // 其他AI服务提供商...
      default:
        throw Exception('不支持的AI服务提供商: $provider');
    }
  }

  static AIService createServiceFromConfig(Map<String, dynamic> config) {
    final provider = config['provider'] as String;
    final apiKey = config['apiKey'] as String?;
    final clientSecret = config['clientSecret'] as String?;

    return createService(provider, apiKey: apiKey, clientSecret: clientSecret);
  }

  static List<String> getSupportedProviders() {
    return [
      'ernie_bot', // 文心一言
      'mock',      // 模拟AI服务
      // 其他提供商...
    ];
  }

  static String getProviderDisplayName(String provider) {
    switch (provider) {
      case 'ernie_bot':
        return '文心一言';
      case 'mock':
        return '模拟AI服务（离线模式）';
      default:
        return provider;
    }
  }

  static String getProviderDescription(String provider) {
    switch (provider) {
      case 'ernie_bot':
        return '百度文心一言官方API，需要Client ID和Client Secret进行认证';
      case 'mock':
        return '模拟AI服务，用于离线测试和开发，无需网络连接';
      default:
        return '未知的AI服务提供商';
    }
  }
} 