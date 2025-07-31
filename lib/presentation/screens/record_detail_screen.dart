import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/record.dart';
import '../../data/models/media_file.dart';
import '../../business_logic/providers/record_provider.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../themes/romantic_themes.dart';
import '../../l10n/app_localizations.dart';

class RecordDetailScreen extends ConsumerStatefulWidget {
  final String recordId;
  
  const RecordDetailScreen({
    super.key,
    required this.recordId,
  });

  @override
  ConsumerState<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends ConsumerState<RecordDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late RecordType _selectedType;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _selectedType = RecordType.diary;
    _tags = [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recordAsync = ref.watch(recordNotifierProvider(widget.recordId));
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.editRecord : l10n.recordDetails,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _startEditing(),
              tooltip: l10n.edit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(),
              tooltip: l10n.delete,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _saveRecord(),
              tooltip: l10n.save,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _cancelEditing(),
              tooltip: l10n.cancel,
            ),
          ],
        ],
      ),
      body: recordAsync.when(
        data: (record) {
          if (record == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFFB0B0B0) 
                        : const Color(0xFF757575),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '记录不存在',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFFE0E0E0) 
                          : const Color(0xFF212121),
                    ),
                  ),
                ],
              ),
            );
          }

          // 初始化编辑控制器
          if (!_isEditing) {
            _titleController.text = record.title;
            _contentController.text = record.content;
            _selectedType = record.type;
            _tags = List.from(record.tags);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(record, romanticTheme),
                const SizedBox(height: 24),
                _buildContent(record, romanticTheme),
                if (record.mediaFiles.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildMediaSection(record, romanticTheme),
                ],
                if (record.tags.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildTagsSection(record, romanticTheme),
                ],
                const SizedBox(height: 24),
                _buildMetadata(record, romanticTheme),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFFB0B0B0) 
                    : const Color(0xFF757575),
              ),
              const SizedBox(height: 16),
              Text(
                '加载失败: $error',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFFE0E0E0) 
                      : const Color(0xFF212121),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(recordNotifierProvider(widget.recordId));
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Record record, RomanticThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing) ...[
              TextField(
                controller: _titleController,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '输入标题...',
                ),
              ),
              const SizedBox(height: 16),
              _buildTypeSelector(theme),
            ] else ...[
              Text(
                record.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : theme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFF424242) 
                          : theme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? const Color(0xFF4A4A4A) 
                            : theme.primary.withOpacity(0.3)
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getRecordTypeIcon(record.type),
                          size: 16,
                          color: theme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getRecordTypeDisplayName(record.type),
                          style: TextStyle(
                            color: theme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('yyyy年M月d日 EEEE', 'zh_CN').format(record.createdAt),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[400] 
                          : theme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(RomanticThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '记录类型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : theme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: RecordType.values.map((type) {
            final isSelected = _selectedType == type;
            return FilterChip(
              label: Text(_getRecordTypeDisplayName(type)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType = type;
                });
              },
              selectedColor: theme.primary.withOpacity(0.2),
              checkmarkColor: theme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContent(Record record, RomanticThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: theme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.content,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isEditing) ...[
              TextField(
                controller: _contentController,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '记录你的想法、感受或经历...',
                ),
              ),
              const SizedBox(height: 16),
              _buildTagsEditor(theme),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.secondary.withOpacity(0.2)),
                ),
                child: Text(
                  record.content.isEmpty ? l10n.noContent : record.content,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: record.content.isEmpty 
                        ? (Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[400] 
                            : theme.textSecondary)
                        : (Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : theme.textPrimary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTagsEditor(RomanticThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tags,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: _tags.map((tag) {
            return Chip(
              label: Text(tag),
              onDeleted: () {
                setState(() {
                  _tags.remove(tag);
                });
              },
              deleteIcon: const Icon(Icons.close, size: 18),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.addNewTag,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty && !_tags.contains(value)) {
                    setState(() {
                      _tags.add(value);
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaSection(Record record, RomanticThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.perm_media, color: theme.primary),
                const SizedBox(width: 8),
                Text(
                  '媒体文件',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  '${record.mediaFiles.length} 个文件',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400] 
                        : theme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: record.mediaFiles.length,
                itemBuilder: (context, index) {
                  final mediaFile = record.mediaFiles[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: theme.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getMediaIcon(mediaFile.type),
                            size: 32,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getMediaTypeDisplayName(mediaFile.type),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(Record record, RomanticThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_offer, color: theme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.tags,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: record.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.secondary.withOpacity(0.3)),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                                          color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : theme.textPrimary,
                    fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadata(Record record, RomanticThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.recordInfo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetadataItem('创建时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(record.createdAt), theme),
            _buildMetadataItem('更新时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(record.updatedAt), theme),
            _buildMetadataItem('记录ID', record.id, theme),
            if (record.metadata.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '元数据',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.metadata.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400] 
                        : theme.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value, RomanticThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[400] 
                    : theme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : theme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _saveRecord() async {
    final recordAsync = ref.read(recordNotifierProvider(widget.recordId));
    final currentRecord = recordAsync.valueOrNull;
    
    if (currentRecord == null) return;

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入标题')),
      );
      return;
    }

    try {
      final updatedRecord = currentRecord.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        type: _selectedType,
        tags: _tags,
        updatedAt: DateTime.now(),
      );

      await ref.read(recordNotifierProvider(widget.recordId).notifier).updateRecord(updatedRecord);
      
      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('记录已保存')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条记录吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteRecord();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRecord() async {
    try {
      await ref.read(recordsNotifierProvider.notifier).deleteRecord(widget.recordId);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('记录已删除')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  IconData _getRecordTypeIcon(RecordType type) {
    switch (type) {
      case RecordType.diary:
        return Icons.book;
      case RecordType.work:
        return Icons.work;
      case RecordType.study:
        return Icons.school;
      case RecordType.travel:
        return Icons.flight;
      case RecordType.health:
        return Icons.favorite;
      case RecordType.finance:
        return Icons.account_balance_wallet;
      case RecordType.creative:
        return Icons.palette;
    }
  }

  String _getRecordTypeDisplayName(RecordType type) {
    final l10n = AppLocalizations.of(context);
    return l10n.getRecordTypeDisplayName(type.name);
  }

  IconData _getMediaIcon(MediaType type) {
    switch (type) {
      case MediaType.image:
        return Icons.image;
      case MediaType.video:
        return Icons.videocam;
      case MediaType.audio:
        return Icons.audiotrack;
      case MediaType.document:
        return Icons.description;
      case MediaType.location:
        return Icons.location_on;
      case MediaType.contact:
        return Icons.contact_page;
      case MediaType.text:
        return Icons.text_fields;
    }
    return Icons.file_present; // 默认图标
  }

  String _getMediaTypeDisplayName(MediaType type) {
    switch (type) {
      case MediaType.image:
        return '图片';
      case MediaType.video:
        return '视频';
      case MediaType.audio:
        return '音频';
      case MediaType.document:
        return '文档';
      case MediaType.location:
        return '位置';
      case MediaType.contact:
        return '联系人';
      case MediaType.text:
        return '文本';
    }
  }
} 