import 'ai_service.dart';
import 'ernie_bot_service.dart';
import '../../data/local/settings_service.dart';

class AiServiceFactory {
  static AIService createService(String provider) {
    final apiKey = SettingsService.apiKey ?? '';
    final secretKey = SettingsService.secretKey ?? '';
    
    switch (provider) {
      case 'ernie_bot':
        if (apiKey.isEmpty || secretKey.isEmpty) {
          throw Exception('API Key和Secret Key不能为空');
        }
        return ErnieBotService(
          apiKey: apiKey,
          secretKey: secretKey,
        );
      case 'openai':
        // TODO: 实现OpenAI服务
        throw UnimplementedError('OpenAI服务尚未实现');
      case 'claude':
        // TODO: 实现Claude服务
        throw UnimplementedError('Claude服务尚未实现');
      default:
        if (apiKey.isEmpty || secretKey.isEmpty) {
          throw Exception('API Key和Secret Key不能为空');
        }
        return ErnieBotService(
          apiKey: apiKey,
          secretKey: secretKey,
        );
    }
  }
} 