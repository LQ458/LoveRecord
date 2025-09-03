import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/todo_item.dart';
import 'package:intl/intl.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onToggleCompletion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onToggleCompletion,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onToggleCompletion,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Completion checkbox
                  GestureDetector(
                    onTap: onToggleCompletion,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: todo.isCompleted
                              ? theme.primaryColor
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                        color: todo.isCompleted
                            ? theme.primaryColor
                            : Colors.transparent,
                      ),
                      child: todo.isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                todo.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  decoration: todo.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: todo.isCompleted
                                      ? Colors.grey[600]
                                      : null,
                                ),
                              ),
                            ),
                            if (todo.isShared)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.pink.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.people,
                                      size: 12,
                                      color: Colors.pink,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Shared',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: Colors.pink,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        
                        // Category and priority
                        Row(
                          children: [
                            Text(
                              '${todo.category.icon} ${todo.category.label}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Color(int.parse(
                                  '0xFF${todo.priority.colorHex.substring(1)}',
                                )).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                todo.priority.label,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Color(int.parse(
                                    '0xFF${todo.priority.colorHex.substring(1)}',
                                  )),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Action buttons
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              
              // Description (if exists)
              if (todo.description != null && todo.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  todo.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    decoration: todo.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ],
              
              // Tags (if exists)
              if (todo.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: todo.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              
              // Footer with dates and status
              const SizedBox(height: 8),
              Row(
                children: [
                  // Due date
                  if (todo.dueDate != null) ...[
                    Icon(
                      todo.isOverdue ? Icons.warning : Icons.schedule,
                      size: 14,
                      color: todo.isOverdue 
                          ? Colors.red 
                          : todo.isDueToday 
                              ? Colors.orange 
                              : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      todo.isDueToday 
                          ? 'Due today'
                          : todo.isOverdue 
                              ? 'Overdue'
                              : 'Due ${DateFormat('MMM d').format(todo.dueDate!)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: todo.isOverdue 
                            ? Colors.red 
                            : todo.isDueToday 
                                ? Colors.orange 
                                : Colors.grey[500],
                        fontWeight: todo.isOverdue || todo.isDueToday 
                            ? FontWeight.w600 
                            : null,
                      ),
                    ),
                    const Spacer(),
                  ] else ...[
                    const Spacer(),
                  ],
                  
                  // Created date
                  Text(
                    'Created ${_formatDate(todo.createdAt)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  
                  // Completed date
                  if (todo.isCompleted && todo.completedAt != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '• Completed ${_formatDate(todo.completedAt!)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}