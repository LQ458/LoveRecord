import 'package:flutter/material.dart';
import '../../data/models/record.dart';
import '../../data/models/media_file.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

class RecordCard extends StatelessWidget {
  final Record record;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const RecordCard({
    super.key,
    required this.record,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和操作按钮
              Row(
                children: [
                  Expanded(
                    child: Text(
                      record.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 内容预览
              if (record.content.isNotEmpty)
                Text(
                  record.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 12),
              
              // 标签
              if (record.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: record.tags.take(3).map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 12),
              
              // 底部信息
              Row(
                children: [
                  // 类型标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(record.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getTypeColor(record.type).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getTypeDisplayName(context, record.type),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTypeColor(record.type),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // 媒体文件数量
                  if (record.mediaFiles.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getMediaIcon(record.mediaFiles.first.type),
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${record.mediaFiles.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  
                  const SizedBox(width: 12),
                  
                  // 创建时间
                  Text(
                    _formatDate(record.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取类型显示名称
  String _getTypeDisplayName(BuildContext context, RecordType type) {
    final l10n = AppLocalizations.of(context);
    return l10n.getRecordTypeDisplayName(type.name);
  }

  /// 获取类型颜色
  Color _getTypeColor(RecordType type) {
    switch (type) {
      case RecordType.diary:
        return Colors.blue;
      case RecordType.work:
        return Colors.orange;
      case RecordType.study:
        return Colors.green;
      case RecordType.travel:
        return Colors.purple;
      case RecordType.health:
        return Colors.red;
      case RecordType.finance:
        return Colors.teal;
      case RecordType.creative:
        return Colors.pink;
    }
  }

  /// 获取媒体类型图标
  IconData _getMediaIcon(MediaType type) {
    switch (type) {
      case MediaType.image:
        return Icons.image;
      case MediaType.audio:
        return Icons.audiotrack;
      case MediaType.video:
        return Icons.videocam;
      case MediaType.document:
        return Icons.description;
      case MediaType.location:
        return Icons.location_on;
      case MediaType.contact:
        return Icons.contact_phone;
      case MediaType.text:
        return Icons.text_fields;
    }
    return Icons.attach_file; // 默认图标
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}周前';
    } else {
      return DateFormat('MM/dd').format(date);
    }
  }
} 