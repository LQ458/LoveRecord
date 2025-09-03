import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business_logic/providers/todo_provider.dart';
import '../../data/models/todo_item.dart';
import '../widgets/todo_item_widget.dart';
import '../widgets/todo_stats_widget.dart';
import '../themes/romantic_themes.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/date_parser.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  TodoCategory? _selectedCategory;
  TodoPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize todo service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todoServiceInitProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Initialize todo service
    ref.watch(todoServiceInitProvider);
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Modern App Bar with search
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            foregroundColor: _isSearching 
                ? (isDark ? Colors.white : Colors.black87)
                : Colors.white, // White on gradient, adaptive when searching
            elevation: 0,
            systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            flexibleSpace: FlexibleSpaceBar(
              title: _isSearching ? null : Text(
                'Todo Lists',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Always white on gradient background
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: _isSearching ? null : LinearGradient(
                    colors: romanticTheme.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: _isSearching ? _buildSearchBar(isDark) : null,
              ),
            ),
            actions: [
              if (!_isSearching) ...[
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                ),
              ] else ...[
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: romanticTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          // Statistics Section
          SliverToBoxAdapter(
            child: TodoStatsWidget(),
          ),
          
          // Filter Chips
          if (_selectedCategory != null || _selectedPriority != null)
            SliverToBoxAdapter(
              child: _buildFilterChips(romanticTheme, isDark),
            ),
          
          // Tab Section
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabBar: TabBar(
                controller: _tabController,
                indicatorColor: romanticTheme.primary,
                labelColor: romanticTheme.primary,
                unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Overdue'),
                ],
              ),
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            ),
          ),
          
          // Todo Lists
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildModernTodoList(_getAllTodos()),
                _buildModernTodoList(_getPendingTodos()),
                _buildModernTodoList(_getCompletedTodos()),
                _buildModernTodoList(_getOverdueTodos()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildModernFAB(romanticTheme),
    );
  }




  void _showAddTaskDialog(RomanticThemeData romanticTheme, bool isDark) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          _AddTaskScreen(romanticTheme: romanticTheme, isDark: isDark),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
            ),
            child: child,
          );
        },
      ),
    );
  }
  
  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }
  
  Widget _buildFilterChips(RomanticThemeData romanticTheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      child: Row(
        children: [
          if (_selectedCategory != null) ...[
            Chip(
              label: Text(_selectedCategory!.label),
              avatar: Text(_selectedCategory!.icon),
              onDeleted: () {
                setState(() {
                  _selectedCategory = null;
                });
              },
              backgroundColor: romanticTheme.primary.withOpacity(0.1),
              deleteIconColor: romanticTheme.primary,
            ),
            const SizedBox(width: 8),
          ],
          if (_selectedPriority != null) ...[
            Chip(
              label: Text(_selectedPriority!.label),
              avatar: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(int.parse('0xFF${_selectedPriority!.colorHex.substring(1)}')),
                  shape: BoxShape.circle,
                ),
              ),
              onDeleted: () {
                setState(() {
                  _selectedPriority = null;
                });
              },
              backgroundColor: Color(int.parse('0xFF${_selectedPriority!.colorHex.substring(1)}')).withOpacity(0.1),
              deleteIconColor: Color(int.parse('0xFF${_selectedPriority!.colorHex.substring(1)}')),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildModernFAB(RomanticThemeData romanticTheme) {
    return FloatingActionButton.extended(
      onPressed: () {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        _showAddTaskDialog(romanticTheme, isDark);
      },
      backgroundColor: romanticTheme.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text(
        'New Task',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildModernTodoList(AsyncValue<List<TodoItem>> todosAsync) {
    return todosAsync.when(
      data: (todos) {
        final filteredTodos = _applyFilters(todos);
        
        if (filteredTodos.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredTodos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final todo = filteredTodos[index];
            return TodoItemWidget(
              todo: todo,
              onToggleCompletion: () => _toggleTodo(todo),
              onEdit: () => _editTodo(todo),
              onDelete: () => _deleteTodo(todo),
            );
          },
        );
      },
      loading: () => _buildLoadingStateWithFallback(),
      error: (error, stack) => _buildErrorState(error),
    );
  }
  
  Widget _buildLoadingStateWithFallback() {
    // Show empty state after a brief loading period
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 1500)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If still loading after 1.5 seconds, show empty state
          return _buildEmptyState();
        }
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading your tasks...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt,
              size: 40,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the "+" button to add your first task',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load tasks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(todoNotifierProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }



  void _editTodo(TodoItem todo) {
    showDialog(
      context: context,
      builder: (context) => AddEditTodoDialog(
        todo: todo,
        onSave: (updatedTodo) {
          ref.read(todoNotifierProvider.notifier).updateTodo(
            todo.id,
            title: updatedTodo.title,
            description: updatedTodo.description,
            priority: updatedTodo.priority,
            dueDate: updatedTodo.dueDate,
            tags: updatedTodo.tags,
          );
        },
      ),
    );
  }

  void _toggleTodo(TodoItem todo) {
    ref.read(todoNotifierProvider.notifier).toggleTodoCompletion(todo.id);
  }

  void _deleteTodo(TodoItem todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除待办事项'),
        content: Text('确定要删除"${todo.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(todoNotifierProvider.notifier).deleteTodo(todo.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
  
  // Filter and data methods
  List<TodoItem> _applyFilters(List<TodoItem> todos) {
    List<TodoItem> filtered = todos;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((todo) {
        return todo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (todo.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               todo.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }
    
    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((todo) => todo.category == _selectedCategory).toList();
    }
    
    // Apply priority filter
    if (_selectedPriority != null) {
      filtered = filtered.where((todo) => todo.priority == _selectedPriority).toList();
    }
    
    return filtered;
  }
  
  AsyncValue<List<TodoItem>> _getAllTodos() {
    return ref.watch(todoNotifierProvider);
  }
  
  AsyncValue<List<TodoItem>> _getPendingTodos() {
    return ref.watch(todoNotifierProvider).whenData(
      (todos) => todos.where((todo) => !todo.isCompleted).toList(),
    );
  }
  
  AsyncValue<List<TodoItem>> _getCompletedTodos() {
    return ref.watch(todoNotifierProvider).whenData(
      (todos) => todos.where((todo) => todo.isCompleted).toList(),
    );
  }
  
  AsyncValue<List<TodoItem>> _getOverdueTodos() {
    return ref.watch(todoNotifierProvider).whenData(
      (todos) => todos.where((todo) => todo.isOverdue).toList(),
    );
  }
  
  void _showFilterDialog() {
    final romanticTheme = ref.read(currentRomanticThemeDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            
            // Category filter
            Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TodoCategory.values.map((category) {
                final isSelected = category == _selectedCategory;
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.icon),
                      const SizedBox(width: 4),
                      Text(category.label),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                    Navigator.pop(context);
                  },
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  selectedColor: romanticTheme.primary.withOpacity(0.2),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Priority filter
            Text(
              'Priority',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TodoPriority.values.map((priority) {
                final isSelected = priority == _selectedPriority;
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(int.parse('0xFF${priority.colorHex.substring(1)}')),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(priority.label),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = selected ? priority : null;
                    });
                    Navigator.pop(context);
                  },
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  selectedColor: Color(int.parse('0xFF${priority.colorHex.substring(1)}')).withOpacity(0.2),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Custom TabBar Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;

  _TabBarDelegate({required this.tabBar, required this.color});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

/// 添加/编辑Todo对话框
class AddEditTodoDialog extends StatefulWidget {
  final TodoItem? todo;
  final Function(TodoItem) onSave;

  const AddEditTodoDialog({
    super.key,
    this.todo,
    required this.onSave,
  });

  @override
  State<AddEditTodoDialog> createState() => _AddEditTodoDialogState();
}

class _AddEditTodoDialogState extends State<AddEditTodoDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TodoPriority _selectedPriority;
  DateTime? _selectedDueDate;
  List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');
    _selectedPriority = widget.todo?.priority ?? TodoPriority.medium;
    _selectedDueDate = widget.todo?.dueDate;
    _tags = List.from(widget.todo?.tags ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                widget.todo == null ? '添加待办事项' : '编辑待办事项',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // 标题输入
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '标题 *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              
              // 描述输入
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // 优先级选择
              const Text('优先级'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TodoPriority.values.map((priority) {
                  final isSelected = priority == _selectedPriority;
                  return FilterChip(
                    label: Text(priority.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPriority = priority;
                      });
                    },
                    backgroundColor: Color(int.parse('0xFF${priority.colorHex.substring(1)}')).withValues(alpha: 0.1),
                    selectedColor: Color(int.parse('0xFF${priority.colorHex.substring(1)}')).withValues(alpha: 0.3),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              // 截止日期
              Row(
                children: [
                  const Text('截止日期'),
                  const Spacer(),
                  TextButton(
                    onPressed: _selectDueDate,
                    child: Text(
                      _selectedDueDate == null
                          ? '选择日期'
                          : '${_selectedDueDate!.year}-${_selectedDueDate!.month.toString().padLeft(2, '0')}-${_selectedDueDate!.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                  if (_selectedDueDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _selectedDueDate = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 标签
              const Text('标签'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ..._tags.map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                  )),
                  ActionChip(
                    label: const Text('+ 添加标签'),
                    onPressed: _addTag,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveTodo,
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加标签'),
        content: TextField(
          controller: _tagController,
          decoration: const InputDecoration(
            hintText: '输入标签名称',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final tag = _tagController.text.trim();
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() {
                  _tags.add(tag);
                });
                _tagController.clear();
              }
              Navigator.of(context).pop();
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _saveTodo() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入标题')),
      );
      return;
    }

    final todo = TodoItem(
      id: widget.todo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: _descriptionController.text.trim(),
      isCompleted: widget.todo?.isCompleted ?? false,
      priority: _selectedPriority,
      dueDate: _selectedDueDate,
      tags: _tags,
      createdAt: widget.todo?.createdAt ?? DateTime.now(),
      category: TodoCategory.personal,
      assignedTo: null,
      createdBy: 'current_user',
    );

    widget.onSave(todo);
    Navigator.of(context).pop();
  }
}

// Comprehensive Add Task Screen (Todoist-style)
class _AddTaskScreen extends ConsumerStatefulWidget {
  final RomanticThemeData romanticTheme;
  final bool isDark;
  
  const _AddTaskScreen({required this.romanticTheme, required this.isDark});
  
  @override
  ConsumerState<_AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<_AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TodoPriority _selectedPriority = TodoPriority.medium;
  DateTime? _selectedDueDate;
  DateTime? _selectedReminderDate;
  TodoCategory _selectedCategory = TodoCategory.personal;
  DateParseResult? _currentParseResult;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _onTextChanged(String text) {
    if (text.isNotEmpty) {
      final parseResult = SmartDateParser.parseText(text);
      setState(() {
        _currentParseResult = parseResult;
        if (parseResult.dueDate != null) {
          _selectedDueDate = parseResult.dueDate;
        }
      });
    } else {
      setState(() {
        _currentParseResult = null;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: widget.isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '添加任务',
          style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: Text(
              '添加任务',
              style: TextStyle(
                color: widget.romanticTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title Input with Smart Parsing
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.isDark ? Colors.grey[600]! : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _titleController,
                onChanged: _onTextChanged,
                autofocus: true,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: '任务名称',
                  hintStyle: TextStyle(
                    color: widget.isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
            
            // Show detected dates with highlight
            if (_currentParseResult?.hasDateInfo == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.romanticTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.romanticTheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: widget.romanticTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '检测到日期: ${_formatDate(_currentParseResult!.dueDate!)}',
                        style: TextStyle(
                          color: widget.romanticTheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentParseResult = null;
                          _selectedDueDate = null;
                          _titleController.text = _currentParseResult?.cleanedText ?? _titleController.text;
                        });
                      },
                      child: Text(
                        '忽略',
                        style: TextStyle(
                          color: widget.romanticTheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '描述',
                hintStyle: TextStyle(
                  color: widget.isDark ? Colors.grey[400] : Colors.grey[500],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Options Row
            _buildOptionButton(
              icon: Icons.calendar_today,
              label: _selectedDueDate != null ? _formatDate(_selectedDueDate!) : '今天',
              color: Colors.green,
              onTap: () => _showDatePicker(),
            ),
            
            const SizedBox(height: 12),
            
            _buildOptionButton(
              icon: Icons.flag,
              label: _getPriorityLabel(_selectedPriority),
              color: _getPriorityColor(_selectedPriority),
              onTap: () => _showPriorityPicker(),
            ),
            
            const SizedBox(height: 12),
            
            _buildOptionButton(
              icon: Icons.notifications,
              label: _selectedReminderDate != null ? '提醒: ${_formatDate(_selectedReminderDate!)}' : '提醒',
              color: Colors.orange,
              onTap: () => _showReminderPicker(),
            ),
            
            const SizedBox(height: 12),
            
            _buildOptionButton(
              icon: Icons.folder,
              label: '收件箱',
              color: Colors.blue,
              onTap: () => _showCategoryPicker(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.isDark ? Colors.grey[600]! : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
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
                color: widget.isDark ? Colors.white70 : Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '今天';
    } else if (date.difference(now).inDays == 1) {
      return '明天';
    } else {
      return '${date.month}月${date.day}日';
    }
  }
  
  String _getPriorityLabel(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low: return '优先级 1';
      case TodoPriority.medium: return '优先级 2';
      case TodoPriority.high: return '优先级 3';
      case TodoPriority.urgent: return '优先级 4';
    }
  }
  
  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low: return Colors.grey;
      case TodoPriority.medium: return Colors.blue;
      case TodoPriority.high: return Colors.orange;
      case TodoPriority.urgent: return Colors.red;
    }
  }
  
  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        setState(() {
          _selectedDueDate = date;
        });
      }
    });
  }
  
  void _showPriorityPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: TodoPriority.values.map((priority) {
              return ListTile(
                leading: Icon(
                  Icons.flag,
                  color: _getPriorityColor(priority),
                ),
                title: Text(_getPriorityLabel(priority)),
                onTap: () {
                  setState(() {
                    _selectedPriority = priority;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
  
  void _showReminderPicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedReminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        setState(() {
          _selectedReminderDate = date;
        });
      }
    });
  }
  
  void _showCategoryPicker() {
    // Category picker implementation
  }
  
  void _saveTask() {
    final title = _currentParseResult?.cleanedText.isNotEmpty == true 
        ? _currentParseResult!.cleanedText 
        : _titleController.text.trim();
    
    if (title.isEmpty) return;
    
    ref.read(todoNotifierProvider.notifier).createTodo(
      title: title,
      description: _descriptionController.text.trim(),
      priority: _selectedPriority,
      dueDate: _selectedDueDate,
      category: _selectedCategory,
    );
    
    Navigator.of(context).pop();
  }
}