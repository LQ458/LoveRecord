import 'dashscope_service.dart';
import 'ernie_bot_service.dart'; // Re-enabled with improved international access
import 'openai_service.dart';
import 'mock_ai_service.dart';
import 'ai_service.dart';

class AiServiceFactory {
  static AIService createService(String provider, {
    String? apiKey,
    String? clientSecret,
  }) {
    switch (provider) {
      case 'dashscope':
        if (apiKey == null || apiKey.isEmpty) {
          throw Exception('DashScope (通义千问) 需要提供API Key');
        }
        return DashScopeService(apiKey: apiKey);
        
      case 'ernie_bot':
        if (apiKey == null || apiKey.isEmpty) {
          throw Exception('文心一言需要提供API Key（Client ID）');
        }
        return ErnieBotService(apiKey: apiKey, clientSecret: clientSecret);
        
      case 'openai':
        if (apiKey == null || apiKey.isEmpty) {
          throw Exception('OpenAI 需要提供API Key');
        }
        return OpenAIService(apiKey: apiKey);
        
      case 'mock':
        return MockAIService();
        
      // 其他AI服务提供商...
      default:
        return MockAIService(); // Default to mock service instead of throwing error
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
      'dashscope', // 通义千问 (推荐 - 阿里云国际版)
      'ernie_bot', // 文心一言 (百度)
      'openai',    // OpenAI GPT (国际)
      'mock',      // 模拟AI服务
      // 其他提供商...
    ];
  }

  static String getProviderDisplayName(String provider) {
    switch (provider) {
      case 'dashscope':
        return '通义千问 (DashScope)';
      case 'ernie_bot':
        return '文心一言 (ERNIE Bot)';
      case 'openai':
        return 'OpenAI GPT';
      case 'mock':
        return '模拟AI服务（离线模式）';
      default:
        return provider;
    }
  }

  static String getProviderDescription(String provider) {
    switch (provider) {
      case 'dashscope':
        return '阿里云通义千问官方API，国际版支持海外访问，中文理解能力强，仅需API Key';
      case 'ernie_bot':
        return '百度文心一言官方API，需要Client ID和Client Secret进行认证';
      case 'openai':
        return 'OpenAI GPT 官方API，全球访问无障碍，只需API Key即可使用';
      case 'mock':
        return '模拟AI服务，用于离线测试和开发，无需网络连接';
      default:
        return '未知的AI服务提供商';
    }
  }
} 