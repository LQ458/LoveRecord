import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business_logic/providers/todo_provider.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../../data/models/todo_item.dart';
import '../themes/romantic_themes.dart';

class TodoStatsWidget extends ConsumerWidget {
  const TodoStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoNotifierProvider);
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return todosAsync.when(
      data: (todos) {
        if (todos.isEmpty) return const SizedBox.shrink();

        final stats = _calculateStats(todos);
        
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: romanticTheme.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: romanticTheme.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Main progress section
              Row(
                children: [
                  // Progress circle
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: stats.completionRate / 100,
                            strokeWidth: 6,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${stats.completionRate.toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Stats details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow(
                          icon: Icons.check_circle,
                          label: 'Completed',
                          count: stats.completed,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow(
                          icon: Icons.radio_button_unchecked,
                          label: 'Pending',
                          count: stats.pending,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow(
                          icon: Icons.schedule,
                          label: 'Overdue',
                          count: stats.overdue,
                          color: stats.overdue > 0 ? Colors.red[100]! : Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (stats.todayTasks > 0 || stats.dueSoon > 0) ...[
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                
                // Today and upcoming section
                Row(
                  children: [
                    if (stats.todayTasks > 0) ...[
                      Expanded(
                        child: _buildQuickStat(
                          'Today',
                          stats.todayTasks,
                          Icons.today,
                          Colors.white,
                        ),
                      ),
                    ],
                    if (stats.todayTasks > 0 && stats.dueSoon > 0)
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    if (stats.dueSoon > 0) ...[
                      Expanded(
                        child: _buildQuickStat(
                          'Due Soon',
                          stats.dueSoon,
                          Icons.upcoming,
                          Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  _TodoStats _calculateStats(List<TodoItem> todos) {
    final total = todos.length;
    final completed = todos.where((todo) => todo.isCompleted).length;
    final pending = total - completed;
    final overdue = todos.where((todo) => todo.isOverdue).length;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayTasks = todos.where((todo) {
      if (todo.dueDate == null) return false;
      final dueDate = DateTime(
        todo.dueDate!.year,
        todo.dueDate!.month,
        todo.dueDate!.day,
      );
      return dueDate.isAtSameMomentAs(today);
    }).length;
    
    final dueSoon = todos.where((todo) {
      if (todo.dueDate == null || todo.isCompleted) return false;
      final daysDiff = todo.dueDate!.difference(now).inDays;
      return daysDiff > 0 && daysDiff <= 3;
    }).length;
    
    final completionRate = total > 0 ? (completed / total * 100) : 0.0;

    return _TodoStats(
      total: total,
      completed: completed,
      pending: pending,
      overdue: overdue,
      todayTasks: todayTasks,
      dueSoon: dueSoon,
      completionRate: completionRate,
    );
  }
}

class _TodoStats {
  final int total;
  final int completed;
  final int pending;
  final int overdue;
  final int todayTasks;
  final int dueSoon;
  final double completionRate;

  const _TodoStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.todayTasks,
    required this.dueSoon,
    required this.completionRate,
  });
}