import 'dart:io';
import 'lib/services/ai/dashscope_service.dart';
import 'lib/services/ai/ernie_bot_service.dart';
import 'lib/core/config/env_config.dart';

void main() async {
  print('🔧 正在测试所有中国AI服务连接...\n');
  
  // 初始化环境配置
  await EnvConfig.initialize();
  
  bool allTestsPassed = true;
  
  // 测试DashScope (Qwen Turbo)
  await testDashScope() ? null : allTestsPassed = false;
  
  print('\n' + '='*50 + '\n');
  
  // 测试Baidu ERNIE Bot
  await testBaiduErnie() ? null : allTestsPassed = false;
  
  print('\n' + '='*50 + '\n');
  
  if (allTestsPassed) {
    print('🎉 所有AI服务测试通过！');
  } else {
    print('⚠️ 部分AI服务测试失败，请检查配置');
  }
}

Future<bool> testDashScope() async {
  print('📱 测试DashScope (通义千问 Turbo) API...');
  
  final apiKey = EnvConfig.getString('DASHSCOPE_API_KEY');
  if (apiKey.isEmpty) {
    print('❌ 未找到DASHSCOPE_API_KEY，跳过测试');
    return false;
  }
  
  print('🔑 API Key: ${apiKey.substring(0, 8)}...');
  
  try {
    final service = DashScopeService(apiKey: apiKey);
    
    // 测试连接
    print('📡 测试连接...');
    final connectionResult = await service.testConnection();
    
    if (connectionResult) {
      print('✅ DashScope连接成功！');
      
      // 测试文本生成
      print('🤖 测试文本生成...');
      final response = await service.generateText('请用一句话介绍通义千问');
      print('AI回复: $response');
      
      // 测试内容分析
      print('🔍 测试内容分析...');
      final analysis = await service.analyzeContent('今天天气很好，我去公园散步了，心情特别愉快');
      print('分析结果: 分类=${analysis.categories}, 关键词=${analysis.keywords}');
      
      print('🎉 DashScope所有功能测试通过！');
      return true;
    } else {
      print('❌ DashScope连接失败');
      return false;
    }
  } catch (e) {
    print('❌ DashScope测试异常: $e');
    return false;
  }
}

Future<bool> testBaiduErnie() async {
  print('🤖 测试Baidu ERNIE Bot API...');
  
  final clientId = EnvConfig.getString('BAIDU_CLIENT_ID');
  final clientSecret = EnvConfig.getString('BAIDU_CLIENT_SECRET');
  
  if (clientId.isEmpty || clientSecret.isEmpty) {
    print('❌ 未找到BAIDU_CLIENT_ID或BAIDU_CLIENT_SECRET，跳过测试');
    return false;
  }
  
  print('🔑 Client ID: ${clientId.substring(0, 8)}...');
  
  try {
    final service = ErnieBotService(
      apiKey: clientId,
      clientSecret: clientSecret,
    );
    
    // 测试连接
    print('📡 测试连接...');
    final connectionResult = await service.testConnection();
    
    if (connectionResult) {
      print('✅ ERNIE Bot连接成功！');
      
      // 测试文本生成
      print('🤖 测试文本生成...');
      final response = await service.generateText('请用一句话介绍文心一言');
      print('AI回复: $response');
      
      // 测试内容分析
      print('🔍 测试内容分析...');
      final analysis = await service.analyzeContent('今天完成了一个重要的项目，团队合作很顺利');
      print('分析结果: 分类=${analysis.categories}, 关键词=${analysis.keywords}');
      
      print('🎉 ERNIE Bot所有功能测试通过！');
      return true;
    } else {
      print('❌ ERNIE Bot连接失败');
      return false;
    }
  } catch (e) {
    print('❌ ERNIE Bot测试异常: $e');
    return false;
  }
}