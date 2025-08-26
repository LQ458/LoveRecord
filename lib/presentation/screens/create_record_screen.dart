import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/models/record.dart';
import '../../data/models/media_file.dart';
import '../../business_logic/providers/record_provider.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../../services/ai/ai_service_factory.dart';
import '../../services/ai/ai_service.dart';
import '../../data/local/settings_service.dart';
import '../../l10n/app_localizations.dart';

class CreateRecordScreen extends ConsumerStatefulWidget {
  const CreateRecordScreen({super.key});

  @override
  ConsumerState<CreateRecordScreen> createState() => _CreateRecordScreenState();
}

class _CreateRecordScreenState extends ConsumerState<CreateRecordScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  
  RecordType _selectedType = RecordType.diary;
  final List<MediaFile> _mediaFiles = [];
  final List<String> _tags = [];
  bool _isLoading = false;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.createRecord,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isAnalyzing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: _analyzeContent,
            tooltip: l10n.aiAnalysis,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRecord,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeSelector(),
                  const SizedBox(height: 16),
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildContentField(),
                  const SizedBox(height: 16),
                  _buildMediaSection(),
                  const SizedBox(height: 16),
                  _buildTagsSection(),
                  const SizedBox(height: 16),
                  _buildAiAnalysisSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildTypeSelector() {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordType,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: RecordType.values.map((type) {
                final isSelected = _selectedType == type;
                return FilterChip(
                  label: Text(
                    _getTypeDisplayName(type),
                    style: TextStyle(
                      color: isSelected 
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: l10n.title,
        hintText: l10n.pleaseEnterTitle,
        border: const OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildContentField() {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _contentController,
      decoration: InputDecoration(
        labelText: l10n.content,
        hintText: l10n.pleaseEnterContent,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 8,
      textInputAction: TextInputAction.newline,
    );
  }

  Widget _buildMediaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '媒体文件',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text('${_mediaFiles.length} 个文件'),
              ],
            ),
            const SizedBox(height: 12),
            if (_mediaFiles.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mediaFiles.length,
                  itemBuilder: (context, index) {
                    final mediaFile = _mediaFiles[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _buildMediaPreview(mediaFile),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeMediaFile(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text('添加图片'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text('添加视频'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('添加文件'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(MediaFile mediaFile) {
    switch (mediaFile.type) {
      case MediaType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            mediaFile.path,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image, size: 40);
            },
          ),
        );
      case MediaType.video:
        return const Center(
          child: Icon(Icons.videocam, size: 40),
        );
      case MediaType.audio:
        return const Center(
          child: Icon(Icons.audiotrack, size: 40),
        );
      default:
        return const Center(
          child: Icon(Icons.insert_drive_file, size: 40),
        );
    }
  }

  Widget _buildTagsSection() {
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    final recordsAsync = ref.watch(recordsNotifierProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_offer, 
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFFE0E0E0) 
                      : const Color(0xFF212121)
                ),
                const SizedBox(width: 8),
                Text(
                  '标签',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text('${_tags.length} 个标签'),
              ],
            ),
            const SizedBox(height: 12),
            
            // Selected tags
            if (_tags.isNotEmpty) ...[
              Text(
                '已选标签:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF424242) 
                        : const Color(0xFFF5F5F5),
                    labelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFFE0E0E0) 
                          : const Color(0xFF212121)
                    ),
                    deleteIconColor: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFFE0E0E0) 
                        : const Color(0xFF212121),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // Tag input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      hintText: '输入标签，按回车添加',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(
                        Icons.add, 
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? const Color(0xFFE0E0E0) 
                            : const Color(0xFF212121)
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _addTag(value.trim());
                        _tagsController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_tagsController.text.trim().isNotEmpty) {
                      _addTag(_tagsController.text.trim());
                      _tagsController.clear();
                    }
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('添加'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF424242) 
                        : const Color(0xFFF5F5F5),
                    foregroundColor: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFFE0E0E0) 
                        : const Color(0xFF212121),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Popular/Recent tags suggestions
            recordsAsync.when(
              data: (records) {
                final allTags = <String>{};
                final tagCounts = <String, int>{};
                
                for (final record in records) {
                  for (final tag in record.tags) {
                    allTags.add(tag);
                    tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
                  }
                }
                
                // Remove already selected tags
                final availableTags = allTags.where((tag) => !_tags.contains(tag)).toList();
                
                // Sort by popularity
                availableTags.sort((a, b) => (tagCounts[b] ?? 0).compareTo(tagCounts[a] ?? 0));
                
                if (availableTags.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '热门标签推荐:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: availableTags.take(10).map((tag) {
                        final count = tagCounts[tag] ?? 0;
                        return ActionChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(tag),
                              if (count > 1) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? const Color(0xFF3A3A3A) 
                                        : const Color(0xFFE0E0E0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    count.toString(),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onPressed: () => _addTag(tag),
                          backgroundColor: Theme.of(context).brightness == Brightness.dark 
                              ? const Color(0xFF424242) 
                              : const Color(0xFFF5F5F5),
                          labelStyle: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFFE0E0E0) 
                                : const Color(0xFF212121)
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiAnalysisSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI智能分析',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'AI将分析你的内容，提供智能标签、情感分析和内容建议。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _analyzeContent,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('开始分析'),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeDisplayName(RecordType type) {
    final l10n = AppLocalizations.of(context);
    return l10n.getRecordTypeDisplayName(type.name);
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final size = await image.length();
        setState(() {
          _mediaFiles.add(MediaFile(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            path: image.path,
            type: MediaType.image,
            size: size,
            createdAt: DateTime.now(),
            metadata: {},
          ));
        });
      }
    } catch (e) {
      _showError(l10n.selectImageFailed.replaceAll('{error}', e.toString()));
    }
  }

  Future<void> _pickVideo() async {
    final l10n = AppLocalizations.of(context);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      
      if (video != null) {
        final size = await video.length();
        setState(() {
          _mediaFiles.add(MediaFile(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            path: video.path,
            type: MediaType.video,
            size: size,
            createdAt: DateTime.now(),
            metadata: {},
          ));
        });
      }
    } catch (e) {
      _showError(l10n.selectVideoFailed.replaceAll('{error}', e.toString()));
    }
  }

  Future<void> _pickFile() async {
    final l10n = AppLocalizations.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      
      if (result != null) {
        final file = result.files.first;
        setState(() {
          _mediaFiles.add(MediaFile(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            path: file.path ?? '',
            type: _getMediaTypeFromExtension(file.extension ?? ''),
            size: file.size,
            createdAt: DateTime.now(),
            metadata: {},
          ));
        });
      }
    } catch (e) {
      _showError(l10n.selectFileFailed.replaceAll('{error}', e.toString()));
    }
  }

  MediaType _getMediaTypeFromExtension(String extension) {
    final ext = extension.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return MediaType.image;
    } else if (['mp4', 'avi', 'mov', 'wmv', 'flv'].contains(ext)) {
      return MediaType.video;
    } else if (['mp3', 'wav', 'aac', 'flac'].contains(ext)) {
      return MediaType.audio;
    } else if (['pdf', 'doc', 'docx', 'txt'].contains(ext)) {
      return MediaType.document;
    } else {
      return MediaType.text;
    }
  }

  void _removeMediaFile(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
    });
  }

  void _addTag(String tag) {
    if (!_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _analyzeContent() async {
    if (_contentController.text.isEmpty) {
      _showError('请先输入内容');
      return;
    }

    // 检查配置
    final provider = SettingsService.aiProvider;
    final apiKey = SettingsService.apiKey;
    
    print('Debug - AI Provider: $provider');
    print('Debug - API Key exists: ${apiKey?.isNotEmpty ?? false}');
    print('Debug - API Key length: ${apiKey?.length ?? 0}');
    
    if (apiKey == null || apiKey.isEmpty) {
      _showError('请先在设置中配置API密钥\n\n当前配置:\n提供商: $provider\nAPI Key: 未配置');
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      print('Debug - Creating AI service with provider: $provider');
      final aiService = AiServiceFactory.createService(
        provider,
        apiKey: apiKey,
      );
      
      print('Debug - Testing connection...');
      final connectionTest = await aiService.testConnection();
      print('Debug - Connection test result: $connectionTest');
      
      if (!connectionTest) {
        _showError('AI服务连接测试失败\n\n请检查:\n• 网络连接\n• API Key是否正确\n• 账户余额是否充足');
        return;
      }
      
      print('Debug - Analyzing content...');
      final analysis = await aiService.analyzeContent(_contentController.text);
      print('Debug - Analysis completed: ${analysis.keywords.length} keywords, ${analysis.categories.length} categories');
      
      // 添加AI生成的关键词作为标签
      if (analysis.keywords.isNotEmpty) {
        setState(() {
          for (final keyword in analysis.keywords) {
            if (!_tags.contains(keyword)) {
              _tags.add(keyword);
            }
          }
        });
      }

      // 显示分析结果
      _showAnalysisResult(analysis);
    } catch (e) {
      print('Debug - AI analysis error: $e');
      _showError('AI分析失败: $e\n\n配置信息:\n提供商: $provider\nAPI Key: ${apiKey.substring(0, 8)}...');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _showAnalysisResult(ContentAnalysis analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI分析结果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (analysis.categories.isNotEmpty) ...[
              const Text('内容分类:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                children: analysis.categories.map((category) => Chip(label: Text(category))).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (analysis.keywords.isNotEmpty) ...[
              const Text('关键词:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                children: analysis.keywords.map((keyword) => Chip(label: Text(keyword))).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (analysis.summary.isNotEmpty) ...[
              const Text('内容摘要:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(analysis.summary),
              const SizedBox(height: 16),
            ],
            Text('置信度: ${(analysis.confidence * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRecord() async {
    if (_titleController.text.isEmpty) {
      _showError('请输入标题');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final record = Record.create(
        title: _titleController.text,
        content: _contentController.text,
        type: _selectedType,
        mediaFiles: _mediaFiles,
        tags: _tags,
      );

      await ref.read(recordsNotifierProvider.notifier).addRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('记录保存成功')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('保存记录失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
} 