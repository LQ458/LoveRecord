import 'package:json_annotation/json_annotation.dart';

part 'ai_service.g.dart';

@JsonSerializable()
class ContentAnalysis {
  final List<String> categories;
  final List<String> keywords;
  final String summary;
  final double confidence;

  const ContentAnalysis({
    required this.categories,
    required this.keywords,
    required this.summary,
    required this.confidence,
  });

  factory ContentAnalysis.fromJson(Map<String, dynamic> json) => _$ContentAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$ContentAnalysisToJson(this);
}

@JsonSerializable()
class EmotionAnalysis {
  final String emotion; // positive, negative, neutral
  final double confidence;
  final List<String> keywords;

  const EmotionAnalysis({
    required this.emotion,
    required this.confidence,
    required this.keywords,
  });

  factory EmotionAnalysis.fromJson(Map<String, dynamic> json) => _$EmotionAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$EmotionAnalysisToJson(this);
}

abstract class AIService {
  /// 生成文本内容
  Future<String> generateText(String prompt);
  
  /// 测试网络连接
  Future<bool> testConnection();
  
  /// 分析内容并返回分类、关键词、摘要等
  Future<ContentAnalysis> analyzeContent(String content);
  
  /// 对内容进行分类
  Future<List<String>> classifyContent(String content);
  
  /// 分析情感倾向
  Future<EmotionAnalysis> analyzeEmotion(String content);
  
  /// 生成内容摘要
  Future<String> generateSummary(String content);
  
  /// 提取关键词
  Future<List<String>> extractKeywords(String content);
  
  /// 聊天对话
  Future<String> chat(String message, List<String> context);
  
  /// 生成标题建议
  Future<List<String>> generateTitleSuggestions(String content);
  
  /// 分析图片内容（如果支持）
  Future<String> analyzeImage(String imagePath);
}


/// AI服务提供商枚举
enum AIProvider {
  ernieBot,    // 百度文心一言
  qwen,        // 阿里通义千问
  hunyuan,     // 腾讯混元
  chatglm,     // 智谱AI
  sparkDesk,   // 讯飞星火
  mock,        // 模拟AI服务
}

/// AI服务配置
class AIConfig {
  final AIProvider provider;
  final String apiKey;
  final String? secretKey;
  final String baseUrl;
  final Map<String, dynamic> additionalConfig;

  const AIConfig({
    required this.provider,
    required this.apiKey,
    this.secretKey,
    required this.baseUrl,
    this.additionalConfig = const {},
  });
} 