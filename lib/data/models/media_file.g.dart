// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaFile _$MediaFileFromJson(Map<String, dynamic> json) => MediaFile(
      id: json['id'] as String,
      path: json['path'] as String,
      type: $enumDecode(_$MediaTypeEnumMap, json['type']),
      size: (json['size'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$MediaFileToJson(MediaFile instance) => <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'type': _$MediaTypeEnumMap[instance.type]!,
      'size': instance.size,
      'createdAt': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$MediaTypeEnumMap = {
  MediaType.text: 'text',
  MediaType.image: 'image',
  MediaType.audio: 'audio',
  MediaType.video: 'video',
  MediaType.document: 'document',
  MediaType.location: 'location',
  MediaType.contact: 'contact',
};
