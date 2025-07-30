import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/record.dart';
import '../../data/models/media_file.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../themes/romantic_themes.dart';
import 'calendar_view.dart';

/// Different presentation styles for records
enum RecordPresentationStyle {
  timeline,
  masonry,
  moodBased,
  memoryBook,
  compact,
  calendar,
  statistics,
}

extension RecordPresentationStyleExtension on RecordPresentationStyle {
  String get displayName {
    switch (this) {
      case RecordPresentationStyle.timeline:
        return '时间轴';
      case RecordPresentationStyle.masonry:
        return '瀑布流';
      case RecordPresentationStyle.moodBased:
        return '情感视图';
      case RecordPresentationStyle.memoryBook:
        return '回忆录';
      case RecordPresentationStyle.compact:
        return '简洁列表';
      case RecordPresentationStyle.calendar:
        return '日历视图';
      case RecordPresentationStyle.statistics:
        return '统计视图';
    }
  }
  
  IconData get icon {
    switch (this) {
      case RecordPresentationStyle.timeline:
        return Icons.timeline;
      case RecordPresentationStyle.masonry:
        return Icons.view_quilt;
      case RecordPresentationStyle.moodBased:
        return Icons.emoji_emotions;
      case RecordPresentationStyle.memoryBook:
        return Icons.menu_book;
      case RecordPresentationStyle.compact:
        return Icons.view_list;
      case RecordPresentationStyle.calendar:
        return Icons.calendar_month;
      case RecordPresentationStyle.statistics:
        return Icons.analytics;
    }
  }
}

/// Main presentation block widget
class RecordPresentationBlock extends ConsumerWidget {
  final List<Record> records;
  final RecordPresentationStyle style;
  final Function(Record) onTap;
  final Function(Record) onDelete;
  final ScrollController? scrollController;
  
  const RecordPresentationBlock({
    super.key,
    required this.records,
    required this.style,
    required this.onTap,
    required this.onDelete,
    this.scrollController,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (style) {
      case RecordPresentationStyle.timeline:
        return TimelineRecordView(
          records: records,
          onTap: onTap,
          onDelete: onDelete,
          scrollController: scrollController,
        );
      case RecordPresentationStyle.masonry:
        return MasonryRecordView(
          records: records,
          onTap: onTap,
          onDelete: onDelete,
          scrollController: scrollController,
        );
      case RecordPresentationStyle.moodBased:
        return MoodBasedRecordView(
          records: records,
          onTap: onTap,
          onDelete: onDelete,
          scrollController: scrollController,
        );
      case RecordPresentationStyle.memoryBook:
        return MemoryBookRecordView(
          records: records,
          onTap: onTap,
          onDelete: onDelete,
          scrollController: scrollController,
        );
      case RecordPresentationStyle.compact:
        return CompactRecordView(
          records: records,
          onTap: onTap,
          onDelete: onDelete,
          scrollController: scrollController,
        );
      case RecordPresentationStyle.calendar:
        return CalendarView(
          records: records,
          onTap: onTap,
          onDelete: onDelete,
        );
      case RecordPresentationStyle.statistics:
        return StatisticsRecordView(
          records: records,
          onTap: onTap,
          onDelete: onDelete,
          scrollController: scrollController,
        );
    }
  }
}

/// Timeline view with date headers
class TimelineRecordView extends ConsumerWidget {
  final List<Record> records;
  final Function(Record) onTap;
  final Function(Record) onDelete;
  final ScrollController? scrollController;
  
  const TimelineRecordView({
    super.key,
    required this.records,
    required this.onTap,
    required this.onDelete,
    this.scrollController,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    final groupedRecords = _groupRecordsByDate(records);
    
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: groupedRecords.length,
      itemBuilder: (context, index) {
        final entry = groupedRecords.entries.elementAt(index);
        final date = entry.key;
        final dayRecords = entry.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(context, date, romanticTheme),
            const SizedBox(height: 12),
            ...dayRecords.map((record) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTimelineCard(context, record, romanticTheme),
            )),
          ],
        );
      },
    );
  }
  
  Widget _buildDateHeader(BuildContext context, DateTime date, RomanticThemeData theme) {
    final isToday = _isToday(date);
    final isYesterday = _isYesterday(date);
    
    String dateText;
    if (isToday) {
      dateText = '今天';
    } else if (isYesterday) {
      dateText = '昨天';
    } else {
      dateText = DateFormat('M月d日 EEEE', 'zh_CN').format(date);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        dateText,
        style: TextStyle(
          color: theme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
  
  Widget _buildTimelineCard(BuildContext context, Record record, RomanticThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(left: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => onTap(record),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(record.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildRecordTypeChip(record.type, theme, isDark: Theme.of(context).brightness == Brightness.dark),
                ],
              ),
              if (record.content.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  record.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (record.mediaFiles.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildMediaPreview(record.mediaFiles, theme),
              ],
              if (record.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildTagsRow(record.tags, theme, isDark: Theme.of(context).brightness == Brightness.dark),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Map<DateTime, List<Record>> _groupRecordsByDate(List<Record> records) {
    final Map<DateTime, List<Record>> grouped = {};
    
    for (final record in records) {
      final date = DateTime(
        record.createdAt.year,
        record.createdAt.month,
        record.createdAt.day,
      );
      
      grouped.putIfAbsent(date, () => []).add(record);
    }
    
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }
}

/// Masonry/Pinterest-style grid view
class MasonryRecordView extends ConsumerWidget {
  final List<Record> records;
  final Function(Record) onTap;
  final Function(Record) onDelete;
  final ScrollController? scrollController;
  
  const MasonryRecordView({
    super.key,
    required this.records,
    required this.onTap,
    required this.onDelete,
    this.scrollController,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final record = records[index];
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: _buildMasonryCard(context, record, romanticTheme),
                );
              },
              childCount: records.length,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMasonryCard(BuildContext context, Record record, RomanticThemeData theme) {
    final hasMedia = record.mediaFiles.isNotEmpty;
    final hasLongContent = record.content.length > 100;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => onTap(record),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasMedia) _buildCardMedia(record.mediaFiles.first, theme),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (record.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      record.content,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: hasLongContent ? 6 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('M/d').format(record.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: theme.textSecondary,
                        ),
                      ),
                      _buildRecordTypeIcon(record.type, theme),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCardMedia(MediaFile mediaFile, RomanticThemeData theme) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          colors: theme.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          _getMediaIcon(mediaFile.type),
          size: 40,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }
}

/// Mood-based view with emotion colors
class MoodBasedRecordView extends ConsumerWidget {
  final List<Record> records;
  final Function(Record) onTap;
  final Function(Record) onDelete;
  final ScrollController? scrollController;
  
  const MoodBasedRecordView({
    super.key,
    required this.records,
    required this.onTap,
    required this.onDelete,
    this.scrollController,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMoodCard(context, record, romanticTheme),
        );
      },
    );
  }
  
  Widget _buildMoodCard(BuildContext context, Record record, RomanticThemeData theme) {
    final moodColor = _getMoodColor(record, theme);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            moodColor.withOpacity(0.1),
            moodColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: moodColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () => onTap(record),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: moodColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getMoodIcon(record),
                        color: moodColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            DateFormat('M月d日 HH:mm').format(record.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildMoodIndicator(record, moodColor),
                  ],
                ),
                if (record.content.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    record.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (record.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildTagsRow(record.tags, theme, isDark: Theme.of(context).brightness == Brightness.dark),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getMoodColor(Record record, RomanticThemeData theme) {
    // Simulate mood analysis based on content keywords
    final content = record.content.toLowerCase();
    if (content.contains('开心') || content.contains('快乐') || content.contains('幸福')) {
      return Colors.amber;
    } else if (content.contains('伤心') || content.contains('难过') || content.contains('失落')) {
      return Colors.indigo;
    } else if (content.contains('爱') || content.contains('喜欢') || content.contains('浪漫')) {
      return theme.primary;
    } else if (content.contains('生气') || content.contains('愤怒')) {
      return Colors.red;
    }
    return theme.secondary;
  }
  
  IconData _getMoodIcon(Record record) {
    final content = record.content.toLowerCase();
    if (content.contains('开心') || content.contains('快乐') || content.contains('幸福')) {
      return Icons.sentiment_very_satisfied;
    } else if (content.contains('伤心') || content.contains('难过') || content.contains('失落')) {
      return Icons.sentiment_very_dissatisfied;
    } else if (content.contains('爱') || content.contains('喜欢') || content.contains('浪漫')) {
      return Icons.favorite;
    } else if (content.contains('生气') || content.contains('愤怒')) {
      return Icons.sentiment_dissatisfied;
    }
    return Icons.sentiment_neutral;
  }
  
  Widget _buildMoodIndicator(Record record, Color moodColor) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: moodColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: moodColor.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// Memory book style view
class MemoryBookRecordView extends ConsumerWidget {
  final List<Record> records;
  final Function(Record) onTap;
  final Function(Record) onDelete;
  final ScrollController? scrollController;
  
  const MemoryBookRecordView({
    super.key,
    required this.records,
    required this.onTap,
    required this.onDelete,
    this.scrollController,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildMemoryCard(context, record, romanticTheme),
        );
      },
    );
  }
  
  Widget _buildMemoryCard(BuildContext context, Record record, RomanticThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => onTap(record),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and type
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: theme.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('yyyy年M月d日').format(record.createdAt),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE HH:mm', 'zh_CN').format(record.createdAt),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildRecordTypeChip(record.type, theme, isLight: true, isDark: Theme.of(context).brightness == Brightness.dark),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (record.content.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.secondary.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          record.content,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    if (record.mediaFiles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildMediaGrid(record.mediaFiles, theme),
                    ],
                    if (record.tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildTagsRow(record.tags, theme),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact list view
class CompactRecordView extends ConsumerWidget {
  final List<Record> records;
  final Function(Record) onTap;
  final Function(Record) onDelete;
  final ScrollController? scrollController;
  
  const CompactRecordView({
    super.key,
    required this.records,
    required this.onTap,
    required this.onDelete,
    this.scrollController,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF3A3A3A) 
            : const Color(0xFFE0E0E0),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildCompactTile(context, record, romanticTheme);
      },
    );
  }
  
  Widget _buildCompactTile(BuildContext context, Record record, RomanticThemeData theme) {
    return ListTile(
      onTap: () => onTap(record),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getRecordTypeIcon(record.type),
          size: 24,
          color: Colors.white,
        ),
      ),
      title: Text(
        record.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (record.content.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              record.content,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                DateFormat('M/d HH:mm').format(record.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: theme.textSecondary,
                ),
              ),
              if (record.mediaFiles.isNotEmpty) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.attach_file,
                  size: 12,
                  color: theme.textSecondary,
                ),
                Text(
                  '${record.mediaFiles.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: _buildRecordTypeIcon(record.type, theme),
    );
  }
}

// Helper widgets and functions
Widget _buildRecordTypeChip(RecordType type, RomanticThemeData theme, {bool isLight = false, bool isDark = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isLight ? Colors.white.withOpacity(0.2) : (isDark ? const Color(0xFF424242) : const Color(0xFFF5F5F5)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      _getRecordTypeDisplayName(type),
      style: TextStyle(
        color: isLight ? Colors.white : (isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121)),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

Widget _buildRecordTypeIcon(RecordType type, RomanticThemeData theme) {
  return Builder(
    builder: (context) => Icon(
      _getRecordTypeIcon(type),
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFFE0E0E0) 
          : const Color(0xFF212121),
      size: 20,
    ),
  );
}

Widget _buildMediaPreview(List<MediaFile> mediaFiles, RomanticThemeData theme) {
  return SizedBox(
    height: 60,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: mediaFiles.length.clamp(0, 5),
      itemBuilder: (context, index) {
        final mediaFile = mediaFiles[index];
        return Container(
          width: 60,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getMediaIcon(mediaFile.type),
            color: Colors.white.withOpacity(0.8),
            size: 24,
          ),
        );
      },
    ),
  );
}

Widget _buildMediaGrid(List<MediaFile> mediaFiles, RomanticThemeData theme) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: mediaFiles.take(6).map((mediaFile) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _getMediaIcon(mediaFile.type),
          color: Colors.white.withOpacity(0.8),
          size: 32,
        ),
      );
    }).toList(),
  );
}

Widget _buildTagsRow(List<String> tags, RomanticThemeData theme, {bool isDark = false}) {
  return Wrap(
    spacing: 6,
    runSpacing: 4,
    children: tags.take(5).map((tag) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF424242) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }).toList(),
  );
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
  switch (type) {
    case RecordType.diary:
      return '日记';
    case RecordType.work:
      return '工作';
    case RecordType.study:
      return '学习';
    case RecordType.travel:
      return '旅行';
    case RecordType.health:
      return '健康';
    case RecordType.finance:
      return '财务';
    case RecordType.creative:
      return '创意';
  }
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
}

/// Statistics view with charts and insights
class StatisticsRecordView extends ConsumerWidget {
  final List<Record> records;
  final Function(Record) onTap;
  final Function(Record) onDelete;
  final ScrollController? scrollController;

  const StatisticsRecordView({
    super.key,
    required this.records,
    required this.onTap,
    required this.onDelete,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentRomanticThemeDataProvider);
    
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallStats(theme),
          const SizedBox(height: 24),
          _buildRecordTypeStats(theme),
          const SizedBox(height: 24),
          _buildTimelineStats(theme),
          const SizedBox(height: 24),
          _buildMediaStats(theme),
          const SizedBox(height: 24),
          _buildTagStats(theme),
        ],
      ),
    );
  }

  Widget _buildOverallStats(RomanticThemeData theme) {
    final totalRecords = records.length;
    final totalDays = records.isNotEmpty 
        ? DateTime.now().difference(records.last.createdAt).inDays + 1
        : 0;
    final averagePerDay = totalDays > 0 ? (totalRecords / totalDays).toStringAsFixed(1) : '0';
    final totalMediaFiles = records.fold(0, (sum, record) => sum + record.mediaFiles.length);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: theme.primary),
                const SizedBox(width: 8),
                Text(
                  '总体统计',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('总记录数', totalRecords.toString(), Icons.article, theme),
                ),
                Expanded(
                  child: _buildStatItem('记录天数', totalDays.toString(), Icons.calendar_today, theme),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('日均记录', averagePerDay, Icons.trending_up, theme),
                ),
                Expanded(
                  child: _buildStatItem('媒体文件', totalMediaFiles.toString(), Icons.attachment, theme),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTypeStats(RomanticThemeData theme) {
    final typeCount = <RecordType, int>{};
    for (final record in records) {
      typeCount[record.type] = (typeCount[record.type] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, color: theme.primary),
                const SizedBox(width: 8),
                Text(
                  '记录类型分布',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...typeCount.entries.map((entry) {
              final percentage = records.isNotEmpty 
                  ? (entry.value / records.length * 100).round()
                  : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(_getRecordTypeIcon(entry.key), size: 20, color: theme.secondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_getRecordTypeDisplayName(entry.key)),
                    ),
                    Text(
                      '${entry.value} ($percentage%)',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStats(RomanticThemeData theme) {
    final monthlyCount = <String, int>{};
    for (final record in records) {
      final monthKey = DateFormat('yyyy-MM').format(record.createdAt);
      monthlyCount[monthKey] = (monthlyCount[monthKey] ?? 0) + 1;
    }

    final sortedMonths = monthlyCount.keys.toList()..sort();
    final last6Months = sortedMonths.length > 6 
        ? sortedMonths.sublist(sortedMonths.length - 6)
        : sortedMonths;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: theme.primary),
                const SizedBox(width: 8),
                Text(
                  '近期活跃度',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: last6Months.map((month) {
                  final count = monthlyCount[month] ?? 0;
                  final maxCount = monthlyCount.values.isNotEmpty 
                      ? monthlyCount.values.reduce((a, b) => a > b ? a : b)
                      : 1;
                  final height = (count / maxCount * 70).clamp(4.0, 70.0);
                  
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 24,
                        height: height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: theme.gradient,
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('MM').format(DateTime.parse('$month-01')),
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaStats(RomanticThemeData theme) {
    final mediaTypeCount = <MediaType, int>{};
    for (final record in records) {
      for (final media in record.mediaFiles) {
        mediaTypeCount[media.type] = (mediaTypeCount[media.type] ?? 0) + 1;
      }
    }

    if (mediaTypeCount.isEmpty) {
      return const SizedBox.shrink();
    }

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
                  '媒体文件统计',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: mediaTypeCount.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getMediaIcon(entry.key), size: 20, color: theme.secondary),
                    const SizedBox(width: 8),
                    Text('${entry.value}'),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagStats(RomanticThemeData theme) {
    final tagCount = <String, int>{};
    for (final record in records) {
      for (final tag in record.tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }

    if (tagCount.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedTags = tagCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sortedTags.take(10).toList();

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
                  '热门标签',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topTags.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.secondary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.secondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.value.toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, RomanticThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.gradient.map((c) => c.withOpacity(0.1)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Note: For a real masonry grid implementation, consider using packages like:
// - flutter_staggered_grid_view
// - flutter_layout_grid
// Currently using standard grid for simplicity