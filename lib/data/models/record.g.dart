// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Record _$RecordFromJson(Map<String, dynamic> json) => Record(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      mediaFiles: (json['mediaFiles'] as List<dynamic>)
          .map((e) => MediaFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      type: $enumDecode(_$RecordTypeEnumMap, json['type']),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$RecordToJson(Record instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'mediaFiles': instance.mediaFiles,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'type': _$RecordTypeEnumMap[instance.type]!,
      'metadata': instance.metadata,
    };

const _$RecordTypeEnumMap = {
  RecordType.diary: 'diary',
  RecordType.work: 'work',
  RecordType.study: 'study',
  RecordType.travel: 'travel',
  RecordType.health: 'health',
  RecordType.finance: 'finance',
  RecordType.creative: 'creative',
};
