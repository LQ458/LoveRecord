import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'ai_service.dart';

class ErnieBotService implements AIService {
  final String apiKey;
  final String secretKey;
  final Dio _dio;
  String? _accessToken;
  DateTime? _tokenExpiry;

  ErnieBotService({
    required this.apiKey,
    required this.secretKey,
  }) : _dio = Dio() {
    _dio.options.baseUrl = 'https://aip.baidubce.com';
  }

  /// 获取访问令牌
  Future<String> _getAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    final response = await _dio.get(
      '/oauth/2.0/token',
      queryParameters: {
        'grant_type': 'client_credentials',
        'client_id': apiKey,
        'client_secret': secretKey,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      _accessToken = data['access_token'];
      _tokenExpiry = DateTime.now().add(Duration(seconds: data['expires_in'] - 60));
      return _accessToken!;
    } else {
      throw Exception('Failed to get access token: ${response.statusMessage}');
    }
  }

  @override
  Future<String> generateText(String prompt) async {
    final token = await _getAccessToken();
    
    final response = await _dio.post(
      '/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions',
      queryParameters: {'access_token': token},
      data: {
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
        'max_tokens': 2048,
      },
    );

    if (response.statusCode == 200) {
      return response.data['result'];
    } else {
      throw Exception('Failed to generate text: ${response.statusMessage}');
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