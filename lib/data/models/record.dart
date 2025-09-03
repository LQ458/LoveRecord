import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'media_file.dart';
import 'ai_analysis_result.dart';

part 'record.g.dart';

enum RecordType {
  @JsonValue('diary')
  diary,
  @JsonValue('work')
  work,
  @JsonValue('study')
  study,
  @JsonValue('travel')
  travel,
  @JsonValue('health')
  health,
  @JsonValue('finance')
  finance,
  @JsonValue('creative')
  creative,
}

@JsonSerializable()
class Record {
  final String id;
  final String title;
  final String content;
  final List<MediaFile> mediaFiles;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RecordType type;
  final Map<String, dynamic> metadata;
  
  // AI分析结果（从数据库懒加载）
  @JsonKey(includeFromJson: false, includeToJson: false)
  final AIAnalysisResult? aiAnalysis;

  const Record({
    required this.id,
    required this.title,
    required this.content,
    required this.mediaFiles,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    required this.metadata,
    this.aiAnalysis,
  });

  factory Record.create({
    required String title,
    required String content,
    required RecordType type,
    List<MediaFile> mediaFiles = const [],
    List<String> tags = const [],
    Map<String, dynamic> metadata = const {},
  }) {
    final now = DateTime.now();
    return Record(
      id: const Uuid().v4(),
      title: title,
      content: content,
      mediaFiles: mediaFiles,
      tags: tags,
      createdAt: now,
      updatedAt: now,
      type: type,
      metadata: metadata,
      aiAnalysis: null, // AI分析将稍后添加
    );
  }

  Record copyWith({
    String? id,
    String? title,
    String? content,
    List<MediaFile>? mediaFiles,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    RecordType? type,
    Map<String, dynamic>? metadata,
    AIAnalysisResult? aiAnalysis,
  }) {
    return Record(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
    );
  }

  factory Record.fromJson(Map<String, dynamic> json) => _$RecordFromJson(json);
  Map<String, dynamic> toJson() => _$RecordToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Record &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Record{id: $id, title: $title, type: $type, createdAt: $createdAt}';
  }
} 