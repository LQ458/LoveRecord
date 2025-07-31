import 'package:flutter_test/flutter_test.dart';
import 'package:loverecord/services/ai/ai_service_factory.dart';

void main() {
  group('AI Service Integration Tests', () {
    
    test('Mock AI Service should work correctly', () async {
      // Create mock AI service
      final aiService = AiServiceFactory.createService('mock');
      
      // Test connection
      final connectionResult = await aiService.testConnection();
      expect(connectionResult, isTrue);
      
      // Test text generation
      final textResult = await aiService.generateText('你好');
      expect(textResult, isNotEmpty);
      expect(textResult, contains('模拟'));
      
      // Test content analysis
      final analysisResult = await aiService.analyzeContent('今天天气很好，心情不错');
      expect(analysisResult.categories, isNotEmpty);
      expect(analysisResult.keywords, isNotEmpty);
      expect(analysisResult.confidence, greaterThan(0.0));
      
      // Test emotion analysis
      final emotionResult = await aiService.analyzeEmotion('今天很开心');
      expect(emotionResult.emotion, isIn(['positive', 'negative', 'neutral']));
      expect(emotionResult.confidence, greaterThan(0.0));
      
      // Test title suggestions
      final titleSuggestions = await aiService.generateTitleSuggestions('今天去公园玩了');
      expect(titleSuggestions, hasLength(3));
      expect(titleSuggestions.every((title) => title.isNotEmpty), isTrue);
    });
    
    test('ERNIE Bot Service should initialize correctly', () async {
      // Test with dummy API key
      expect(() => AiServiceFactory.createService('ernie_bot', apiKey: 'test_key'),
             returnsNormally);
      
      // Test without API key should throw
      expect(() => AiServiceFactory.createService('ernie_bot'),
             throwsException);
    });
    
    test('Factory should support all providers', () {
      final supportedProviders = AiServiceFactory.getSupportedProviders();
      expect(supportedProviders, contains('ernie_bot'));
      expect(supportedProviders, contains('mock'));
      
      // Test display names
      expect(AiServiceFactory.getProviderDisplayName('ernie_bot'), equals('文心一言'));
      expect(AiServiceFactory.getProviderDisplayName('mock'), equals('模拟AI服务（离线模式）'));
      
      // Test descriptions
      expect(AiServiceFactory.getProviderDescription('ernie_bot'), contains('百度'));
      expect(AiServiceFactory.getProviderDescription('mock'), contains('离线'));
    });
    
    test('Factory should handle invalid providers', () {
      expect(() => AiServiceFactory.createService('invalid_provider'),
             throwsException);
    });
    
    test('Content analysis should handle different content types', () async {
      final aiService = AiServiceFactory.createService('mock');
      
      // Test work content
      final workAnalysis = await aiService.analyzeContent('今天完成了项目的重要功能开发');
      expect(workAnalysis.categories, isNotEmpty);
      
      // Test travel content
      final travelAnalysis = await aiService.analyzeContent('去了美丽的海边度假');
      expect(travelAnalysis.categories, isNotEmpty);
      
      // Test emotional content
      final emotionalAnalysis = await aiService.analyzeContent('感到很开心和满足');
      expect(emotionalAnalysis.categories, isNotEmpty);
    });
    
    test('AI service should handle errors gracefully', () async {
      final aiService = AiServiceFactory.createService('mock');
      
      // Test with empty content
      final emptyResult = await aiService.analyzeContent('');
      expect(emptyResult, isNotNull);
      
      // Test with very long content
      final longContent = 'a' * 10000;
      final longResult = await aiService.generateSummary(longContent);
      expect(longResult, isNotNull);
      expect(longResult.length, lessThanOrEqualTo(1000)); // Should be summarized
    });
  });
}