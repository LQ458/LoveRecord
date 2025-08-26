import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'ai_service.dart';

class OpenAIService implements AIService {
  final String apiKey;
  final Dio _dio;
  static const int _maxRetries = 3;

  OpenAIService({required this.apiKey}) : _dio = Dio() {
    // OpenAI API configuration (2024 - excellent international access)
    _dio.options.baseUrl = 'https://api.openai.com/v1';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    
    // OpenAI API headers
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
      'User-Agent': 'LoveRecord/1.0.0 (Flutter; macOS)',
    };
    
    // Add retry interceptor for reliability
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.requestOptions.extra['retryCount'] == null) {
          error.requestOptions.extra['retryCount'] = 0;
        }
        
        int retryCount = error.requestOptions.extra['retryCount'];
        
        if (retryCount < _maxRetries && 
            (error.type == DioExceptionType.connectionError ||
             error.type == DioExceptionType.connectionTimeout ||
             error.type == DioExceptionType.receiveTimeout)) {
          
          retryCount++;
          error.requestOptions.extra['retryCount'] = retryCount;
          
          developer.log('重试请求 ($retryCount/$_maxRetries): ${error.requestOptions.path}', 
                       name: 'OpenAIService');
          
          // Retry with exponential backoff
          await Future.delayed(Duration(milliseconds: 1000 * retryCount));
          
          try {
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
          } catch (e) {
            handler.next(error);
          }
        } else {
          handler.next(error);
        }
      },
    ));
  }

  @override
  Future<bool> testConnection() async {
    try {
      developer.log('测试OpenAI API连接...', name: 'OpenAIService');
      
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': 'Hello, please respond with "Connection test successful"'}
          ],
          'max_tokens': 50,
          'temperature': 0.1,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      developer.log('OpenAI API响应: ${response.statusCode}', name: 'OpenAIService');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          developer.log('OpenAI API连接测试成功', name: 'OpenAIService');
          return true;
        }
      }
      
      return false;
    } on DioException catch (e) {
      developer.log('OpenAI连接测试失败: ${e.type} - ${e.message}', name: 'OpenAIService');
      
      if (e.response?.statusCode == 401) {
        throw Exception('OpenAI API Key 无效\n\n请检查:\n• API Key是否正确\n• API Key是否有足够的使用配额\n• API Key权限是否正确');
      } else if (e.response?.statusCode == 429) {
        throw Exception('API调用频率限制\n\n请稍后重试，或升级您的OpenAI账户计划');
      } else if (e.response?.statusCode == 403) {
        throw Exception('API访问被拒绝\n\n可能原因:\n• 账户余额不足\n• API Key权限不足\n• 地区访问限制');
      } else {
        throw Exception('网络连接错误\n\n${_getNetworkErrorMessage(e)}');
      }
    } catch (e) {
      developer.log('OpenAI连接测试异常: $e', name: 'OpenAIService');
      throw Exception('连接测试失败：$e');
    }
  }

  @override
  Future<String> generateText(String prompt) async {
    try {
      developer.log('开始OpenAI文本生成...', name: 'OpenAIService');
      
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'gpt-3.5-turbo', // Cost-effective and reliable
          'messages': [
            {'role': 'system', 'content': '你是一个有用的AI助手，专门帮助用户管理和分析个人记录。请用中文回复。'},
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
          'top_p': 1,
          'frequency_penalty': 0,
          'presence_penalty': 0,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      developer.log('OpenAI文本生成响应: ${response.statusCode}', name: 'OpenAIService');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final message = data['choices'][0]['message'];
          if (message != null && message['content'] != null) {
            final result = message['content'].toString().trim();
            developer.log('OpenAI文本生成成功: ${result.length}字符', name: 'OpenAIService');
            return result;
          }
        }
        throw Exception('API响应格式错误：缺少content字段');
      } else if (response.statusCode == 401) {
        throw Exception('API Key无效或已过期');
      } else if (response.statusCode == 429) {
        throw Exception('API调用频率过高，请稍后重试');
      } else if (response.statusCode == 400) {
        final errorMsg = response.data?['error']?['message'] ?? '请求参数错误';
        throw Exception('请求错误：$errorMsg');
      } else {
        throw Exception('服务器错误：HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      developer.log('OpenAI文本生成DioException: ${e.type} - ${e.message}', name: 'OpenAIService');
      throw Exception(_getNetworkErrorMessage(e));
    } catch (e) {
      developer.log('OpenAI文本生成其他错误: $e', name: 'OpenAIService');
      throw Exception('生成文本时发生错误：$e');
    }
  }

  @override
  Future<ContentAnalysis> analyzeContent(String content) async {
    final prompt = '''
请分析以下内容，并返回JSON格式的分析结果：

内容：$content

请返回以下格式的JSON（不要包含其他文字，只返回JSON）：
{
  "categories": ["分类1", "分类2"],
  "keywords": ["关键词1", "关键词2", "关键词3"],
  "summary": "内容摘要",
  "confidence": 0.85
}

分类选项：工作笔记、生活记录、学习笔记、旅行日记、情感记录、健康管理、财务管理、创意想法
''';

    final result = await generateText(prompt);
    
    try {
      // 尝试从结果中提取JSON
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(result);
      if (jsonMatch != null) {
        final jsonData = jsonDecode(jsonMatch.group(0)!);
        return ContentAnalysis(
          categories: List<String>.from(jsonData['categories'] ?? []),
          keywords: List<String>.from(jsonData['keywords'] ?? []),
          summary: jsonData['summary'] ?? '',
          confidence: (jsonData['confidence'] ?? 0.0).toDouble(),
        );
      }
    } catch (e) {
      developer.log('JSON解析失败，使用默认分析: $e', name: 'OpenAIService');
    }

    // 默认返回
    return const ContentAnalysis(
      categories: ['未分类'],
      keywords: [],
      summary: '内容分析失败',
      confidence: 0.0,
    );
  }

  @override
  Future<List<String>> classifyContent(String content) async {
    final analysis = await analyzeContent(content);
    return analysis.categories;
  }

  @override
  Future<EmotionAnalysis> analyzeEmotion(String content) async {
    final prompt = '''
请分析以下内容的情感倾向，并返回JSON格式的结果（不要包含其他文字，只返回JSON）：

内容：$content

请返回以下格式的JSON：
{
  "emotion": "positive",
  "confidence": 0.85,
  "keywords": ["关键词1", "关键词2", "关键词3"]
}

情感选项：positive(积极), negative(消极), neutral(中性)
''';

    final result = await generateText(prompt);
    
    try {
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(result);
      if (jsonMatch != null) {
        final jsonData = jsonDecode(jsonMatch.group(0)!);
        
        return EmotionAnalysis(
          emotion: jsonData['emotion'] ?? 'neutral',
          confidence: (jsonData['confidence'] ?? 0.0).toDouble(),
          keywords: List<String>.from(jsonData['keywords'] ?? []),
        );
      }
    } catch (e) {
      developer.log('情感分析JSON解析失败: $e', name: 'OpenAIService');
    }

    // 默认返回
    return const EmotionAnalysis(
      emotion: 'neutral',
      confidence: 0.0,
      keywords: [],
    );
  }

  @override
  Future<String> generateSummary(String content) async {
    final prompt = '''
请为以下内容生成一个简洁的摘要（1-2句话）：

$content

请直接返回摘要内容，不要包含其他文字。
''';

    return await generateText(prompt);
  }

  @override
  Future<List<String>> extractKeywords(String content) async {
    final prompt = '''
请从以下内容中提取关键词，并返回JSON格式的数组（不要包含其他文字，只返回JSON）：

内容：$content

请返回以下格式的JSON：
["关键词1", "关键词2", "关键词3", "关键词4", "关键词5"]

请提取3-5个最重要的关键词。
''';

    final result = await generateText(prompt);
    
    try {
      final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(result);
      if (jsonMatch != null) {
        final jsonData = jsonDecode(jsonMatch.group(0)!);
        return List<String>.from(jsonData);
      }
    } catch (e) {
      developer.log('关键词提取JSON解析失败: $e', name: 'OpenAIService');
    }

    // 默认返回
    return [];
  }

  @override
  Future<String> chat(String message, List<String> context) async {
    final contextString = context.isNotEmpty 
        ? '对话历史：\n${context.join('\n')}\n\n' 
        : '';
    
    final prompt = '''
$contextString用户消息：$message

请作为一个有用的AI助手回复用户的消息。保持对话自然流畅，如果有对话历史，请参考上下文。
''';

    return await generateText(prompt);
  }

  @override
  Future<List<String>> generateTitleSuggestions(String content) async {
    final prompt = '''
请为以下内容生成3-5个标题建议，并返回JSON格式的数组（不要包含其他文字，只返回JSON）：

内容：$content

请返回以下格式的JSON：
["标题建议1", "标题建议2", "标题建议3", "标题建议4", "标题建议5"]

标题应该简洁明了，能够概括内容的主要意思。
''';

    final result = await generateText(prompt);
    
    try {
      final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(result);
      if (jsonMatch != null) {
        final jsonData = jsonDecode(jsonMatch.group(0)!);
        return List<String>.from(jsonData);
      }
    } catch (e) {
      developer.log('标题建议JSON解析失败: $e', name: 'OpenAIService');
    }

    // 默认返回
    return ['未命名记录'];
  }

  @override
  Future<String> analyzeImage(String imagePath) async {
    // OpenAI GPT-3.5 doesn't support image analysis
    // For image analysis, would need GPT-4V (Vision) which is more expensive
    developer.log('图片分析暂不支持，需要升级到GPT-4V模型', name: 'OpenAIService');
    return '抱歉，当前使用的GPT-3.5模型不支持图片分析功能。如需图片分析，请升级到GPT-4V模型。';
  }

  String _getNetworkErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return '网络连接失败\n\n✅ 优势：无需VPN，全球可访问\n🔧 请检查网络连接';
      case DioExceptionType.connectionTimeout:
        return '连接超时\n\n请检查网络连接或稍后重试';
      case DioExceptionType.receiveTimeout:
        return '响应超时\n\n服务器响应缓慢，请稍后重试';
      case DioExceptionType.sendTimeout:
        return '发送超时\n\n请检查网络连接';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final errorMessage = e.response?.data?['error']?['message'] ?? '未知错误';
        return '服务器错误 ($statusCode)\n\n$errorMessage';
      case DioExceptionType.cancel:
        return '请求被取消';
      default:
        return '网络请求失败：${e.message ?? '未知错误'}';
    }
  }
}