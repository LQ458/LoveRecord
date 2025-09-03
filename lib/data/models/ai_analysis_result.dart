/// AI分析结果数据模型
class AIAnalysisResult {
  final String? summary;
  final List<String> keywords;
  final List<String> categories;
  final String? emotion;
  final double? summaryConfidence;
  final double? emotionConfidence;
  final double? contentConfidence;
  final DateTime? analyzedAt;

  const AIAnalysisResult({
    this.summary,
    this.keywords = const [],
    this.categories = const [],
    this.emotion,
    this.summaryConfidence,
    this.emotionConfidence, 
    this.contentConfidence,
    this.analyzedAt,
  });

  /// 创建空的分析结果
  factory AIAnalysisResult.empty() {
    return const AIAnalysisResult();
  }

  /// 从数据库数据创建分析结果
  factory AIAnalysisResult.fromDatabaseMap(Map<String, dynamic> map) {
    return AIAnalysisResult(
      summary: map['summary'] as String?,
      keywords: (map['keywords'] as List<String>?) ?? [],
      categories: (map['categories'] as List<String>?) ?? [],
      emotion: map['emotion'] as String?,
      summaryConfidence: map['summaryConfidence'] as double?,
      emotionConfidence: map['emotionConfidence'] as double?,
      contentConfidence: map['contentConfidence'] as double?,
      analyzedAt: DateTime.now(),
    );
  }

  /// 从AI服务结果创建分析结果
  factory AIAnalysisResult.fromAIServices({
    String? summary,
    List<String>? keywords,
    List<String>? categories,
    String? emotion,
    double? summaryConfidence,
    double? emotionConfidence,
    double? contentConfidence,
  }) {
    return AIAnalysisResult(
      summary: summary,
      keywords: keywords ?? [],
      categories: categories ?? [],
      emotion: emotion,
      summaryConfidence: summaryConfidence,
      emotionConfidence: emotionConfidence,
      contentConfidence: contentConfidence,
      analyzedAt: DateTime.now(),
    );
  }

  /// 复制并修改部分字段
  AIAnalysisResult copyWith({
    String? summary,
    List<String>? keywords,
    List<String>? categories,
    String? emotion,
    double? summaryConfidence,
    double? emotionConfidence,
    double? contentConfidence,
    DateTime? analyzedAt,
  }) {
    return AIAnalysisResult(
      summary: summary ?? this.summary,
      keywords: keywords ?? this.keywords,
      categories: categories ?? this.categories,
      emotion: emotion ?? this.emotion,
      summaryConfidence: summaryConfidence ?? this.summaryConfidence,
      emotionConfidence: emotionConfidence ?? this.emotionConfidence,
      contentConfidence: contentConfidence ?? this.contentConfidence,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }

  /// 检查是否有任何分析结果
  bool get hasAnyAnalysis {
    return (summary != null && summary!.isNotEmpty) ||
           keywords.isNotEmpty ||
           categories.isNotEmpty ||
           (emotion != null && emotion!.isNotEmpty);
  }

  /// 检查是否为空
  bool get isEmpty => !hasAnyAnalysis;

  /// 获取情感分析的显示文本
  String get emotionDisplayText {
    switch (emotion?.toLowerCase()) {
      case 'positive':
        return '积极';
      case 'negative':
        return '消极';
      case 'neutral':
        return '中性';
      default:
        return '未分析';
    }
  }

  /// 获取置信度的显示文本
  String getConfidenceText(double? confidence) {
    if (confidence == null) return '未知';
    final percentage = (confidence * 100).toStringAsFixed(1);
    return '$percentage%';
  }

  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResult(
      summary: json['summary'] as String?,
      keywords: (json['keywords'] as List<dynamic>?)?.cast<String>() ?? [],
      categories: (json['categories'] as List<dynamic>?)?.cast<String>() ?? [],
      emotion: json['emotion'] as String?,
      summaryConfidence: json['summaryConfidence'] as double?,
      emotionConfidence: json['emotionConfidence'] as double?,
      contentConfidence: json['contentConfidence'] as double?,
      analyzedAt: json['analyzedAt'] != null 
          ? DateTime.parse(json['analyzedAt'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'keywords': keywords,
      'categories': categories,
      'emotion': emotion,
      'summaryConfidence': summaryConfidence,
      'emotionConfidence': emotionConfidence,
      'contentConfidence': contentConfidence,
      'analyzedAt': analyzedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AIAnalysisResult{'
        'summary: ${summary?.substring(0, (summary?.length ?? 0) > 50 ? 50 : (summary?.length ?? 0))}..., '
        'keywords: $keywords, '
        'categories: $categories, '
        'emotion: $emotion, '
        'hasAnalysis: $hasAnyAnalysis}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIAnalysisResult &&
          runtimeType == other.runtimeType &&
          summary == other.summary &&
          keywords == other.keywords &&
          categories == other.categories &&
          emotion == other.emotion;

  @override
  int get hashCode =>
      summary.hashCode ^
      keywords.hashCode ^
      categories.hashCode ^
      emotion.hashCode;
}