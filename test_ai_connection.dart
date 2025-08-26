import 'dart:io';
import 'lib/services/ai/dashscope_service.dart';
import 'lib/core/config/env_config.dart';

void main() async {
  // 初始化环境配置
  await EnvConfig.initialize();
  
  // 从环境变量获取API Key
  final apiKey = EnvConfig.getString('AI_API_KEY');
  
  if (apiKey.isEmpty) {
    print('❌ 错误: 未找到AI_API_KEY环境变量');
    print('请确保.env文件中配置了正确的API Key');
    exit(1);
  }
  
  print('🔧 正在测试DashScope AI服务连接...');
  print('API Key: ${apiKey.substring(0, 8)}...');
  
  try {
    final aiService = DashScopeService(apiKey: apiKey);
    
    // 测试连接
    print('📡 测试连接...');
    final connectionResult = await aiService.testConnection();
    
    if (connectionResult) {
      print('✅ AI服务连接成功！');
      
      // 测试文本生成
      print('🤖 测试文本生成...');
      final response = await aiService.generateText('你好，请简单介绍一下你自己');
      print('AI回复: $response');
      
      print('🎉 所有测试通过！AI服务可以正常使用。');
    } else {
      print('❌ AI服务连接失败');
    }
  } catch (e) {
    print('❌ 测试失败: $e');
    exit(1);
  }
}