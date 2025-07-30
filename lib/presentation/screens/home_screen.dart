import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../business_logic/providers/record_provider.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../../data/models/record.dart';
import '../widgets/record_presentation_blocks.dart';
import '../widgets/loading_widget.dart';
import '../themes/romantic_themes.dart';

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
      _presentationStyle = RecordPresentationStyle.values[
        styleIndex.clamp(0, RecordPresentationStyle.values.length - 1)
      ];
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LoveRecord',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: RecordSearchDelegate(ref),
              );
            },
          ),
          IconButton(
            icon: Icon(_presentationStyle.icon),
            onPressed: _showPresentationStyleDialog,
            tooltip: '切换显示样式',
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: _showThemeSelectionDialog,
            tooltip: '选择主题',
          ),
          IconButton(
            icon: Icon(_getBrightnessIcon()),
            onPressed: _toggleBrightness,
            tooltip: '切换深色/浅色模式',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.of(context).pushNamed('/analytics');
            },
            tooltip: '情感分析',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
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
                              hintText: '搜索记录...',
                              prefixIcon: Icon(
                                Icons.search, 
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? const Color(0xFFE0E0E0) 
                                    : const Color(0xFF212121)
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? const Color(0xFFE0E0E0) 
                                            : const Color(0xFF212121)
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
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? const Color(0xFF3A3A3A) 
                                      : const Color(0xFFE0E0E0)
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? const Color(0xFF3A3A3A) 
                                      : const Color(0xFFE0E0E0)
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? const Color(0xFFE0E0E0) 
                                      : const Color(0xFF212121), 
                                  width: 2
                                ),
                              ),
                              fillColor: Theme.of(context).brightness == Brightness.dark 
                                  ? const Color(0xFF2D2D2D) 
                                  : const Color(0xFFF5F5F5),
                              filled: true,
                              hintStyle: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark 
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFF424242) 
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? const Color(0xFF4A4A4A) 
                                  : const Color(0xFFE0E0E0)
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                romanticTheme.icon, 
                                size: 16, 
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? const Color(0xFFE0E0E0) 
                                    : const Color(0xFF212121)
                              ),
                              const SizedBox(width: 6),
                              Text(
                                romanticTheme.name,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark 
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark 
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
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? const Color(0xFFE0E0E0) 
                                    : const Color(0xFF212121)
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _presentationStyle.displayName,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark 
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
                                color: Theme.of(context).brightness == Brightness.dark 
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
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? const Color(0xFFE0E0E0) 
                                  : const Color(0xFF212121),
                            ),
                            backgroundColor: Theme.of(context).brightness == Brightness.dark 
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
        return record.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               record.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               record.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // 按类型过滤
    if (_selectedType != null) {
      filtered = filtered.where((record) => record.type == _selectedType).toList();
    }

    return filtered;
  }

  /// 显示过滤器对话框
  void _showFilterDialog() {
    final romanticTheme = ref.read(currentRomanticThemeDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5),
        title: Text(
          '过滤记录',
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
                  color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
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
              '清除',
              style: TextStyle(
                color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '取消',
              style: TextStyle(
                color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取类型显示名称
  String _getTypeDisplayName(RecordType type) {
    switch (type) {
      case RecordType.diary:
        return '日记';
      case RecordType.work:
        return '工作';
      case RecordType.study:
        return '学习';
      case RecordType.travel:
        return '旅行';
      case RecordType.health:
        return '健康';
      case RecordType.finance:
        return '财务';
      case RecordType.creative:
        return '创意';
    }
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除记录"${record.title}"吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(recordsNotifierProvider.notifier).deleteRecord(record.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('记录已删除')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示展示样式选择对话框
  void _showPresentationStyleDialog() {
    final romanticTheme = ref.read(currentRomanticThemeDataProvider);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: romanticTheme.createGradientDecoration(borderRadius: 20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '选择显示样式',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ...RecordPresentationStyle.values.map((style) {
                  final isSelected = style == _presentationStyle;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected 
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: ListTile(
                      leading: Icon(style.icon, color: Colors.white),
                      title: Text(
                        style.displayName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        _savePresentationStyle(style);
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 显示主题选择对话框
  void _showThemeSelectionDialog() {
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
                '选择浪漫主题',
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
                    final themeData = RomanticThemes.getTheme(theme);
                    final currentTheme = ref.read(themeNotifierProvider).valueOrNull?.romanticTheme;
                    final isSelected = theme == currentTheme;
                    
                    return GestureDetector(
                      onTap: () {
                        ref.read(themeNotifierProvider.notifier).changeRomanticTheme(theme);
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
                              ? Border.all(color: Colors.black54, width: 3)
                              : null,
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
            child: Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '还没有爱的记录',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始记录你们的美好时光吧',
            style: TextStyle(
              fontSize: 16,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewRecord,
            icon: const Icon(Icons.add),
            label: const Text('创建第一条记录'),
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
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
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
            label: const Text('重试'),
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
    if (themeState?.brightness == Brightness.dark) {
      return Icons.light_mode;
    }
    return Icons.dark_mode;
  }

  /// 切换深色/浅色模式
  void _toggleBrightness() {
    ref.read(themeNotifierProvider.notifier).toggleBrightness();
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
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
        foregroundColor: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
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
        selectionColor: (isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121)).withOpacity(0.3),
        selectionHandleColor: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121), 
            width: 1.5
          ),
        ),
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF757575) : const Color(0xFF9E9E9E),
        ),
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
                     record.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
            }).toList();

            if (filteredRecords.isEmpty) {
              return const Center(
                child: Text('没有找到匹配的记录'),
              );
            }

            return ListView.builder(
              itemCount: filteredRecords.length,
              itemBuilder: (context, index) {
                final record = filteredRecords[index];
                return ListTile(
                  title: Text(record.title),
                  subtitle: Text(
                    record.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatDate(record.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    close(context, record.id);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('搜索出错: $error'),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${date.month}/${date.day}';
    }
  }
} 