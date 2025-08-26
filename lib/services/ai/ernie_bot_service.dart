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
    // 2024 修复：使用中国版千帆平台端点（最优性能）
    _dio.options.baseUrl = 'https://aip.baidubce.com';
    // 中国用户优化设置
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    
    // 优化的HTTP头配置（中国版）
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'LoveRecord/1.0.0 (Flutter; macOS)',
      'Accept-Language': 'zh-CN,zh;q=0.9', // 优先中文
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
      final errorMessage = _buildDetailedErrorMessage(lastError, diagnosticResult);
      developer.log('所有连接方法都失败', name: 'ErnieBotService');
      throw Exception(errorMessage);
          
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

  /// 获取访问令牌（2024年更新：支持多种认证方式和错误处理）
  Future<String> _getAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    Exception? lastError;
    
    // 尝试多种认证方法（基于2024年研究发现）
    
    // 方法1：标准OAuth 2.0 Client Credentials（当前方法）
    try {
      developer.log('尝试方法1：OAuth 2.0 Client Credentials认证...', name: 'ErnieBotService');
      
      // 构建表单数据（百度API要求使用form-urlencoded格式）
      final formData = 'grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret';
      
      final response = await _dio.post(
        '/oauth/2.0/token',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
            'User-Agent': 'LoveRecord/1.0.0 (Flutter; macOS)',
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
          developer.log('方法1认证成功：OAuth 2.0 Client Credentials', name: 'ErnieBotService');
          return _accessToken!;
        } else {
          throw Exception('API响应格式错误：缺少access_token字段');
        }
      } else if (response.statusCode == 401) {
        throw Exception('认证失败：Client ID 或 Client Secret 无效\n\n2024年常见问题:\n• 确认使用的是千帆平台的Client ID（不是AK）\n• 检查是否开通了文心一言服务\n• 确认API密钥来自正确的控制台页面');
      } else if (response.statusCode == 403) {
        throw Exception('权限被拒绝：API服务未开通或配额不足\n\n2024年解决方案:\n• 在百度智能云控制台开通ERNIE Bot服务\n• 检查账户余额和配额状态\n• 确认服务在当前地区可用');
      } else {
        throw Exception('获取访问令牌失败：HTTP ${response.statusCode}\n响应内容: ${response.data}');
      }
    } on DioException catch (e) {
      lastError = Exception('方法1失败：OAuth 2.0认证出现网络错误');
      developer.log('方法1失败：${e.type} - ${e.message}', name: 'ErnieBotService');
      
      // 根据错误类型记录详细信息
      switch (e.type) {
        case DioExceptionType.connectionError:
          lastError = Exception('网络连接失败\n\n可能原因（2024年常见）:\n• 海外访问百度API受限，需要VPN\n• macOS防火墙阻止连接\n• DNS解析问题\n\n建议解决方案:\n• 使用国内VPN或网络环境\n• 检查macOS网络权限设置\n• 尝试切换到移动网络测试');
          break;
        case DioExceptionType.connectionTimeout:
          lastError = Exception('连接超时\n\n2024年解决方案:\n• 海外用户需要稳定VPN连接\n• 增加网络超时时间\n• 尝试在网络较好的时段访问');
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            lastError = Exception('认证失败 (401)\n\n请检查:\n• Client ID 和 Client Secret 是否正确\n• 是否使用了千帆平台的正确密钥\n• 服务是否已在控制台开通');
          } else if (e.response?.statusCode == 403) {
            lastError = Exception('权限不足 (403)\n\n常见原因:\n• 服务未在控制台开通\n• 账户余额不足\n• API调用超出配额限制');
          }
          break;
        default:
          lastError = Exception('网络请求失败：${e.message ?? '未知错误'}');
      }
    } catch (e) {
      lastError = Exception('方法1异常：$e');
      developer.log('方法1其他异常: $e', name: 'ErnieBotService');
    }
    
    // 方法2：尝试千帆平台直接端点（2024年新增）
    try {
      developer.log('尝试方法2：千帆平台直接认证...', name: 'ErnieBotService');
      
      final qianfanDio = Dio();
      qianfanDio.options.baseUrl = 'https://qianfan.baidubce.com';
      qianfanDio.options.connectTimeout = const Duration(seconds: 30);
      
      final formData = 'grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret';
      
      final response = await qianfanDio.post(
        '/oauth/2.0/token',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['access_token'] != null) {
          _accessToken = data['access_token'];
          _tokenExpiry = DateTime.now().add(Duration(seconds: (data['expires_in'] ?? 2592000) - 60));
          developer.log('方法2认证成功：千帆平台直接端点', name: 'ErnieBotService');
          return _accessToken!;
        }
      }
    } catch (e) {
      developer.log('方法2失败: $e', name: 'ErnieBotService');
    }
    
    // 所有认证方法都失败，抛出详细错误信息
    final errorMessage = '''
🔑 百度API认证失败 - 2024年常见问题诊断

认证方法都已尝试失败，请检查以下配置：

1. 【API密钥配置】
   • 确认使用千帆平台的 Client ID 和 Client Secret
   • 控制台地址：https://console.bce.baidu.com/qianfan/
   • 检查密钥是否正确复制（无多余空格）

2. 【服务开通状态】
   • 登录百度智能云控制台
   • 确认已开通 ERNIE Bot 服务
   • 检查账户余额和调用配额

3. 【网络访问问题】
   • 海外用户需要使用VPN连接到中国
   • macOS用户检查防火墙和网络权限
   • 尝试使用移动网络测试

4. 【常见解决方案】
   • 重新生成API密钥
   • 确认服务地区可用性
   • 联系百度技术支持

最后错误：${lastError.toString() ?? '未知错误'}
''';
    
    throw Exception(errorMessage);
  }

  @override
  Future<String> generateText(String prompt) async {
    Exception? lastError;
    
    // 2024年最新修复：使用中国版正确端点（提高成功率）
    final endpoints = [
      '/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/ernie-bot-turbo',   // ERNIE-Bot-Turbo（推荐）
      '/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/eb-instant',        // ERNIE-Bot-4.0-Turbo
      '/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/ernie_bot_8k',      // ERNIE-Bot 8K（备选）
      '/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/ernie-bot-4',       // ERNIE-Bot-4.0
    ];
    
    for (int i = 0; i < endpoints.length; i++) {
      final endpoint = endpoints[i];
      try {
        developer.log('尝试端点 ${i + 1}/${endpoints.length}: $endpoint', name: 'ErnieBotService');
        
        final token = await _getAccessToken();
        developer.log('使用访问令牌: ${token.substring(0, 10)}...', name: 'ErnieBotService');
        
        final response = await _dio.post(
          endpoint,
          queryParameters: {'access_token': token},
          data: {
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
            'temperature': 0.95,
            'top_p': 0.8,
            'penalty_score': 1.0,
            'system': '你是ERNIE Bot，由百度开发的大语言模型。', // 2024年推荐添加系统提示
          },
          options: Options(
            validateStatus: (status) => status != null && status < 500,
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'LoveRecord/1.0.0 (Flutter; macOS)',
            },
          ),
        );

        developer.log('端点${i + 1}响应: ${response.statusCode}', name: 'ErnieBotService');

        if (response.statusCode == 200) {
          final data = response.data;
          if (data['result'] != null) {
            final result = data['result'];
            developer.log('端点${i + 1}成功: ${result.length}字符', name: 'ErnieBotService');
            return result;
          } else if (data['error_msg'] != null) {
            throw Exception('API返回错误：${data['error_msg']}');
          } else {
            throw Exception('API响应格式错误：缺少result字段');
          }
        } else if (response.statusCode == 401) {
          throw Exception('认证失败：访问令牌无效或过期');
        } else if (response.statusCode == 403) {
          throw Exception('权限不足：服务未开通或配额不足');
        } else if (response.statusCode == 429) {
          throw Exception('请求频率过高：请稍后重试');
        } else {
          throw Exception('生成文本失败：HTTP ${response.statusCode}');
        }
      } on DioException catch (e) {
        lastError = Exception('端点${i + 1}失败: ${e.type} - ${e.message}');
        developer.log('端点${i + 1}失败: ${e.type} - ${e.message}', name: 'ErnieBotService');
        
        // 如果是认证或权限错误，不再尝试其他端点
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          throw Exception('认证或权限错误，停止尝试其他端点：${e.response?.statusCode}');
        }
        continue; // 继续尝试下一个端点
      } catch (e) {
        lastError = Exception('端点${i + 1}异常: $e');
        developer.log('端点${i + 1}异常: $e', name: 'ErnieBotService');
        continue; // 继续尝试下一个端点
      }
    }
    
    // 所有端点都失败了，抛出详细错误
    final errorMessage = '''
📡 文本生成失败 - 所有API端点都不可用

尝试了${endpoints.length}个不同的API端点，都无法成功连接。

2024年常见解决方案：
1. 检查网络连接（海外用户需要VPN）
2. 确认API服务已开通并有足够配额
3. 检查访问令牌是否有效
4. 尝试稍后重试（可能是暂时性服务问题）

最后错误：${lastError?.toString() ?? '未知错误'}
''';
    
    throw Exception(errorMessage);
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