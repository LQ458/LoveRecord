import 'package:uuid/uuid.dart';
import '../../utils/date_parser.dart';

/// Todo item data model for individual tasks
class TodoItem {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final TodoPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String? assignedTo; // Partner ID for shared todos
  final String createdBy; // User who created the todo
  final List<String> tags;
  final TodoCategory category;
  final List<MultiStepDeadline> multiStepDeadlines;

  const TodoItem({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.priority,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
    this.assignedTo,
    required this.createdBy,
    required this.tags,
    required this.category,
    this.multiStepDeadlines = const [],
  });

  /// Create a new todo item
  factory TodoItem.create({
    required String title,
    String? description,
    TodoPriority priority = TodoPriority.medium,
    DateTime? dueDate,
    String? assignedTo,
    required String createdBy,
    List<String> tags = const [],
    TodoCategory category = TodoCategory.personal,
    List<MultiStepDeadline> multiStepDeadlines = const [],
  }) {
    return TodoItem(
      id: const Uuid().v4(),
      title: title,
      description: description,
      isCompleted: false,
      priority: priority,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      assignedTo: assignedTo,
      createdBy: createdBy,
      tags: tags,
      category: category,
      multiStepDeadlines: multiStepDeadlines,
    );
  }

  /// Mark todo as completed
  TodoItem markCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  /// Mark todo as incomplete
  TodoItem markIncomplete() {
    return copyWith(
      isCompleted: false,
      completedAt: null,
    );
  }

  /// Update todo item
  TodoItem copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    TodoPriority? priority,
    DateTime? dueDate,
    DateTime? completedAt,
    String? assignedTo,
    List<String>? tags,
    TodoCategory? category,
    List<MultiStepDeadline>? multiStepDeadlines,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      multiStepDeadlines: multiStepDeadlines ?? this.multiStepDeadlines,
    );
  }

  /// Check if todo is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Check if todo is due today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final due = dueDate!;
    return now.year == due.year && 
           now.month == due.month && 
           now.day == due.day;
  }

  /// Check if todo is shared with partner
  bool get isShared => assignedTo != null;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'tags': tags,
      'category': category.name,
      'multiStepDeadlines': multiStepDeadlines.map((d) => d.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      priority: TodoPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => TodoPriority.medium,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      dueDate: json['dueDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['dueDate'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'])
          : null,
      assignedTo: json['assignedTo'],
      createdBy: json['createdBy'],
      tags: List<String>.from(json['tags'] ?? []),
      category: TodoCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => TodoCategory.personal,
      ),
      multiStepDeadlines: (json['multiStepDeadlines'] as List<dynamic>?)
          ?.map((d) => MultiStepDeadline.fromJson(d as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  @override
  String toString() {
    return 'TodoItem(id: $id, title: $title, isCompleted: $isCompleted, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Todo priority levels
enum TodoPriority {
  low,
  medium,
  high,
  urgent;

  /// Get priority color
  String get colorHex {
    switch (this) {
      case TodoPriority.low:
        return '#4CAF50'; // Green
      case TodoPriority.medium:
        return '#FF9800'; // Orange
      case TodoPriority.high:
        return '#F44336'; // Red
      case TodoPriority.urgent:
        return '#9C27B0'; // Purple
    }
  }

  /// Get priority label
  String get label {
    switch (this) {
      case TodoPriority.low:
        return 'Low';
      case TodoPriority.medium:
        return 'Medium';
      case TodoPriority.high:
        return 'High';
      case TodoPriority.urgent:
        return 'Urgent';
    }
  }
}

/// Todo categories for organization
enum TodoCategory {
  personal,
  shared,
  work,
  home,
  health,
  shopping,
  travel,
  anniversary,
  dateNight;

  /// Get category label
  String get label {
    switch (this) {
      case TodoCategory.personal:
        return 'Personal';
      case TodoCategory.shared:
        return 'Shared';
      case TodoCategory.work:
        return 'Work';
      case TodoCategory.home:
        return 'Home';
      case TodoCategory.health:
        return 'Health';
      case TodoCategory.shopping:
        return 'Shopping';
      case TodoCategory.travel:
        return 'Travel';
      case TodoCategory.anniversary:
        return 'Anniversary';
      case TodoCategory.dateNight:
        return 'Date Night';
    }
  }

  /// Get category icon
  String get icon {
    switch (this) {
      case TodoCategory.personal:
        return '👤';
      case TodoCategory.shared:
        return '💕';
      case TodoCategory.work:
        return '💼';
      case TodoCategory.home:
        return '🏠';
      case TodoCategory.health:
        return '🏥';
      case TodoCategory.shopping:
        return '🛒';
      case TodoCategory.travel:
        return '✈️';
      case TodoCategory.anniversary:
        return '🎂';
      case TodoCategory.dateNight:
        return '🌹';
    }
  }
}