import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../business_logic/providers/record_provider.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../../business_logic/providers/todo_provider.dart';
import '../../data/models/record.dart';
import '../../data/models/todo_item.dart';
import '../widgets/record_presentation_blocks.dart';
import '../widgets/loading_widget.dart';
import '../themes/romantic_themes.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  RecordType? _selectedType;
  RecordPresentationStyle _presentationStyle = RecordPresentationStyle.timeline;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPresentationStyle();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPresentationStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final styleIndex = prefs.getInt('presentation_style') ?? 0;
    setState(() {
      _presentationStyle =
          RecordPresentationStyle.values[styleIndex.clamp(
            0,
            RecordPresentationStyle.values.length - 1,
          )];
    });
  }

  Future<void> _savePresentationStyle(RecordPresentationStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('presentation_style', style.index);
    setState(() {
      _presentationStyle = style;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(recordsNotifierProvider);
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LoveRecord',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: RecordSearchDelegate(ref));
            },
          ),
          IconButton(
            icon: Icon(_presentationStyle.icon),
            onPressed: _showPresentationStyleDialog,
            tooltip: l10n.switchDisplayStyle,
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: _showThemeSelectionDialog,
            tooltip: l10n.selectTheme,
          ),
          IconButton(
            icon: Icon(_getBrightnessIcon()),
            onPressed: _toggleBrightness,
            tooltip: l10n.brightness,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: l10n.filterRecords,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 搜索栏和当前主题提示
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF121212)
                    : const Color(0xFFF5F5F5),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: l10n.searchRecords,
                              prefixIcon: Icon(
                                Icons.search,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFE0E0E0)
                                    : const Color(0xFF212121),
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFFE0E0E0)
                                            : const Color(0xFF212121),
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF3A3A3A)
                                      : const Color(0xFFE0E0E0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF3A3A3A)
                                      : const Color(0xFFE0E0E0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFFE0E0E0)
                                      : const Color(0xFF212121),
                                  width: 2,
                                ),
                              ),
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF2D2D2D)
                                  : const Color(0xFFF5F5F5),
                              filled: true,
                              hintStyle: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF757575)
                                    : const Color(0xFF9E9E9E),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 当前主题和样式指示器
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF424242)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF4A4A4A)
                                  : const Color(0xFFE0E0E0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                romanticTheme.icon,
                                size: 16,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFE0E0E0)
                                    : const Color(0xFF212121),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                romanticTheme.name,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFFE0E0E0)
                                      : const Color(0xFF212121),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF424242)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _presentationStyle.icon,
                                size: 16,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFE0E0E0)
                                    : const Color(0xFF212121),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _presentationStyle.getDisplayName(context),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFFE0E0E0)
                                      : const Color(0xFF212121),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (_selectedType != null)
                          Chip(
                            label: Text(
                              _getTypeDisplayName(_selectedType!),
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFE0E0E0)
                                    : const Color(0xFF212121),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onDeleted: () {
                              setState(() {
                                _selectedType = null;
                              });
                            },
                            deleteIcon: Icon(
                              Icons.close,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFFE0E0E0)
                                  : const Color(0xFF212121),
                            ),
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF424242)
                                : const Color(0xFFF5F5F5),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // 记录列表 - 使用新的展示块
            Expanded(
              child: recordsAsync.when(
                data: (records) {
                  final filteredRecords = _filterRecords(records);

                  if (filteredRecords.isEmpty) {
                    return _buildEmptyState(romanticTheme);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(recordsNotifierProvider);
                    },
                    color: romanticTheme.primary,
                    child: RecordPresentationBlock(
                      records: filteredRecords,
                      style: _presentationStyle,
                      onTap: _openRecord,
                      onDelete: _deleteRecord,
                    ),
                  );
                },
                loading: () => const LoadingWidget(),
                error: (error, stack) => _buildErrorState(error, romanticTheme),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewRecord,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 过滤记录
  List<Record> _filterRecords(List<Record> records) {
    List<Record> filtered = records;

    // 按搜索查询过滤
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((record) {
        return record.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            record.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record.tags.any(
              (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
            );
      }).toList();
    }

    // 按类型过滤
    if (_selectedType != null) {
      filtered = filtered
          .where((record) => record.type == _selectedType)
          .toList();
    }

    return filtered;
  }

  /// 显示过滤器对话框
  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context);
    final romanticTheme = ref.read(currentRomanticThemeDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D2D2D)
            : const Color(0xFFF5F5F5),
        title: Text(
          l10n.filterRecords,
          style: TextStyle(
            color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: RecordType.values.map((type) {
            return ListTile(
              title: Text(
                _getTypeDisplayName(type),
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFE0E0E0)
                      : const Color(0xFF212121),
                ),
              ),
              leading: Radio<RecordType>(
                value: type,
                groupValue: _selectedType,
                activeColor: romanticTheme.primary,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                  Navigator.of(context).pop();
                },
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
              });
              Navigator.of(context).pop();
            },
            child: Text(
              l10n.clear,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFE0E0E0)
                    : const Color(0xFF212121),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFE0E0E0)
                    : const Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取类型显示名称
  String _getTypeDisplayName(RecordType type) {
    final l10n = AppLocalizations.of(context);
    return l10n.getRecordTypeDisplayName(type.name);
  }

  /// 创建新记录
  void _createNewRecord() {
    Navigator.of(context).pushNamed('/create-record');
  }

  /// 打开记录详情
  void _openRecord(Record record) {
    Navigator.of(context).pushNamed('/record/${record.id}');
  }

  /// 删除记录
  void _deleteRecord(Record record) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(
          l10n.confirmDeleteRecord.replaceAll('{title}', record.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(recordsNotifierProvider.notifier)
                  .deleteRecord(record.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.recordDeleted)));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  /// 显示展示样式选择对话框
  void _showPresentationStyleDialog() {
    final romanticTheme = ref.read(currentRomanticThemeDataProvider);
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D2D2D)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.selectDisplayStyle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFE0E0E0)
                : const Color(0xFF212121),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: RecordPresentationStyle.values.map((style) {
            final isSelected = style == _presentationStyle;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                          ? const Color(0xFF424242)
                          : romanticTheme.primary.withOpacity(0.2))
                    : (isDark
                          ? const Color(0xFF3A3A3A)
                          : Colors.grey.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(
                        color: isDark
                            ? const Color(0xFFE0E0E0)
                            : romanticTheme.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: ListTile(
                leading: Icon(
                  style.icon,
                  color: isDark
                      ? const Color(0xFFE0E0E0)
                      : (isSelected
                            ? romanticTheme.primary
                            : const Color(0xFF212121)),
                ),
                title: Text(
                  style.getDisplayName(context),
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFE0E0E0)
                        : (isSelected
                              ? romanticTheme.primary
                              : const Color(0xFF212121)),
                  ),
                ),
                onTap: () {
                  _savePresentationStyle(style);
                  Navigator.of(context).pop();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 显示主题选择对话框
  void _showThemeSelectionDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.chooseTheme,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 400,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: RomanticTheme.values.length,
                  itemBuilder: (context, index) {
                    final theme = RomanticTheme.values[index];
                    final themeData = RomanticThemes.getLocalizedTheme(
                      theme,
                      l10n,
                    );
                    final currentTheme = ref
                        .read(themeNotifierProvider)
                        .valueOrNull
                        ?.romanticTheme;
                    final isSelected = theme == currentTheme;

                    return GestureDetector(
                      onTap: () {
                        ref
                            .read(themeNotifierProvider.notifier)
                            .changeRomanticTheme(theme);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: themeData.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary,
                                  width: 3,
                                )
                              : Border.all(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.3),
                                  width: 1,
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: themeData.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                themeData.icon,
                                size: 32,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                themeData.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                themeData.description,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(RomanticThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: theme.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_border, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noRecordsYet,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startRecordingMemories,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : theme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewRecord,
            icon: const Icon(Icons.add),
            label: Text(l10n.createFirstRecord),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(Object error, RomanticThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 64, color: Colors.red),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.loadFailed,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : theme.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(recordsNotifierProvider);
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取亮度图标
  IconData _getBrightnessIcon() {
    final themeState = ref.watch(themeNotifierProvider).valueOrNull;
    switch (themeState?.brightnessMode) {
      case ThemeBrightnessMode.dark:
        return Icons.light_mode;
      case ThemeBrightnessMode.light:
        return Icons.dark_mode;
      case ThemeBrightnessMode.system:
        return Icons.brightness_auto;
      default:
        return Icons.brightness_auto;
    }
  }

  /// 切换亮度模式
  void _toggleBrightness() {
    final themeState = ref.read(themeNotifierProvider).valueOrNull;
    if (themeState != null) {
      ThemeBrightnessMode newMode;
      switch (themeState.brightnessMode) {
        case ThemeBrightnessMode.light:
          newMode = ThemeBrightnessMode.dark;
          break;
        case ThemeBrightnessMode.dark:
          newMode = ThemeBrightnessMode.system;
          break;
        case ThemeBrightnessMode.system:
          newMode = ThemeBrightnessMode.light;
          break;
        default:
          newMode = ThemeBrightnessMode.light;
      }
      ref.read(themeNotifierProvider.notifier).setBrightnessMode(newMode);
    }
  }

  Widget _buildTodoSummarySection() {
    return Consumer(
      builder: (context, ref, child) {
        // Initialize todo service
        ref.watch(todoServiceInitProvider);

        final stats = ref.watch(todoStatisticsProvider);
        final pendingTodos = ref.watch(pendingTodosProvider);

        // Always show the todo section for easy access
        if (stats.total == 0) {
          return _buildEmptyTodoSection();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/todos');
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.checklist,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '待办清单',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${stats.pending}/${stats.total}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).primaryColor,
                        size: 16,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: stats.total > 0
                              ? stats.completed / stats.total
                              : 0,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${stats.completionRate}%',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ],
                  ),

                  if (pendingTodos.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    // Show next 2 pending todos
                    ...pendingTodos.take(2).map((todo) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                todo.title,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (todo.priority == TodoPriority.urgent ||
                                todo.priority == TodoPriority.high)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Color(
                                    int.parse(
                                      '0xFF${todo.priority.colorHex.substring(1)}',
                                    ),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),

                    if (pendingTodos.length > 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '还有 ${pendingTodos.length - 2} 个任务',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyTodoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/todos');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.checklist_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '待办清单',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理您的任务和目标，保持井然有序',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    '点击创建您的第一个任务',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 记录搜索委托
class RecordSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  RecordSearchDelegate(this.ref);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final romanticTheme = ref.read(currentRomanticThemeDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ThemeData(
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF5F5F5),
        foregroundColor: isDark
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF212121),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
        selectionColor:
            (isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121))
                .withOpacity(0.3),
        selectionHandleColor: isDark
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF212121),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
            width: 1.5,
          ),
        ),
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF757575) : const Color(0xFF9E9E9E),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: isDark ? 2 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: TextTheme(
        titleMedium: TextStyle(
          color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF424242),
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: isDark ? const Color(0xFF757575) : const Color(0xFF757575),
          fontSize: 12,
        ),
      ),
      iconTheme: IconThemeData(
        color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF424242),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return Consumer(
      builder: (context, ref, child) {
        final recordsAsync = ref.watch(recordsNotifierProvider);

        return recordsAsync.when(
          data: (records) {
            final filteredRecords = records.where((record) {
              return record.title.toLowerCase().contains(query.toLowerCase()) ||
                  record.content.toLowerCase().contains(query.toLowerCase()) ||
                  record.tags.any(
                    (tag) => tag.toLowerCase().contains(query.toLowerCase()),
                  );
            }).toList();

            if (filteredRecords.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF757575)
                          : const Color(0xFFBDBDBD),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).noMatchingRecords,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFB0B0B0)
                            : const Color(0xFF424242),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredRecords.length,
              itemBuilder: (context, index) {
                final record = filteredRecords[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      record.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          record.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (record.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            children: record.tags.take(3).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF2D2D2D)
                                      : const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFFB0B0B0)
                                        : const Color(0xFF424242),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatDate(record.createdAt, context),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          _getRecordTypeIcon(record.type),
                          size: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF757575)
                              : const Color(0xFF757575),
                        ),
                      ],
                    ),
                    onTap: () {
                      close(context, record.id);
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('${AppLocalizations.of(context).searchError}: $error'),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n.formatRelativeTime(date);
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
      default:
        return Icons.article;
    }
  }
}
