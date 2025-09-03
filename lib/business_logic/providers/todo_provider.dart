import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/todo_item.dart';
import '../../services/todo_service.dart';
import 'dart:developer' as developer;

/// Provider for TodoService instance
final todoServiceProvider = Provider<TodoService>((ref) {
  final service = TodoService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for initializing TodoService
final todoServiceInitProvider = FutureProvider<void>((ref) async {
  final todoService = ref.watch(todoServiceProvider);
  await todoService.initialize();
});

/// Provider for all todos stream
final todosStreamProvider = StreamProvider<List<TodoItem>>((ref) {
  final todoService = ref.watch(todoServiceProvider);
  return todoService.todosStream;
});

/// Provider for todo statistics
final todoStatisticsProvider = Provider<TodoStatistics>((ref) {
  final todoService = ref.watch(todoServiceProvider);
  return todoService.getStatistics();
});

/// Provider for pending todos
final pendingTodosProvider = Provider<List<TodoItem>>((ref) {
  final todoService = ref.watch(todoServiceProvider);
  return todoService.getTodosByCompletion(false);
});

/// Provider for completed todos
final completedTodosProvider = Provider<List<TodoItem>>((ref) {
  final todoService = ref.watch(todoServiceProvider);
  return todoService.getTodosByCompletion(true);
});

/// Provider for shared todos
final sharedTodosProvider = Provider<List<TodoItem>>((ref) {
  final todoService = ref.watch(todoServiceProvider);
  return todoService.getSharedTodos();
});

/// Provider for personal todos
final personalTodosProvider = Provider<List<TodoItem>>((ref) {
  final todoService = ref.watch(todoServiceProvider);
  return todoService.getPersonalTodos();
});

/// Provider for overdue todos
final overdueTodosProvider = Provider<List<TodoItem>>((ref) {
  final todoService = ref.watch(todoServiceProvider);
  return todoService.getOverdueTodos();
});

/// Provider for todos due today
final todosDueTodayProvider = Provider<List<TodoItem>>((ref) {
  final todoService = ref.watch(todoServiceProvider);
  return todoService.getTodosDueToday();
});

/// Provider for todos by category
final todosByCategoryProvider = Provider.family<List<TodoItem>, TodoCategory>((ref, category) {
  final todoService = ref.watch(todoServiceProvider);
  return todoService.getTodosByCategory(category);
});

/// Notifier for managing todo operations
class TodoNotifier extends StateNotifier<AsyncValue<List<TodoItem>>> {
  TodoNotifier(this._todoService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final TodoService _todoService;

  Future<void> _initialize() async {
    try {
      await _todoService.initialize();
      
      // Listen to todo stream
      _todoService.todosStream.listen(
        (todos) {
          if (mounted) {
            state = AsyncValue.data(todos);
          }
        },
        onError: (error) {
          if (mounted) {
            state = AsyncValue.error(error, StackTrace.current);
          }
        },
      );
    } catch (error) {
      if (mounted) {
        state = AsyncValue.error(error, StackTrace.current);
      }
    }
  }

  /// Create a new todo
  Future<void> createTodo({
    required String title,
    String? description,
    TodoPriority priority = TodoPriority.medium,
    DateTime? dueDate,
    String? assignedTo,
    List<String> tags = const [],
    TodoCategory category = TodoCategory.personal,
  }) async {
    try {
      await _todoService.createTodo(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        assignedTo: assignedTo,
        createdBy: 'current_user', // TODO: Get from auth service
        tags: tags,
        category: category,
      );
    } catch (error) {
      developer.log('Error creating todo: $error', name: 'TodoNotifier');
      rethrow;
    }
  }

  /// Update an existing todo
  Future<void> updateTodo(String todoId, {
    String? title,
    String? description,
    TodoPriority? priority,
    DateTime? dueDate,
    String? assignedTo,
    List<String>? tags,
    TodoCategory? category,
  }) async {
    try {
      await _todoService.updateTodo(
        todoId,
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        assignedTo: assignedTo,
        tags: tags,
        category: category,
      );
    } catch (error) {
      developer.log('Error updating todo: $error', name: 'TodoNotifier');
      rethrow;
    }
  }

  /// Toggle todo completion
  Future<void> toggleTodoCompletion(String todoId) async {
    try {
      await _todoService.toggleTodoCompletion(todoId);
    } catch (error) {
      developer.log('Error toggling todo completion: $error', name: 'TodoNotifier');
      rethrow;
    }
  }

  /// Delete a todo
  Future<void> deleteTodo(String todoId) async {
    try {
      await _todoService.deleteTodo(todoId);
    } catch (error) {
      developer.log('Error deleting todo: $error', name: 'TodoNotifier');
      rethrow;
    }
  }

  /// Refresh todos
  Future<void> refresh() async {
    try {
      state = const AsyncValue.loading();
      await _todoService.initialize(); // This will reload from database
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}

/// Provider for TodoNotifier
final todoNotifierProvider = StateNotifierProvider<TodoNotifier, AsyncValue<List<TodoItem>>>((ref) {
  final todoService = ref.watch(todoServiceProvider);
  return TodoNotifier(todoService);
});

/// Provider for filtered todos based on current filter
enum TodoFilter {
  all,
  pending,
  completed,
  shared,
  personal,
  overdue,
  dueToday,
}

final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

final filteredTodosProvider = Provider<List<TodoItem>>((ref) {
  final filter = ref.watch(todoFilterProvider);
  final todoService = ref.watch(todoServiceProvider);

  switch (filter) {
    case TodoFilter.all:
      return todoService.todos;
    case TodoFilter.pending:
      return todoService.getTodosByCompletion(false);
    case TodoFilter.completed:
      return todoService.getTodosByCompletion(true);
    case TodoFilter.shared:
      return todoService.getSharedTodos();
    case TodoFilter.personal:
      return todoService.getPersonalTodos();
    case TodoFilter.overdue:
      return todoService.getOverdueTodos();
    case TodoFilter.dueToday:
      return todoService.getTodosDueToday();
  }
});

/// Provider for search query
final todoSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for searched and filtered todos
final searchedTodosProvider = Provider<List<TodoItem>>((ref) {
  final filteredTodos = ref.watch(filteredTodosProvider);
  final searchQuery = ref.watch(todoSearchQueryProvider).toLowerCase();

  if (searchQuery.isEmpty) {
    return filteredTodos;
  }

  return filteredTodos.where((todo) {
    return todo.title.toLowerCase().contains(searchQuery) ||
           (todo.description?.toLowerCase().contains(searchQuery) ?? false) ||
           todo.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
  }).toList();
});