// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentAnalysis _$ContentAnalysisFromJson(Map<String, dynamic> json) =>
    ContentAnalysis(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      keywords:
          (json['keywords'] as List<dynamic>).map((e) => e as String).toList(),
      summary: json['summary'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$ContentAnalysisToJson(ContentAnalysis instance) =>
    <String, dynamic>{
      'categories': instance.categories,
      'keywords': instance.keywords,
      'summary': instance.summary,
      'confidence': instance.confidence,
    };

EmotionAnalysis _$EmotionAnalysisFromJson(Map<String, dynamic> json) =>
    EmotionAnalysis(
      emotion: json['emotion'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      keywords:
          (json['keywords'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$EmotionAnalysisToJson(EmotionAnalysis instance) =>
    <String, dynamic>{
      'emotion': instance.emotion,
      'confidence': instance.confidence,
      'keywords': instance.keywords,
    };
