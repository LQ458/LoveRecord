import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'ai_service.dart';
import 'ai_service_factory.dart';
import 'network_diagnostics.dart';

class ErnieBotService implements AIService {
  final String clientId;
  final String clientSecret;
  final Dio _dio;
  String? _accessToken;
  DateTime? _tokenExpiry;
  static const int _maxRetries = 3;

  ErnieBotService({
    required String apiKey,
    String? clientSecret,
  }) : clientId = apiKey,
       clientSecret = clientSecret ?? apiKey,
       _dio = Dio() {
    // 使用正确的百度智能云API基础URL
    _dio.options.baseUrl = 'https://aip.baidubce.com';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    
    // 添加用户代理和其他HTTP头
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'LoveRecord/1.0.0 (Flutter; macOS)',
    };
    
    // 添加重试拦截器
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
                       name: 'ErnieBotService');
          
          // 等待一段时间后重试
          await Future.delayed(Duration(seconds: retryCount * 2));
          
          try {
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            handler.next(error);
            return;
          }
        }
        
        handler.next(error);
      },
    ));
    
    // 添加日志拦截器
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => developer.log(obj.toString(), name: 'ErnieBotService'),
    ));
  }

  /// 测试网络连接（专为macOS优化，集成网络诊断和多重测试）
  @override
  Future<bool> testConnection() async {
    try {
      developer.log('开始测试百度API连接...', name: 'ErnieBotService');
      
      // 运行网络诊断
      final diagnosticResult = await NetworkDiagnostics.diagnoseConnection();
      
      developer.log('网络诊断完成: ${diagnosticResult.overallStatus}', name: 'ErnieBotService');
      developer.log('诊断状态: ${diagnosticResult.getStatusDescription()}', name: 'ErnieBotService');
      
      // 如果有问题，记录详细信息
      if (diagnosticResult.issues.isNotEmpty) {
        developer.log('发现的问题: ${diagnosticResult.issues.join(', ')}', name: 'ErnieBotService');
      }
      
      if (diagnosticResult.suggestions.isNotEmpty) {
        developer.log('建议解决方案: ${diagnosticResult.getAllSuggestions().join(', ')}', name: 'ErnieBotService');
      }
      
      // 根据诊断结果决定是否继续测试
      if (diagnosticResult.overallStatus == NetworkStatus.disconnected) {
        throw Exception('网络连接不可用。\n\n问题:\n${diagnosticResult.issues.join('\n')}\n\n建议解决方案:\n${diagnosticResult.getAllSuggestions().join('\n')}');
      }
      
      // 尝试多种连接方法
      DioException? lastError;
      
      // 方法1: 标准OAuth连接测试
      try {
        developer.log('尝试方法1: 标准OAuth连接测试', name: 'ErnieBotService');
        final testResponse = await _performApiConnectionTest();
        developer.log('方法1成功: ${testResponse.statusCode}', name: 'ErnieBotService');
        return true;
      } on DioException catch (e) {
        lastError = e;
        developer.log('方法1失败: ${e.type} - ${e.message}', name: 'ErnieBotService');
      }
      
      // 方法2: 简化连接测试（仅测试域名可达性）
      try {
        developer.log('尝试方法2: 简化连接测试', name: 'ErnieBotService');
        await _performSimpleConnectivityTest();
        developer.log('方法2成功: 域名可达', name: 'ErnieBotService');
        return true;
      } catch (e) {
        developer.log('方法2失败: $e', name: 'ErnieBotService');
      }
      
      // 方法3: 使用Mock服务进行离线测试
      try {
        developer.log('尝试方法3: Mock服务连接测试', name: 'ErnieBotService');
        final mockService = AiServiceFactory.createService('mock');
        final mockResult = await mockService.testConnection();
        if (mockResult) {
          developer.log('方法3成功: 切换到离线模式', name: 'ErnieBotService');
          throw Exception('⚠️ 无法连接到百度API服务器，但已启用离线模式。\n\n可以使用模拟AI服务进行测试和开发。\n\n建议:\n• 检查网络连接和防火墙设置\n• 确认API密钥配置正确\n• 尝试使用VPN或更换网络环境\n\n${lastError != null ? _buildDetailedErrorMessage(lastError, diagnosticResult) : '无具体错误信息'}');
        }
      } catch (e) {
        developer.log('方法3失败: $e', name: 'ErnieBotService');
      }
      
      // 所有方法都失败，提供详细错误信息
      if (lastError != null) {
        final errorMessage = _buildDetailedErrorMessage(lastError, diagnosticResult);
        developer.log('所有连接方法都失败', name: 'ErnieBotService');
        throw Exception(errorMessage);
      } else {
        throw Exception('API连接测试失败：所有连接方法都不可用');
      }
      
    } catch (e) {
      developer.log('连接测试异常: $e', name: 'ErnieBotService');
      rethrow;
    }
  }
  
  /// 执行简化的连接测试（仅测试域名可达性）
  Future<void> _performSimpleConnectivityTest() async {
    final testDio = Dio();
    testDio.options.connectTimeout = const Duration(seconds: 10);
    testDio.options.receiveTimeout = const Duration(seconds: 10);
    testDio.options.headers = {
      'User-Agent': 'LoveRecord/1.0.0 (Flutter; macOS)',
    };
    
    // 仅测试主域名是否可达
    await testDio.get(
      'https://aip.baidubce.com/',
      options: Options(
        validateStatus: (status) => true, // 接受任何状态码
      ),
    );
  }
  
  /// 执行API特定的连接测试
  Future<Response> _performApiConnectionTest() async {
    final testDio = Dio();
    testDio.options.baseUrl = 'https://aip.baidubce.com';
    testDio.options.connectTimeout = const Duration(seconds: 15);
    testDio.options.receiveTimeout = const Duration(seconds: 15);
    testDio.options.headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'User-Agent': 'LoveRecord/1.0.0 (Flutter; macOS)',
    };
    
    // 使用正确的表单数据格式（百度API严格要求）
    final formData = 'grant_type=client_credentials&client_id=test_connection_id&client_secret=test_connection_secret';
    
    return await testDio.post(
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
  }
  
  /// 构建详细的错误信息
  String _buildDetailedErrorMessage(DioException e, NetworkDiagnosticResult diagnostic) {
    final buffer = StringBuffer();
    
    // 基本错误信息
    switch (e.type) {
      case DioExceptionType.connectionError:
        buffer.writeln('❌ 网络连接错误：无法连接到百度API服务器');
        break;
      case DioExceptionType.connectionTimeout:
        buffer.writeln('⏱️ 连接超时：连接百度API服务器超时');
        break;
      case DioExceptionType.receiveTimeout:
        buffer.writeln('⏱️ 响应超时：服务器响应超时');
        break;
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
          // 这些状态码表示网络连接正常，认证错误是预期的
          return '✅ 网络连接正常！测试连接成功。';
        } else {
          buffer.writeln('🔴 服务器错误: HTTP ${e.response?.statusCode}');
        }
        break;
      default:
        buffer.writeln('❓ 未知网络错误: ${e.message ?? '未知'}');
    }
    
    // 添加网络诊断信息
    if (diagnostic.issues.isNotEmpty) {
      buffer.writeln('\n🔍 网络诊断发现的问题:');
      for (int i = 0; i < diagnostic.issues.length; i++) {
        buffer.writeln('${i + 1}. ${diagnostic.issues[i]}');
      }
    }
    
    // 添加解决建议
    final suggestions = diagnostic.getAllSuggestions();
    if (suggestions.isNotEmpty) {
      buffer.writeln('\n💡 建议解决方案:');
      for (int i = 0; i < suggestions.length; i++) {
        buffer.writeln('${i + 1}. ${suggestions[i]}');
      }
    }
    
    // 添加macOS特定建议
    buffer.writeln('\n🍎 macOS特定检查:');
    buffer.writeln('• 系统偏好设置 > 安全性与隐私 > 防火墙 > 允许应用程序通过防火墙');
    buffer.writeln('• 网络偏好设置 > 高级 > 代理 > 确认代理设置');
    buffer.writeln('• 如使用VPN，尝试暂时断开连接进行测试');
    
    return buffer.toString();
  }

  /// 获取访问令牌
  Future<String> _getAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    try {
      developer.log('正在获取访问令牌...', name: 'ErnieBotService');
      
      // 构建表单数据（百度API要求使用form-urlencoded格式）
      final formData = 'grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret';
      
      final response = await _dio.post(
        '/oauth/2.0/token',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      developer.log('访问令牌响应: ${response.statusCode}', name: 'ErnieBotService');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['access_token'] != null) {
          _accessToken = data['access_token'];
          _tokenExpiry = DateTime.now().add(Duration(seconds: (data['expires_in'] ?? 2592000) - 60));
          developer.log('访问令牌获取成功', name: 'ErnieBotService');
          return _accessToken!;
        } else {
          throw Exception('API响应格式错误：缺少access_token字段');
        }
      } else {
        throw Exception('获取访问令牌失败：HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      developer.log('DioException: ${e.type} - ${e.message}', name: 'ErnieBotService');
      
      String errorMessage = '网络请求失败';
      
      switch (e.type) {
        case DioExceptionType.connectionError:
          errorMessage = '网络连接失败，请检查网络设置';
          break;
        case DioExceptionType.connectionTimeout:
          errorMessage = '连接超时，请检查网络连接';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = '响应超时，请稍后重试';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = '发送超时，请检查网络连接';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            errorMessage = 'API Key无效，请检查密钥是否正确';
          } else if (e.response?.statusCode == 403) {
            errorMessage = 'API Key权限不足，请检查服务是否已开通';
          } else if (e.response?.statusCode == 429) {
            errorMessage = '请求频率过高，请稍后重试';
          } else {
            errorMessage = '服务器错误：HTTP ${e.response?.statusCode}';
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = '请求被取消';
          break;
        default:
          errorMessage = '网络请求失败：${e.message ?? '未知错误'}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      developer.log('其他错误: $e', name: 'ErnieBotService');
      throw Exception('获取访问令牌时发生错误：$e');
    }
  }

  @override
  Future<String> generateText(String prompt) async {
    try {
      developer.log('开始生成文本...', name: 'ErnieBotService');
      
      final token = await _getAccessToken();
      developer.log('使用访问令牌: ${token.substring(0, 10)}...', name: 'ErnieBotService');
      
      // 使用ERNIE-Bot-turbo模型（最稳定的端点）
      final response = await _dio.post(
        '/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/eb-instant',
        queryParameters: {'access_token': token},
        data: {
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.95,
          'top_p': 0.8,
          'penalty_score': 1.0,
        },
      );

      developer.log('文本生成响应: ${response.statusCode}', name: 'ErnieBotService');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['result'] != null) {
          final result = data['result'];
          developer.log('文本生成成功: ${result.length}字符', name: 'ErnieBotService');
          return result;
        } else if (data['error_msg'] != null) {
          throw Exception('API返回错误：${data['error_msg']}');
        } else {
          throw Exception('API响应格式错误：缺少result字段');
        }
      } else {
        throw Exception('生成文本失败：HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      developer.log('文本生成DioException: ${e.type} - ${e.message}', name: 'ErnieBotService');
      
      String errorMessage = '网络请求失败';
      
      switch (e.type) {
        case DioExceptionType.connectionError:
          errorMessage = '网络连接失败，请检查网络设置';
          break;
        case DioExceptionType.connectionTimeout:
          errorMessage = '连接超时，请检查网络连接';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = '响应超时，请稍后重试';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = '发送超时，请检查网络连接';
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            errorMessage = '访问令牌已过期，请重新配置API Key';
          } else if (e.response?.statusCode == 429) {
            errorMessage = '请求频率过高，请稍后重试';
          } else if (e.response?.statusCode == 500) {
            errorMessage = '服务器内部错误，请稍后重试';
          } else {
            errorMessage = '服务器错误：HTTP ${e.response?.statusCode}';
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = '请求被取消';
          break;
        default:
          errorMessage = '网络请求失败：${e.message ?? '未知错误'}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      developer.log('文本生成其他错误: $e', name: 'ErnieBotService');
      throw Exception('生成文本时发生错误：$e');
    }
  }

  @override
  Future<ContentAnalysis> analyzeContent(String content) async {
    final prompt = '''
请分析以下内容，并返回JSON格式的分析结果：
内容：$content

请返回以下格式的JSON：
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
      // 如果JSON解析失败，返回默认分析
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
请分析以下内容的情感倾向：
内容：$content

请返回以下格式的JSON：
{
  "emotion": "positive/negative/neutral",
  "confidence": 0.85,
  "keywords": ["情感关键词1", "情感关键词2"]
}
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
      // JSON解析失败
    }

    return const EmotionAnalysis(
      emotion: 'neutral',
      confidence: 0.0,
      keywords: [],
    );
  }

  @override
  Future<String> generateSummary(String content) async {
    final prompt = '''
请为以下内容生成一个简洁的摘要（不超过100字）：
$content
''';

    return await generateText(prompt);
  }

  @override
  Future<List<String>> extractKeywords(String content) async {
    final analysis = await analyzeContent(content);
    return analysis.keywords;
  }

  @override
  Future<String> chat(String message, List<String> context) async {
    final contextText = context.isNotEmpty ? '上下文：${context.join(' ')}\n\n' : '';
    final prompt = '$contextText用户：$message\n\n请回复：';
    
    return await generateText(prompt);
  }

  @override
  Future<List<String>> generateTitleSuggestions(String content) async {
    final prompt = '''
请为以下内容生成3个标题建议：
$content

请返回以下格式：
1. 标题1
2. 标题2
3. 标题3
''';

    final result = await generateText(prompt);
    final lines = result.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    return lines.take(3).map((line) {
      // 移除序号
      return line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
    }).toList();
  }

  @override
  Future<String> analyzeImage(String imagePath) async {
    // 文心一言支持图像分析，但需要特殊处理
    // 这里先返回基础实现
    return '图像分析功能待实现';
  }
} 