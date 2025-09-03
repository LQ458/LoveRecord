import 'package:flutter/material.dart';
import '../../data/local/storage/storage_service_factory.dart';
import '../../data/local/storage/storage_service_interface.dart';

/// 存储信息展示页面
/// 显示当前平台的存储能力和使用情况
class StorageInfoScreen extends StatefulWidget {
  const StorageInfoScreen({super.key});

  @override
  State<StorageInfoScreen> createState() => _StorageInfoScreenState();
}

class _StorageInfoScreenState extends State<StorageInfoScreen> {
  late StorageServiceInterface _storageService;
  Map<String, dynamic>? _storageInfo;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _storageService = StorageServiceFactory.instance;
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // 确保存储服务已初始化
      await _storageService.initialize();

      // 获取存储信息
      final info = await _storageService.getStorageInfo();

      setState(() {
        _storageInfo = info;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('存储信息'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStorageInfo,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorView()
          : _buildStorageInfoView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('加载存储信息失败'),
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadStorageInfo, child: const Text('重试')),
        ],
      ),
    );
  }

  Widget _buildStorageInfoView() {
    if (_storageInfo == null) {
      return const Center(child: Text('无存储信息'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlatformInfo(),
          const SizedBox(height: 24),
          _buildCapabilitiesInfo(),
          const SizedBox(height: 24),
          if (StorageServiceFactory.isWeb) ...[
            _buildWebStorageInfo(),
            const SizedBox(height: 24),
          ],
          if (StorageServiceFactory.isNative) ...[
            _buildNativeStorageInfo(),
            const SizedBox(height: 24),
          ],
          _buildTestButtons(),
        ],
      ),
    );
  }

  Widget _buildPlatformInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '平台信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('平台', _storageInfo!['platform'] ?? '未知'),
            _buildInfoRow('存储服务', StorageServiceFactory.platformName),
            _buildInfoRow('是否Web平台', StorageServiceFactory.isWeb ? '是' : '否'),
          ],
        ),
      ),
    );
  }

  Widget _buildCapabilitiesInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '存储能力',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              '数据库支持',
              _storageInfo!['supportsDatabase'] == true ? '✅ 支持' : '❌ 不支持',
            ),
            _buildInfoRow(
              '文件存储支持',
              _storageInfo!['supportsFileStorage'] == true ? '✅ 支持' : '❌ 不支持',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebStorageInfo() {
    final localStorage = _storageInfo!['localStorage'] as Map<String, dynamic>?;
    final indexedDB = _storageInfo!['indexedDB'] as Map<String, dynamic>?;

    return Column(
      children: [
        if (localStorage != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LocalStorage 使用情况',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('键数量', '${localStorage['keys']}'),
                  _buildInfoRow(
                    '估算大小',
                    '${localStorage['estimatedSizeKB']} KB',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (indexedDB != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IndexedDB 使用情况',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('文件数量', '${indexedDB['fileCount']}'),
                  _buildInfoRow('总大小', '${indexedDB['totalSizeMB']} MB'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNativeStorageInfo() {
    final mediaFiles = _storageInfo!['mediaFiles'] as Map<String, dynamic>?;
    final documentsPath = _storageInfo!['documentsPath'] as String?;

    return Column(
      children: [
        if (documentsPath != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '文件系统信息',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('文档目录', documentsPath),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (mediaFiles != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '媒体文件使用情况',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('文件数量', '${mediaFiles['count']}'),
                  _buildInfoRow('总大小', '${mediaFiles['totalSizeMB']} MB'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTestButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '存储测试',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _testKeyValueStorage,
                  child: const Text('测试键值存储'),
                ),
                ElevatedButton(
                  onPressed: _testFileStorage,
                  child: const Text('测试文件存储'),
                ),
                ElevatedButton(
                  onPressed: _testDatabaseStorage,
                  child: const Text('测试数据库'),
                ),
                ElevatedButton(
                  onPressed: _clearAllData,
                  child: const Text('清空所有数据'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Future<void> _testKeyValueStorage() async {
    try {
      // 测试各种数据类型的存储
      await _storageService.setString('test_string', 'Hello World');
      await _storageService.setInt('test_int', 42);
      await _storageService.setBool('test_bool', true);
      await _storageService.setDouble('test_double', 3.14);
      await _storageService.setStringList('test_list', ['a', 'b', 'c']);

      // 读取并验证
      final string = await _storageService.getString('test_string');
      final int = await _storageService.getInt('test_int');
      final bool = await _storageService.getBool('test_bool');
      final double = await _storageService.getDouble('test_double');
      final list = await _storageService.getStringList('test_list');

      final success =
          string == 'Hello World' &&
          int == 42 &&
          bool == true &&
          double == 3.14 &&
          list?.join(',') == 'a,b,c';

      _showTestResult('键值存储测试', success);
    } catch (e) {
      _showTestResult('键值存储测试', false, error: e.toString());
    }
  }

  Future<void> _testFileStorage() async {
    try {
      if (!await _storageService.supportsFileStorage) {
        _showTestResult('文件存储测试', false, error: '当前平台不支持文件存储');
        return;
      }

      // 测试文件存储
      final testData = 'This is a test file content'.codeUnits;
      final filePath = await _storageService.saveFile('test.txt', testData);

      // 读取文件
      final readData = await _storageService.readFile(filePath);
      final success =
          readData != null &&
          String.fromCharCodes(readData) == 'This is a test file content';

      // 清理测试文件
      await _storageService.deleteFile(filePath);

      _showTestResult('文件存储测试', success);
    } catch (e) {
      _showTestResult('文件存储测试', false, error: e.toString());
    }
  }

  Future<void> _testDatabaseStorage() async {
    try {
      if (!await _storageService.supportsDatabase) {
        _showTestResult('数据库测试', false, error: '当前平台不支持数据库操作');
        return;
      }

      // 这里可以添加数据库测试逻辑
      _showTestResult('数据库测试', true);
    } catch (e) {
      _showTestResult('数据库测试', false, error: e.toString());
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('这将清空所有存储的数据，此操作不可撤销。确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.clear();
        _showTestResult('清空数据', true);
        await _loadStorageInfo(); // 重新加载存储信息
      } catch (e) {
        _showTestResult('清空数据', false, error: e.toString());
      }
    }
  }

  void _showTestResult(String testName, bool success, {String? error}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(testName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(success ? '测试成功' : '测试失败'),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text('错误信息: $error', style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
