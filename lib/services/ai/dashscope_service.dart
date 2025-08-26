import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'ai_service.dart';

class DashScopeService implements AIService {
  final String apiKey;
  final Dio _dio;
  static const int _maxRetries = 3;
  
  DashScopeService({required this.apiKey}) : _dio = Dio() {
    // 使用中国版DashScope端点（最优性能）
    _dio.options.baseUrl = 'https://dashscope.aliyuncs.com';
    
    // 中国用户优化设置
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    
    // 2024年最新DashScope API headers
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
      'X-DashScope-SSE': 'disable', // 禁用流式响应
      'User-Agent': 'LoveRecord/1.0.0 (Flutter; macOS)',
      'Accept-Language': 'zh-CN,zh;q=0.9', // 优先中文
    };
    
    // Add retry interceptor
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
          
          developer.log('重试DashScope请求 ($retryCount/$_maxRetries): ${error.requestOptions.path}', 
                       name: 'DashScopeService');
          
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

  /// 创建DashScope API请求数据（2024最新格式）
  Map<String, dynamic> _createRequestData({
    required List<Map<String, String>> messages,
    int maxTokens = 1000,
    double temperature = 0.7,
  }) {
    return {
      'model': 'qwen-turbo',
      'input': {
        'messages': messages,
      },
      'parameters': {
        'result_format': 'message', // 确保使用消息格式响应
        'max_tokens': maxTokens,
        'temperature': temperature,
        'top_p': 0.8,
        'incremental_output': false, // 非流式响应
      },
    };
  }

  /// 从DashScope API响应中提取内容（2024年最新格式）
  String? _extractContent(Map<String, dynamic> data) {
    try {
      // 2024年DashScope API标准响应格式: data['output']['choices'][0]['message']['content']
      if (data['output'] != null && data['output']['choices'] != null) {
        final choices = data['output']['choices'];
        if (choices is List && choices.isNotEmpty) {
          final choice = choices[0];
          if (choice['message'] != null && choice['message']['content'] != null) {
            final content = choice['message']['content'].toString().trim();
            developer.log('成功提取API响应内容: ${content.length}字符', name: 'DashScopeService');
            return content;
          }
        }
      }
      
      // 备选：兼容旧格式 output.text (不太可能使用但保留兼容性)
      if (data['output'] != null && data['output']['text'] != null) {
        final content = data['output']['text'].toString().trim();
        developer.log('使用兼容格式提取内容: ${content.length}字符', name: 'DashScopeService');
        return content;
      }
      
      developer.log('无法解析API响应内容，响应格式: ${data.toString()}', name: 'DashScopeService');
      return null;
    } catch (e) {
      developer.log('解析API响应失败: $e', name: 'DashScopeService');
      return null;
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      developer.log('测试DashScope API连接...', name: 'DashScopeService');
      
      final requestData = _createRequestData(
        messages: [
          {'role': 'user', 'content': '你好，请回复"连接测试成功"'}
        ],
        maxTokens: 20,
        temperature: 0.1,
      );

      final response = await _dio.post(
        '/api/v1/services/aigc/text-generation/generation',
        data: requestData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      developer.log('API响应状态: ${response.statusCode}', name: 'DashScopeService');

      if (response.statusCode == 200) {
        developer.log('API响应数据: ${response.data}', name: 'DashScopeService');
        final content = _extractContent(response.data);
        if (content != null && content.isNotEmpty) {
          developer.log('DashScope API连接测试成功: $content', name: 'DashScopeService');
          return true;
        } else {
          developer.log('API响应成功但无法提取内容，完整响应: ${response.data}', name: 'DashScopeService');
        }
      }
      
      developer.log('API连接测试失败: 无效响应', name: 'DashScopeService');
      return false;
    } on DioException catch (e) {
      developer.log('DashScope连接测试失败: ${e.type} - ${e.message}', name: 'DashScopeService');
      
      if (e.response?.statusCode == 401) {
        throw Exception('DashScope API Key 无效\n\n请检查:\n• API Key是否正确\n• 是否已在阿里云控制台开通服务\n• API Key权限是否正确');
      } else if (e.response?.statusCode == 429) {
        throw Exception('API调用频率限制\n\n请稍后重试，或升级您的DashScope账户计划');
      } else if (e.response?.statusCode == 403) {
        throw Exception('API访问被拒绝\n\n可能原因:\n• 账户余额不足\n• API Key权限不足\n• 地区访问限制');
      } else {
        throw Exception('网络连接错误\n\n${_getNetworkErrorMessage(e)}');
      }
    } catch (e) {
      developer.log('DashScope连接测试异常: $e', name: 'DashScopeService');
      throw Exception('连接测试失败：$e');
    }
  }

  @override
  Future<String> generateText(String prompt) async {
    try {
      developer.log('开始DashScope文本生成...', name: 'DashScopeService');
      
      final requestData = _createRequestData(
        messages: [
          {'role': 'system', 'content': '你是通义千问，由阿里云开发的AI助手。你擅长中文对话，能帮助用户管理和分析个人记录。'},
          {'role': 'user', 'content': prompt}
        ],
        maxTokens: 2000,
        temperature: 0.7,
      );

      final response = await _dio.post(
        '/api/v1/services/aigc/text-generation/generation',
        data: requestData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      developer.log('DashScope文本生成响应: ${response.statusCode}', name: 'DashScopeService');

      if (response.statusCode == 200) {
        final content = _extractContent(response.data);
        if (content != null && content.isNotEmpty) {
          developer.log('DashScope文本生成成功: ${content.length}字符', name: 'DashScopeService');
          return content;
        } else {
          throw Exception('API响应格式错误：缺少output.text字段');
        }
      } else if (response.statusCode == 401) {
        throw Exception('API Key无效或已过期');
      } else if (response.statusCode == 429) {
        throw Exception('API调用频率过高，请稍后重试');
      } else if (response.statusCode == 400) {
        final errorMsg = response.data?['message'] ?? '请求参数错误';
        throw Exception('请求错误：$errorMsg');
      } else {
        throw Exception('服务器错误：HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      developer.log('DashScope文本生成DioException: ${e.type} - ${e.message}', name: 'DashScopeService');
      throw Exception(_getNetworkErrorMessage(e));
    } catch (e) {
      developer.log('DashScope文本生成其他错误: $e', name: 'DashScopeService');
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
      developer.log('JSON解析失败，使用默认分析: $e', name: 'DashScopeService');
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
      developer.log('情感分析JSON解析失败: $e', name: 'DashScopeService');
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
      developer.log('关键词提取JSON解析失败: $e', name: 'DashScopeService');
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
${contextString}用户消息：$message

请作为通义千问AI助手回复用户的消息。保持对话自然流畅，如果有对话历史，请参考上下文。
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
      developer.log('标题建议JSON解析失败: $e', name: 'DashScopeService');
    }

    // 默认返回
    return ['未命名记录'];
  }

  @override
  Future<String> analyzeImage(String imagePath) async {
    // DashScope Qwen-VL supports image analysis
    try {
      developer.log('尝试使用Qwen-VL进行图片分析...', name: 'DashScopeService');
      
      // For now, return a message indicating future support
      // TODO: Implement Qwen-VL multimodal analysis
      return '图片分析功能开发中，Qwen-VL多模态模型即将支持。';
    } catch (e) {
      developer.log('图片分析失败: $e', name: 'DashScopeService');
      return '图片分析功能暂时不可用。';
    }
  }

  String _getNetworkErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return '网络连接失败\n\n✅ 使用中国版DashScope优化连接\n🔧 请检查网络连接或尝试切换网络';
      case DioExceptionType.connectionTimeout:
        return '连接超时\n\n请检查网络连接或稍后重试';
      case DioExceptionType.receiveTimeout:
        return '响应超时\n\n服务器响应缓慢，请稍后重试';
      case DioExceptionType.sendTimeout:
        return '发送超时\n\n请检查网络连接';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final errorMessage = e.response?.data?['message'] ?? '未知错误';
        return '服务器错误 ($statusCode)\n\n$errorMessage';
      case DioExceptionType.cancel:
        return '请求被取消';
      default:
        return '网络请求失败：${e.message ?? '未知错误'}';
    }
  }
}