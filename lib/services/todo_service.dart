import '../data/local/database_service.dart';
import '../data/models/todo_item.dart';
import '../data/models/record.dart';
import 'dart:async';
import 'dart:developer' as developer;

/// Service for managing todo items with database operations
class TodoService {
  final DatabaseService _databaseService = DatabaseService();
  
  // Stream controllers for reactive updates
  final StreamController<List<TodoItem>> _todosController = 
      StreamController<List<TodoItem>>.broadcast();
  final StreamController<TodoItem> _todoUpdatesController = 
      StreamController<TodoItem>.broadcast();

  // Cache for todos
  List<TodoItem> _cachedTodos = [];
  bool _isInitialized = false;

  /// Stream of all todos
  Stream<List<TodoItem>> get todosStream => _todosController.stream;

  /// Stream of todo updates
  Stream<TodoItem> get todoUpdatesStream => _todoUpdatesController.stream;

  /// Get all cached todos
  List<TodoItem> get todos => List.unmodifiable(_cachedTodos);

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      developer.log('🔧 Initializing TodoService...', name: 'TodoService');
      await _loadTodos();
      _isInitialized = true;
      developer.log('✅ TodoService initialized with ${_cachedTodos.length} todos', name: 'TodoService');
    } catch (e) {
      developer.log('❌ Failed to initialize TodoService: $e', name: 'TodoService');
      // Still emit empty list so UI doesn't get stuck in loading state
      _cachedTodos = [];
      _todosController.add(_cachedTodos);
    }
  }

  /// Load todos from database
  Future<void> _loadTodos() async {
    try {
      // For now, we'll store todos as records with a special type
      final records = await _databaseService.getRecords();
      _cachedTodos = records
          .where((record) => record.title.startsWith('TODO:'))
          .map((record) => _recordToTodo(record))
          .toList();

      // Sort by priority and due date
      _cachedTodos.sort((a, b) {
        // Incomplete todos first
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        // Then by priority (urgent first)
        if (a.priority != b.priority) {
          return b.priority.index.compareTo(a.priority.index);
        }
        // Then by due date (earliest first)
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;
        
        // Finally by creation date (newest first)
        return b.createdAt.compareTo(a.createdAt);
      });

      _todosController.add(_cachedTodos);
      developer.log('📊 Loaded ${_cachedTodos.length} todos from database', name: 'TodoService');
    } catch (e) {
      developer.log('Error loading todos: $e', name: 'TodoService');
      // Ensure we always emit something
      _cachedTodos = [];
      _todosController.add(_cachedTodos);
    }
  }

  /// Create a new todo
  Future<TodoItem> createTodo({
    required String title,
    String? description,
    TodoPriority priority = TodoPriority.medium,
    DateTime? dueDate,
    String? assignedTo,
    required String createdBy,
    List<String> tags = const [],
    TodoCategory category = TodoCategory.personal,
  }) async {
    try {
      final todo = TodoItem.create(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        assignedTo: assignedTo,
        createdBy: createdBy,
        tags: tags,
        category: category,
      );

      // Save to database as a record
      final record = _todoToRecord(todo);
      await _databaseService.saveRecord(record);

      // Update cache
      _cachedTodos.add(todo);
      await _sortAndNotify();

      developer.log('✅ Created todo: ${todo.title}', name: 'TodoService');
      return todo;
    } catch (e) {
      developer.log('❌ Failed to create todo: $e', name: 'TodoService');
      rethrow;
    }
  }

  /// Update an existing todo
  Future<TodoItem> updateTodo(String todoId, {
    String? title,
    String? description,
    TodoPriority? priority,
    DateTime? dueDate,
    String? assignedTo,
    List<String>? tags,
    TodoCategory? category,
  }) async {
    try {
      final index = _cachedTodos.indexWhere((todo) => todo.id == todoId);
      if (index == -1) {
        throw Exception('Todo not found: $todoId');
      }

      final updatedTodo = _cachedTodos[index].copyWith(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        assignedTo: assignedTo,
        tags: tags,
        category: category,
      );

      // Update in database
      final record = _todoToRecord(updatedTodo);
      await _databaseService.updateRecord(record);

      // Update cache
      _cachedTodos[index] = updatedTodo;
      await _sortAndNotify();
      _todoUpdatesController.add(updatedTodo);

      developer.log('✅ Updated todo: ${updatedTodo.title}', name: 'TodoService');
      return updatedTodo;
    } catch (e) {
      developer.log('❌ Failed to update todo: $e', name: 'TodoService');
      rethrow;
    }
  }

  /// Toggle todo completion status
  Future<TodoItem> toggleTodoCompletion(String todoId) async {
    try {
      final index = _cachedTodos.indexWhere((todo) => todo.id == todoId);
      if (index == -1) {
        throw Exception('Todo not found: $todoId');
      }

      final todo = _cachedTodos[index];
      final updatedTodo = todo.isCompleted ? todo.markIncomplete() : todo.markCompleted();

      // Update in database
      final record = _todoToRecord(updatedTodo);
      await _databaseService.updateRecord(record);

      // Update cache
      _cachedTodos[index] = updatedTodo;
      await _sortAndNotify();
      _todoUpdatesController.add(updatedTodo);

      developer.log('✅ Toggled todo completion: ${updatedTodo.title} (${updatedTodo.isCompleted ? "completed" : "incomplete"})', name: 'TodoService');
      return updatedTodo;
    } catch (e) {
      developer.log('❌ Failed to toggle todo completion: $e', name: 'TodoService');
      rethrow;
    }
  }

  /// Delete a todo
  Future<void> deleteTodo(String todoId) async {
    try {
      final index = _cachedTodos.indexWhere((todo) => todo.id == todoId);
      if (index == -1) {
        throw Exception('Todo not found: $todoId');
      }

      final todo = _cachedTodos[index];
      
      // Delete from database
      await _databaseService.deleteRecord(todoId);

      // Remove from cache
      _cachedTodos.removeAt(index);
      _todosController.add(_cachedTodos);

      developer.log('✅ Deleted todo: ${todo.title}', name: 'TodoService');
    } catch (e) {
      developer.log('❌ Failed to delete todo: $e', name: 'TodoService');
      rethrow;
    }
  }

  /// Get todos by category
  List<TodoItem> getTodosByCategory(TodoCategory category) {
    return _cachedTodos.where((todo) => todo.category == category).toList();
  }

  /// Get shared todos
  List<TodoItem> getSharedTodos() {
    return _cachedTodos.where((todo) => todo.isShared).toList();
  }

  /// Get personal todos
  List<TodoItem> getPersonalTodos() {
    return _cachedTodos.where((todo) => !todo.isShared).toList();
  }

  /// Get todos by completion status
  List<TodoItem> getTodosByCompletion(bool isCompleted) {
    return _cachedTodos.where((todo) => todo.isCompleted == isCompleted).toList();
  }

  /// Get overdue todos
  List<TodoItem> getOverdueTodos() {
    return _cachedTodos.where((todo) => todo.isOverdue).toList();
  }

  /// Get todos due today
  List<TodoItem> getTodosDueToday() {
    return _cachedTodos.where((todo) => todo.isDueToday).toList();
  }

  /// Get todo statistics
  TodoStatistics getStatistics() {
    final total = _cachedTodos.length;
    final completed = getTodosByCompletion(true).length;
    final pending = getTodosByCompletion(false).length;
    final overdue = getOverdueTodos().length;
    final dueToday = getTodosDueToday().length;
    final shared = getSharedTodos().length;

    return TodoStatistics(
      total: total,
      completed: completed,
      pending: pending,
      overdue: overdue,
      dueToday: dueToday,
      shared: shared,
      completionRate: total > 0 ? (completed / total * 100).round() : 0,
    );
  }

  /// Sort todos and notify listeners
  Future<void> _sortAndNotify() async {
    _cachedTodos.sort((a, b) {
      // Incomplete todos first
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Then by priority (urgent first)
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }
      // Then by due date (earliest first)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;
      
      // Finally by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    _todosController.add(_cachedTodos);
  }

  /// Convert TodoItem to Record for database storage
  Record _todoToRecord(TodoItem todo) {
    return Record.create(
      title: 'TODO: ${todo.title}',
      content: todo.toJson().toString(),
      type: RecordType.work, // Using work type for todos
    ).copyWith(id: todo.id); // Preserve todo ID
  }

  /// Convert Record to TodoItem
  TodoItem _recordToTodo(Record record) {
    try {
      final content = record.content.replaceFirst('TODO: ', '');
      // This is a simplified conversion - in a real app you'd parse the JSON properly
      return TodoItem(
        id: record.id,
        title: record.title.replaceFirst('TODO: ', ''),
        description: null,
        isCompleted: false,
        priority: TodoPriority.medium,
        createdAt: record.createdAt,
        createdBy: 'current_user', // Default for now
        tags: [],
        category: TodoCategory.personal,
      );
    } catch (e) {
      // Fallback conversion
      return TodoItem(
        id: record.id,
        title: record.title.replaceFirst('TODO: ', ''),
        description: record.content,
        isCompleted: false,
        priority: TodoPriority.medium,
        createdAt: record.createdAt,
        createdBy: 'current_user',
        tags: [],
        category: TodoCategory.personal,
      );
    }
  }



  /// Dispose of resources
  void dispose() {
    _todosController.close();
    _todoUpdatesController.close();
  }
}

/// Todo statistics data class
class TodoStatistics {
  final int total;
  final int completed;
  final int pending;
  final int overdue;
  final int dueToday;
  final int shared;
  final int completionRate;

  const TodoStatistics({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.dueToday,
    required this.shared,
    required this.completionRate,
  });

  @override
  String toString() {
    return 'TodoStatistics(total: $total, completed: $completed, pending: $pending, completionRate: $completionRate%)';
  }
}