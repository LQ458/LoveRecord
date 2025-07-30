import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'media_file.g.dart';

enum MediaType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('audio')
  audio,
  @JsonValue('video')
  video,
  @JsonValue('document')
  document,
  @JsonValue('location')
  location,
  @JsonValue('contact')
  contact,
}

@JsonSerializable()
class MediaFile {
  final String id;
  final String path;
  final MediaType type;
  final int? size;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const MediaFile({
    required this.id,
    required this.path,
    required this.type,
    this.size,
    required this.createdAt,
    required this.metadata,
  });

  factory MediaFile.create({
    required String path,
    required MediaType type,
    int? size,
    Map<String, dynamic> metadata = const {},
  }) {
    return MediaFile(
      id: const Uuid().v4(),
      path: path,
      type: type,
      size: size,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
  }

  MediaFile copyWith({
    String? id,
    String? path,
    MediaType? type,
    int? size,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return MediaFile(
      id: id ?? this.id,
      path: path ?? this.path,
      type: type ?? this.type,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  factory MediaFile.fromJson(Map<String, dynamic> json) => _$MediaFileFromJson(json);
  Map<String, dynamic> toJson() => _$MediaFileToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaFile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MediaFile{id: $id, path: $path, type: $type, size: $size}';
  }
} 