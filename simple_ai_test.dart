import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  // 从.env文件读取API Key
  String? apiKey;
  try {
    final envFile = File('.env');
    if (await envFile.exists()) {
      final content = await envFile.readAsString();
      final lines = content.split('\n');
      for (final line in lines) {
        if (line.startsWith('AI_API_KEY=')) {
          apiKey = line.substring('AI_API_KEY='.length).trim();
          break;
        }
      }
    }
  } catch (e) {
    print('❌ 无法读取.env文件: $e');
    exit(1);
  }

  if (apiKey == null || apiKey.isEmpty) {
    print('❌ 错误: 未找到AI_API_KEY');
    print('请确保.env文件中配置了正确的API Key');
    exit(1);
  }

  print('🔧 正在测试DashScope AI服务连接...');
  print('API Key: ${apiKey.substring(0, 8)}...');

  final dio = Dio();
  dio.options.baseUrl = 'https://dashscope.aliyuncs.com';
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 60);
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
    'X-DashScope-SSE': 'disable',
  };

  try {
    print('📡 测试连接...');
    final response = await dio.post(
      '/api/v1/services/aigc/text-generation/generation',
      data: {
        'model': 'qwen-turbo',
        'input': {
          'messages': [
            {'role': 'user', 'content': '你好，请回复"连接测试成功"'}
          ]
        },
        'parameters': {
          'max_tokens': 20,
          'temperature': 0.1,
        },
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['output'] != null) {
        // DashScope API 返回格式: {output: {text: "回复内容"}}
        if (data['output']['text'] != null) {
          print('✅ AI服务连接成功！');
          print('AI回复: ${data['output']['text']}');
          print('🎉 qwen-turbo模型可以正常使用！');
          return;
        }
        // 兼容旧格式
        if (data['output']['choices'] != null) {
          final choices = data['output']['choices'] as List;
          if (choices.isNotEmpty && choices[0]['message'] != null) {
            print('✅ AI服务连接成功！');
            print('AI回复: ${choices[0]['message']['content']}');
            print('🎉 qwen-turbo模型可以正常使用！');
            return;
          }
        }
      }
    }
    
    print('❌ AI服务响应格式异常');
    print('响应: ${response.data}');
  } catch (e) {
    if (e is DioException) {
      print('❌ 连接失败: ${e.type}');
      if (e.response != null) {
        print('状态码: ${e.response!.statusCode}');
        print('错误信息: ${e.response!.data}');
      } else {
        print('网络错误: ${e.message}');
      }
    } else {
      print('❌ 测试失败: $e');
    }
    exit(1);
  }
}