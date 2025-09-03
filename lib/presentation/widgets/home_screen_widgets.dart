import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/system/widget_service.dart';
import '../../services/system/system_monitor_service.dart';
import '../../business_logic/providers/theme_provider.dart';

/// Apple-style home screen widget components
/// Follows iOS Human Interface Guidelines for widget design

/// Small Widget (2x2) - Partner Status
class PartnerStatusSmallWidget extends ConsumerWidget {
  final PartnerStatusWidget data;

  const PartnerStatusSmallWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentRomanticThemeDataProvider);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Partner name and mood
          Row(
            children: [
              Icon(
                _getMoodIcon(data.mood),
                size: 16,
                color: _getMoodColor(data.mood),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  data.partnerName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Battery level
          Row(
            children: [
              Icon(
                _getBatteryIcon(data.batteryLevel),
                size: 14,
                color: _getBatteryColor(data.batteryLevel),
              ),
              const SizedBox(width: 4),
              Text(
                '${data.batteryLevel}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getBatteryColor(data.batteryLevel),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 2),
          
          // Current activity
          Text(
            data.currentActivity,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.hintColor,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': return Icons.sentiment_very_satisfied;
      case 'excited': return Icons.celebration;
      case 'love': return Icons.favorite;
      case 'sad': return Icons.sentiment_dissatisfied;
      case 'stressed': return Icons.mood_bad;
      case 'tired': return Icons.bedtime;
      case 'working': return Icons.work;
      default: return Icons.sentiment_neutral;
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': return Colors.green;
      case 'excited': return Colors.orange;
      case 'love': return Colors.pink;
      case 'sad': return Colors.blue;
      case 'stressed': return Colors.red;
      case 'tired': return Colors.purple;
      case 'working': return Colors.indigo;
      default: return Colors.grey;
    }
  }

  IconData _getBatteryIcon(int level) {
    if (level >= 90) return Icons.battery_full;
    if (level >= 60) return Icons.battery_5_bar;
    if (level >= 30) return Icons.battery_3_bar;
    if (level >= 15) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  Color _getBatteryColor(int level) {
    if (level >= 30) return Colors.green;
    if (level >= 15) return Colors.orange;
    return Colors.red;
  }
}

/// Medium Widget (4x2) - Shared Todos
class SharedTodosMediumWidget extends ConsumerWidget {
  final SharedTodosWidget data;

  const SharedTodosMediumWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentRomanticThemeDataProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.checklist_rtl,
                size: 20,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Our Todos',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${data.completedToday}/${data.totalCount}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Todo items (top 3)
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: data.todos.take(3).length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final todo = data.todos[index];
                return _buildTodoItem(todo, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(TodoItem todo, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        // Handle todo completion via widget interaction
        WidgetService.handleWidgetAction(
          action: 'toggle_todo',
          parameters: {'todoId': todo.id},
        );
      },
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: todo.isCompleted ? Colors.green : theme.hintColor,
                width: 2,
              ),
              color: todo.isCompleted ? Colors.green : Colors.transparent,
            ),
            child: todo.isCompleted
                ? const Icon(
                    Icons.check,
                    size: 10,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              todo.title,
              style: theme.textTheme.bodySmall?.copyWith(
                decoration: todo.isCompleted 
                    ? TextDecoration.lineThrough 
                    : TextDecoration.none,
                color: todo.isCompleted 
                    ? theme.hintColor 
                    : theme.textTheme.bodySmall?.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (todo.priority == 'high')
            Icon(
              Icons.priority_high,
              size: 14,
              color: Colors.red,
            ),
        ],
      ),
    );
  }
}

/// Large Widget (4x4) - Relationship Dashboard
class RelationshipDashboardLargeWidget extends ConsumerWidget {
  final DaysCounterWidget daysCounter;
  final PartnerStatusWidget partnerStatus;
  final SharedTodosWidget sharedTodos;

  const RelationshipDashboardLargeWidget({
    super.key,
    required this.daysCounter,
    required this.partnerStatus,
    required this.sharedTodos,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentRomanticThemeDataProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with days counter
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      daysCounter.milestone,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${daysCounter.daysSince}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'days',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.favorite,
                size: 32,
                color: theme.primaryColor.withOpacity(0.3),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Partner status section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _getMoodIcon(partnerStatus.mood),
                  color: _getMoodColor(partnerStatus.mood),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partnerStatus.partnerName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${partnerStatus.mood} • ${partnerStatus.currentActivity}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      _getBatteryIcon(partnerStatus.batteryLevel),
                      size: 16,
                      color: _getBatteryColor(partnerStatus.batteryLevel),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${partnerStatus.batteryLevel}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getBatteryColor(partnerStatus.batteryLevel),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Shared todos section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Today\'s Goals',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    _buildProgressIndicator(
                      sharedTodos.completedToday,
                      sharedTodos.totalCount,
                      theme,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: sharedTodos.todos.take(4).length,
                    separatorBuilder: (context, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final todo = sharedTodos.todos[index];
                      return _buildCompactTodoItem(todo, theme);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int completed, int total, ThemeData theme) {
    final progress = total > 0 ? completed / total : 0.0;
    
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 6,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.primaryColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$completed/$total',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.hintColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTodoItem(TodoItem todo, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: todo.isCompleted ? Colors.green : theme.hintColor,
              width: 1.5,
            ),
            color: todo.isCompleted ? Colors.green : Colors.transparent,
          ),
          child: todo.isCompleted
              ? const Icon(
                  Icons.check,
                  size: 8,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            todo.title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              decoration: todo.isCompleted 
                  ? TextDecoration.lineThrough 
                  : TextDecoration.none,
              color: todo.isCompleted 
                  ? theme.hintColor 
                  : theme.textTheme.bodySmall?.color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper methods (same as in PartnerStatusSmallWidget)
  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': return Icons.sentiment_very_satisfied;
      case 'excited': return Icons.celebration;
      case 'love': return Icons.favorite;
      case 'sad': return Icons.sentiment_dissatisfied;
      case 'stressed': return Icons.mood_bad;
      case 'tired': return Icons.bedtime;
      case 'working': return Icons.work;
      default: return Icons.sentiment_neutral;
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': return Colors.green;
      case 'excited': return Colors.orange;
      case 'love': return Colors.pink;
      case 'sad': return Colors.blue;
      case 'stressed': return Colors.red;
      case 'tired': return Colors.purple;
      case 'working': return Colors.indigo;
      default: return Colors.grey;
    }
  }

  IconData _getBatteryIcon(int level) {
    if (level >= 90) return Icons.battery_full;
    if (level >= 60) return Icons.battery_5_bar;
    if (level >= 30) return Icons.battery_3_bar;
    if (level >= 15) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  Color _getBatteryColor(int level) {
    if (level >= 30) return Colors.green;
    if (level >= 15) return Colors.orange;
    return Colors.red;
  }
}

/// Quick Love Note Widget (Small/Medium)
class QuickLoveNoteWidget extends ConsumerWidget {
  final QuickLoveNoteWidget data;
  final WidgetService.WidgetSize size;

  const QuickLoveNoteWidget({
    super.key,
    required this.data,
    required this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentRomanticThemeDataProvider);
    
    return GestureDetector(
      onTap: () => _sendQuickLoveNote(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              color: Colors.white,
              size: size == WidgetService.WidgetSize.small ? 24 : 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Send Love',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (size != WidgetService.WidgetSize.small) ...[
              const SizedBox(height: 4),
              Text(
                'Quick message',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _sendQuickLoveNote(BuildContext context) {
    // Handle sending quick love note
    WidgetService.handleWidgetAction(
      action: 'send_quick_love_note',
      parameters: {
        'message': data.data.quickMessages.first,
      },
    );
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❤️ Love note sent!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}