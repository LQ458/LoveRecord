import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/todo_item.dart';
import '../../business_logic/providers/todo_provider.dart';
import 'package:intl/intl.dart';

class CreateTodoScreen extends ConsumerStatefulWidget {
  final TodoItem? todo; // For editing existing todos

  const CreateTodoScreen({super.key, this.todo});

  @override
  ConsumerState<CreateTodoScreen> createState() => _CreateTodoScreenState();
}

class _CreateTodoScreenState extends ConsumerState<CreateTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  
  TodoPriority _selectedPriority = TodoPriority.medium;
  TodoCategory _selectedCategory = TodoCategory.personal;
  DateTime? _selectedDueDate;
  bool _isSharedTodo = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // If editing, populate fields
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description ?? '';
      _tagsController.text = widget.todo!.tags.join(', ');
      _selectedPriority = widget.todo!.priority;
      _selectedCategory = widget.todo!.category;
      _selectedDueDate = widget.todo!.dueDate;
      _isSharedTodo = widget.todo!.isShared;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.todo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Todo' : 'Create Todo'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveTodo,
              child: Text(
                isEditing ? 'Update' : 'Save',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title field
            _buildSectionCard(
              'Basic Information',
              Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      hintText: 'What needs to be done?',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Add more details (optional)',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Priority and Category
            _buildSectionCard(
              'Organization',
              Column(
                children: [
                  // Priority selection
                  DropdownButtonFormField<TodoPriority>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      prefixIcon: Icon(Icons.flag),
                    ),
                    items: TodoPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Color(int.parse('0xFF${priority.colorHex.substring(1)}')),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(priority.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPriority = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category selection
                  DropdownButtonFormField<TodoCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: TodoCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Text(category.icon),
                            const SizedBox(width: 8),
                            Text(category.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Due date and sharing
            _buildSectionCard(
              'Scheduling & Sharing',
              Column(
                children: [
                  // Due date picker
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Due Date'),
                    subtitle: _selectedDueDate != null
                        ? Text(DateFormat('EEEE, MMMM d, y').format(_selectedDueDate!))
                        : const Text('No due date set'),
                    trailing: _selectedDueDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedDueDate = null;
                              });
                            },
                          )
                        : const Icon(Icons.arrow_forward_ios),
                    onTap: _selectDueDate,
                    contentPadding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 8),

                  // Shared todo toggle
                  SwitchListTile(
                    secondary: const Icon(Icons.people),
                    title: const Text('Share with Partner'),
                    subtitle: const Text('Make this todo visible to your partner'),
                    value: _isSharedTodo,
                    onChanged: (value) {
                      setState(() {
                        _isSharedTodo = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tags
            _buildSectionCard(
              'Tags',
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'work, personal, urgent (separate with commas)',
                  prefixIcon: Icon(Icons.tag),
                  helperText: 'Add tags to organize your todos better',
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget child) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDueDate != null
            ? TimeOfDay.fromDateTime(_selectedDueDate!)
            : const TimeOfDay(hour: 9, minute: 0),
      );

      if (selectedTime != null) {
        setState(() {
          _selectedDueDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final isEditing = widget.todo != null;

      if (isEditing) {
        // Update existing todo
        await ref.read(todoNotifierProvider.notifier).updateTodo(
          widget.todo!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          priority: _selectedPriority,
          category: _selectedCategory,
          dueDate: _selectedDueDate,
          assignedTo: _isSharedTodo ? 'partner_id' : null, // TODO: Get actual partner ID
          tags: tags,
        );
      } else {
        // Create new todo
        await ref.read(todoNotifierProvider.notifier).createTodo(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          priority: _selectedPriority,
          category: _selectedCategory,
          dueDate: _selectedDueDate,
          assignedTo: _isSharedTodo ? 'partner_id' : null, // TODO: Get actual partner ID
          tags: tags,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Todo updated successfully!' : 'Todo created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}