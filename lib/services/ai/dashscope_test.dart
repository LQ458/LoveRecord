import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class DashScopeTest {
  static Future<bool> testApiKey(String apiKey) async {
    final dio = Dio();
    
    // Set timeouts on the Dio instance
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    
    try {
      developer.log('Testing DashScope API with key: ${apiKey.substring(0, 8)}...', name: 'DashScopeTest');
      
      // Use a simpler endpoint for testing
      final response = await dio.post(
        'https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation',
        data: {
          'model': 'qwen-turbo', // Use qwen-turbo for faster response
          'input': {
            'messages': [
              {'role': 'user', 'content': '测试'}
            ]
          },
          'parameters': {
            'result_format': 'message', // 确保使用消息格式
            'max_tokens': 5,
            'temperature': 0.1,
            'incremental_output': false, // 非流式响应
          },
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          validateStatus: (status) => true, // Accept all status codes
        ),
      );
      
      developer.log('Response status: ${response.statusCode}', name: 'DashScopeTest');
      
      if (response.statusCode == 200) {
        final data = response.data;
        developer.log('Response data: ${jsonEncode(data)}', name: 'DashScopeTest');
        
        // 检查 2024年DashScope API 标准响应结构: data['output']['choices'][0]['message']['content']
        if (data['output'] != null && data['output']['choices'] != null) {
          final choices = data['output']['choices'] as List;
          if (choices.isNotEmpty) {
            final choice = choices[0];
            if (choice['message'] != null && choice['message']['content'] != null) {
              final content = choice['message']['content'].toString();
              developer.log('API test successful! Response: $content', name: 'DashScopeTest');
              return true;
            } else {
              developer.log('Response missing message.content field', name: 'DashScopeTest');
            }
          } else {
            developer.log('Response choices array is empty', name: 'DashScopeTest');
          }
        } else {
          developer.log('Response missing output.choices structure', name: 'DashScopeTest');
        }
      } else if (response.statusCode == 401) {
        developer.log('API Key invalid (401)', name: 'DashScopeTest');
        throw Exception('API Key无效，请检查密钥是否正确');
      } else if (response.statusCode == 403) {
        developer.log('API access forbidden (403)', name: 'DashScopeTest');
        final errorData = response.data;
        if (errorData != null && errorData['code'] == 'Arrearage') {
          throw Exception('账户余额不足或状态异常\n\n请检查:\n• 阿里云账户余额是否充足\n• 是否完成实名认证\n• DashScope服务是否已开通\n\n请访问: https://dashscope.console.aliyun.com/');
        } else {
          throw Exception('API访问被拒绝，请检查账户状态和权限');
        }
      } else {
        developer.log('API error: ${response.statusCode} - ${response.data}', name: 'DashScopeTest');
        final errorData = response.data;
        if (errorData != null && errorData['message'] != null) {
          throw Exception('API错误: ${errorData['message']}');
        } else {
          throw Exception('API错误: ${response.statusCode}');
        }
      }
      
      return false;
    } on DioException catch (e) {
      developer.log('Network error: ${e.type} - ${e.message}', name: 'DashScopeTest');
      
      switch (e.type) {
        case DioExceptionType.connectionError:
          throw Exception('网络连接失败，请检查网络连接');
        case DioExceptionType.connectionTimeout:
          throw Exception('连接超时，请检查网络或稍后重试');
        case DioExceptionType.receiveTimeout:
          throw Exception('响应超时，服务器响应缓慢');
        default:
          throw Exception('网络请求失败: ${e.message}');
      }
    } catch (e) {
      developer.log('Test failed with exception: $e', name: 'DashScopeTest');
      throw Exception('测试失败: $e');
    }
  }
}