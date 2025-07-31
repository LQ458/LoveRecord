import 'dart:math';
import 'ai_service.dart';

/// Mock AI service for testing and offline development
class MockAIService implements AIService {
  final Random _random = Random();
  
  @override
  Future<bool> testConnection() async {
    // Mock connection test always succeeds
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));
    return true;
  }

  @override
  Future<String> generateText(String prompt) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1500)));
    
    // Return mock responses based on prompt content
    if (prompt.contains('你好') || prompt.contains('hello')) {
      return '你好！我是模拟AI助手，很高兴为您服务。请注意，这是离线模式，所有回复都是预设的模拟回复。';
    } else if (prompt.contains('分析') || prompt.contains('analyze')) {
      return '''
      {
        "categories": ["生活记录", "情感记录"], 
        "keywords": ["开心", "美好", "回忆"],
        "summary": "这是一个美好的生活记录，充满了积极的情感。",
        "confidence": 0.85
      }
      ''';
    } else if (prompt.contains('情感') || prompt.contains('emotion')) {
      return '''
      {
        "emotion": "positive",
        "confidence": 0.80,
        "keywords": ["快乐", "满足", "幸福"]
      }
      ''';
    } else if (prompt.contains('标题') || prompt.contains('title')) {
      return '''
      1. 美好的一天
      2. 珍贵的回忆
      3. 温馨时光
      ''';
    } else {
      final responses = [
        '感谢您的提问！这是模拟AI回复。在实际使用中，请配置真实的AI服务提供商。',
        '这是一个模拟回复。为获得更好的体验，请在设置中配置您的AI API密钥。',
        '模拟AI正在为您服务。如需使用真实AI功能，请前往设置页面配置API连接。',
        '您好！这是离线模式下的模拟回复。连接真实AI服务后，您将获得更智能的回答。',
      ];
      return responses[_random.nextInt(responses.length)];
    }
  }

  @override
  Future<ContentAnalysis> analyzeContent(String content) async {
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
    
    // Generate mock analysis based on content
    final categories = <String>[];
    final keywords = <String>[];
    
    if (content.contains('工作') || content.contains('工作')) {
      categories.add('工作笔记');
      keywords.addAll(['工作', '任务', '项目']);
    }
    if (content.contains('旅行') || content.contains('旅游')) {
      categories.add('旅行日记');
      keywords.addAll(['旅行', '风景', '体验']);
    }
    if (content.contains('学习') || content.contains('读书')) {
      categories.add('学习笔记');
      keywords.addAll(['学习', '知识', '成长']);
    }
    if (content.contains('开心') || content.contains('快乐') || content.contains('高兴')) {
      categories.add('情感记录');
      keywords.addAll(['开心', '快乐', '美好']);
    }
    
    if (categories.isEmpty) {
      categories.add('生活记录');
    }
    if (keywords.isEmpty) {
      keywords.addAll(['日常', '记录', '回忆']);
    }
    
    // Limit to reasonable numbers
    final limitedCategories = categories.take(3).toList();
    final limitedKeywords = keywords.take(5).toList();
    
    return ContentAnalysis(
      categories: limitedCategories,
      keywords: limitedKeywords,
      summary: content.length > 50 
          ? '${content.substring(0, 47)}...'
          : content,
      confidence: 0.7 + _random.nextDouble() * 0.25, // 0.7-0.95
    );
  }

  @override
  Future<List<String>> classifyContent(String content) async {
    final analysis = await analyzeContent(content);
    return analysis.categories;
  }

  @override
  Future<EmotionAnalysis> analyzeEmotion(String content) async {
    await Future.delayed(Duration(milliseconds: 600 + _random.nextInt(1000)));
    
    String emotion = 'neutral';
    final keywords = <String>[];
    
    if (content.contains('开心') || content.contains('快乐') || content.contains('高兴') || 
        content.contains('幸福') || content.contains('满足')) {
      emotion = 'positive';
      keywords.addAll(['快乐', '幸福', '满足']);
    } else if (content.contains('难过') || content.contains('伤心') || content.contains('沮丧') || 
               content.contains('痛苦') || content.contains('失望')) {
      emotion = 'negative';
      keywords.addAll(['难过', '失望', '沮丧']);
    } else {
      keywords.addAll(['平静', '日常', '记录']);
    }
    
    return EmotionAnalysis(
      emotion: emotion,
      confidence: 0.6 + _random.nextDouble() * 0.3, // 0.6-0.9
      keywords: keywords.take(3).toList(),
    );
  }

  @override
  Future<String> generateSummary(String content) async {
    await Future.delayed(Duration(milliseconds: 700 + _random.nextInt(1000)));
    
    if (content.length <= 100) {
      return content;
    }
    
    // For very long content, return a fixed-length summary
    if (content.length > 1000) {
      return '这是一个很长的内容摘要。模拟AI已将其压缩为简短的摘要，保留了关键信息。在实际应用中，AI会更智能地提取重要内容。';
    }
    
    // Simple summary generation for medium-length content
    final sentences = content.split('。').where((s) => s.trim().isNotEmpty).toList();
    if (sentences.length <= 2) {
      return content.length > 100 ? '${content.substring(0, 97)}...' : content;
    }
    
    // Take first and last sentence, or first two sentences
    final summary = sentences.length > 2 
        ? '${sentences.first}。${sentences.last}。'
        : '${sentences.take(2).join('。')}。';
        
    return summary.length > 100 ? '${summary.substring(0, 97)}...' : summary;
  }

  @override
  Future<List<String>> extractKeywords(String content) async {
    final analysis = await analyzeContent(content);
    return analysis.keywords;
  }

  @override
  Future<String> chat(String message, List<String> context) async {
    await Future.delayed(Duration(milliseconds: 600 + _random.nextInt(1200)));
    
    final responses = [
      '这是模拟对话回复。在实际使用中，AI会根据上下文提供更智能的回答。',
      '感谢您的消息！这是离线模式下的模拟回复。',
      '我是模拟AI助手，正在为您提供测试服务。请配置真实AI服务以获得更好体验。',
      '您的消息已收到！这是预设的模拟回复，实际AI会提供更个性化的回答。',
    ];
    
    return responses[_random.nextInt(responses.length)];
  }

  @override
  Future<List<String>> generateTitleSuggestions(String content) async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(800)));
    
    final suggestions = <String>[];
    
    if (content.contains('旅行') || content.contains('旅游')) {
      suggestions.addAll(['美好的旅行回忆', '旅途中的风景', '难忘的旅行体验']);
    } else if (content.contains('工作')) {
      suggestions.addAll(['工作心得记录', '职场生活感悟', '工作日常总结']);
    } else if (content.contains('学习')) {
      suggestions.addAll(['学习笔记整理', '知识收获总结', '学习心得体会']);
    } else {
      suggestions.addAll(['生活记录', '美好时光', '珍贵回忆']);
    }
    
    return suggestions.take(3).toList();
  }

  @override
  Future<String> analyzeImage(String imagePath) async {
    await Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(2000)));
    
    return '模拟图像分析结果：这是一张包含丰富内容的图片。实际使用中，AI会提供详细的图像描述和分析。';
  }
}