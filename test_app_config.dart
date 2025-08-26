import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/core/config/env_config.dart';
import 'lib/data/local/settings_service.dart';
import 'lib/services/ai/ai_service_factory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== 测试应用配置加载 ===');
  
  // 初始化服务（模拟main.dart中的初始化过程）
  await Hive.initFlutter();
  await EnvConfig.initialize();
  await SettingsService.initialize();
  
  print('\n1. 环境配置状态:');
  print('EnvConfig.isInitialized: ${EnvConfig.isInitialized}');
  print('EnvConfig AI_PROVIDER: ${EnvConfig.getString('AI_PROVIDER')}');
  print('EnvConfig AI_API_KEY: ${EnvConfig.getString('AI_API_KEY').isNotEmpty ? "已配置(${EnvConfig.getString('AI_API_KEY').length}字符)" : "未配置"}');
  
  print('\n2. SettingsService初始状态:');
  print('SettingsService.aiProvider: ${SettingsService.aiProvider}');
  print('SettingsService.apiKey: ${SettingsService.apiKey?.isNotEmpty == true ? "已配置(${SettingsService.apiKey!.length}字符)" : "未配置"}');
  
  // 模拟main.dart中的配置加载逻辑
  final envApiKey = EnvConfig.getString('AI_API_KEY');
  final envProvider = EnvConfig.getString('AI_PROVIDER', defaultValue: 'dashscope');
  
  print('\n3. 从环境变量加载配置:');
  print('环境变量 AI_API_KEY: ${envApiKey.isNotEmpty ? "${envApiKey.substring(0, 8)}..." : "未配置"}');
  print('环境变量 AI_PROVIDER: $envProvider');
  
  if (envApiKey.isNotEmpty) {
    await SettingsService.setApiKey(envApiKey);
    print('✅ 已将API Key加载到SettingsService');
  }
  
  await SettingsService.setAiProvider(envProvider);
  print('✅ 已将AI提供商设置为: $envProvider');
  
  print('\n4. 最终配置状态:');
  print('SettingsService.aiProvider: ${SettingsService.aiProvider}');
  print('SettingsService.apiKey: ${SettingsService.apiKey?.isNotEmpty == true ? "已配置(${SettingsService.apiKey!.length}字符)" : "未配置"}');
  
  // 测试AI服务创建
  print('\n5. 测试AI服务创建:');
  try {
    final provider = SettingsService.aiProvider;
    final apiKey = SettingsService.apiKey;
    
    if (apiKey != null && apiKey.isNotEmpty) {
      final aiService = AiServiceFactory.createService(provider, apiKey: apiKey);
      print('✅ AI服务创建成功: ${aiService.runtimeType}');
      
      // 测试连接
      print('\n6. 测试AI服务连接:');
      final connectionResult = await aiService.testConnection();
      print('连接测试结果: ${connectionResult ? "✅ 成功" : "❌ 失败"}');
      
      if (connectionResult) {
        print('\n7. 测试文本生成:');
        final response = await aiService.generateText('你好，请回复"测试成功"');
        print('AI回复: $response');
        print('\n🎉 所有测试通过！应用内AI服务应该可以正常工作。');
      }
    } else {
      print('❌ API Key未配置，无法创建AI服务');
    }
  } catch (e) {
    print('❌ AI服务测试失败: $e');
  }
}