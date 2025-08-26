import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  print('🔧 正在测试中国AI服务连接...\n');
  
  // 从环境文件读取配置
  final envFile = File('.env');
  final config = <String, String>{};
  
  if (await envFile.exists()) {
    final lines = await envFile.readAsLines();
    for (final line in lines) {
      if (line.contains('=') && !line.startsWith('#')) {
        final parts = line.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();
          config[key] = value;
        }
      }
    }
  } else {
    print('❌ 未找到.env文件，请创建.env文件并配置API密钥');
    exit(1);
  }
  
  bool allTestsPassed = true;
  
  // 测试DashScope
  await testDashScope(config) ? null : allTestsPassed = false;
  
  print('\n' + '='*50 + '\n');
  
  // 测试Baidu ERNIE
  await testBaiduErnie(config) ? null : allTestsPassed = false;
  
  print('\n' + '='*50 + '\n');
  
  if (allTestsPassed) {
    print('🎉 所有AI服务测试通过！');
  } else {
    print('⚠️ 部分AI服务测试失败，请检查配置');
  }
}

Future<bool> testDashScope(Map<String, String> config) async {
  print('📱 测试DashScope (通义千问 Turbo) API...');
  
  final apiKey = config['DASHSCOPE_API_KEY'] ?? config['AI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ 未找到DASHSCOPE_API_KEY或AI_API_KEY，跳过测试');
    return false;
  }
  
  print('🔑 API Key: ${apiKey.substring(0, 8)}...');
  
  try {
    final dio = Dio();
    dio.options.baseUrl = 'https://dashscope.aliyuncs.com';
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 60);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer \$apiKey',
      'X-DashScope-SSE': 'disable',
    };
    
    // 测试连接
    print('📡 测试连接...');
    
    final requestData = {
      'model': 'qwen-turbo',
      'input': {
        'messages': [
          {'role': 'user', 'content': '你好，请回复"连接测试成功"'}
        ],
      },
      'parameters': {
        'result_format': 'message',
        'incremental_output': false,
        'max_tokens': 20,
        'temperature': 0.1,
        'top_p': 0.8,
      },
    };
    
    final response = await dio.post(
      '/api/v1/services/aigc/text-generation/generation',
      data: requestData,
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    
    print('📊 响应状态: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('✅ DashScope连接成功！');
      
      // 尝试提取响应内容
      final data = response.data;
      String? content;
      
      if (data['output'] != null) {
        final output = data['output'];
        if (output['choices'] != null) {
          final choices = output['choices'] as List?;
          if (choices != null && choices.isNotEmpty) {
            final firstChoice = choices[0] as Map<String, dynamic>?;
            if (firstChoice != null && firstChoice['message'] != null) {
              final message = firstChoice['message'] as Map<String, dynamic>?;
              if (message != null && message['content'] != null) {
                content = message['content'].toString().trim();
              }
            }
          }
        } else if (output['text'] != null) {
          content = output['text'].toString().trim();
        }
      }
      
      if (content != null && content.isNotEmpty) {
        print('🤖 AI回复: \$content');
        print('🎉 DashScope功能测试通过！');
        return true;
      } else {
        print('⚠️ 响应格式异常: ${data}');
        return false;
      }
    } else if (response.statusCode == 401) {
      print('❌ API Key无效或已过期');
      return false;
    } else {
      print('❌ 连接失败: HTTP ${response.statusCode}');
      if (response.data != null) {
        print('错误详情: ${response.data}');
      }
      return false;
    }
  } catch (e) {
    print('❌ DashScope测试异常: \$e');
    return false;
  }
}

Future<bool> testBaiduErnie(Map<String, String> config) async {
  print('🤖 测试Baidu ERNIE Bot API...');
  
  final clientId = config['BAIDU_CLIENT_ID'];
  final clientSecret = config['BAIDU_CLIENT_SECRET'];
  
  if (clientId == null || clientSecret == null || 
      clientId.isEmpty || clientSecret.isEmpty) {
    print('❌ 未找到BAIDU_CLIENT_ID或BAIDU_CLIENT_SECRET，跳过测试');
    return false;
  }
  
  print('🔑 Client ID: ${clientId.substring(0, 8)}...');
  
  try {
    final dio = Dio();
    dio.options.baseUrl = 'https://aip.baidubce.com';
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 60);
    
    // 第一步：获取访问令牌
    print('🔐 获取访问令牌...');
    
    final formData = 'grant_type=client_credentials&client_id=\$clientId&client_secret=\$clientSecret';
    
    final tokenResponse = await dio.post(
      '/oauth/2.0/token',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    
    print('🔑 令牌响应状态: ${tokenResponse.statusCode}');
    
    if (tokenResponse.statusCode == 200) {
      final tokenData = tokenResponse.data;
      if (tokenData['access_token'] != null) {
        final accessToken = tokenData['access_token'];
        print('✅ 成功获取访问令牌');
        
        // 第二步：测试文本生成
        print('📡 测试文本生成...');
        
        final chatResponse = await dio.post(
          '/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/ernie-bot-turbo',
          queryParameters: {'access_token': accessToken},
          data: {
            'messages': [
              {'role': 'user', 'content': '你好，请回复"连接测试成功"'}
            ],
            'temperature': 0.95,
            'top_p': 0.8,
            'penalty_score': 1.0,
            'system': '你是ERNIE Bot，由百度开发的大语言模型。',
          },
          options: Options(
            validateStatus: (status) => status != null && status < 500,
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );
        
        print('📊 聊天响应状态: ${chatResponse.statusCode}');
        
        if (chatResponse.statusCode == 200) {
          final data = chatResponse.data;
          if (data['result'] != null) {
            final result = data['result'];
            print('🤖 AI回复: \$result');
            print('✅ ERNIE Bot连接成功！');
            print('🎉 ERNIE Bot功能测试通过！');
            return true;
          } else {
            print('⚠️ 响应格式异常: \$data');
            return false;
          }
        } else {
          print('❌ 文本生成失败: HTTP ${chatResponse.statusCode}');
          if (chatResponse.data != null) {
            print('错误详情: ${chatResponse.data}');
          }
          return false;
        }
      } else {
        print('❌ 令牌响应格式错误: ${tokenData}');
        return false;
      }
    } else if (tokenResponse.statusCode == 401) {
      print('❌ Client ID或Client Secret无效');
      return false;
    } else {
      print('❌ 获取访问令牌失败: HTTP ${tokenResponse.statusCode}');
      if (tokenResponse.data != null) {
        print('错误详情: ${tokenResponse.data}');
      }
      return false;
    }
  } catch (e) {
    print('❌ ERNIE Bot测试异常: \$e');
    return false;
  }
}