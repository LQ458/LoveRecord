import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/record.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../themes/romantic_themes.dart';
import '../../l10n/app_localizations.dart';

class CalendarView extends ConsumerStatefulWidget {
  final List<Record> records;
  final Function(Record) onTap;
  final Function(Record) onDelete;

  const CalendarView({
    super.key,
    required this.records,
    required this.onTap,
    required this.onDelete,
  });

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    final recordsByDate = _groupRecordsByDate();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCalendarHeader(romanticTheme),
          _buildCalendarGrid(romanticTheme, recordsByDate),
          const SizedBox(height: 16),
          _buildSelectedDateRecords(romanticTheme, recordsByDate),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(RomanticThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              setState(() {
                _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
              });
            },
          ),
          Expanded(
            child: Text(
              DateFormat('yyyy年MM月').format(_focusedDate),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: () {
              setState(() {
                _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(RomanticThemeData theme, Map<String, List<Record>> recordsByDate) {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday % 7; // Make Sunday = 0
    final daysInMonth = lastDayOfMonth.day;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Week header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: AppLocalizations.of(context).weekDaysShort.map((day) {
                return Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : theme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Calendar grid - Fixed height container
          Container(
            height: 240, // Fixed height for 6 weeks * 40px
            child: Column(
              children: List.generate(6, (weekIndex) {
                return Expanded(
                  child: Row(
                    children: List.generate(7, (dayIndex) {
                      final dayNumber = weekIndex * 7 + dayIndex - firstDayOfWeek + 1;
                      
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return Expanded(child: Container());
                      }
                      
                      final date = DateTime(_focusedDate.year, _focusedDate.month, dayNumber);
                      final dateKey = _getDateKey(date);
                      final dayRecords = recordsByDate[dateKey] ?? [];
                      final isSelected = _isSameDay(date, _selectedDate);
                      final isToday = _isSameDay(date, DateTime.now());
                      
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.primary
                                  : isToday
                                      ? theme.primary.withOpacity(0.2)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: dayRecords.isNotEmpty
                                  ? Border.all(color: theme.secondary, width: 1)
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    dayNumber.toString(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : isToday
                                              ? theme.primary
                                              : theme.textPrimary,
                                      fontWeight: isSelected || isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                if (dayRecords.isNotEmpty)
                                  Positioned(
                                    top: 1,
                                    right: 1,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: theme.accent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          dayRecords.length.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateRecords(RomanticThemeData theme, Map<String, List<Record>> recordsByDate) {
    final dateKey = _getDateKey(_selectedDate);
    final dayRecords = recordsByDate[dateKey] ?? [];

    if (dayRecords.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.event_note,
              size: 48,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : theme.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              '${DateFormat('M月d日').format(_selectedDate)} 没有记录',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : theme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${DateFormat('M月d日').format(_selectedDate)} (${dayRecords.length}条记录)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : theme.textPrimary,
            ),
          ),
        ),
        ...dayRecords.map((record) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Container(
              width: 4,
              height: double.infinity,
              decoration: BoxDecoration(
                color: _getRecordTypeColor(record.type, theme),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: Text(
              record.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(record.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : theme.textSecondary,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('编辑'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  widget.onTap(record);
                } else if (value == 'delete') {
                  widget.onDelete(record);
                }
              },
            ),
            onTap: () => widget.onTap(record),
          ),
        )).toList(),
      ],
    );
  }

  Map<String, List<Record>> _groupRecordsByDate() {
    final Map<String, List<Record>> grouped = {};
    
    for (final record in widget.records) {
      final dateKey = _getDateKey(record.createdAt);
      grouped[dateKey] = (grouped[dateKey] ?? [])..add(record);
    }
    
    // Sort records within each day by creation time
    grouped.forEach((key, records) {
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
    
    return grouped;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Color _getRecordTypeColor(RecordType type, RomanticThemeData theme) {
    switch (type) {
      case RecordType.diary:
        return theme.primary;
      case RecordType.work:
        return Colors.blue;
      case RecordType.study:
        return Colors.green;
      case RecordType.travel:
        return Colors.orange;
      case RecordType.health:
        return Colors.red;
      case RecordType.finance:
        return Colors.purple;
      case RecordType.creative:
        return Colors.teal;
    }
  }
}