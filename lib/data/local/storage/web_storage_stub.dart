/// Web平台存储服务的桩实现
/// 当在非Web平台编译时使用
import 'storage_service_interface.dart';

class WebStorageService implements StorageServiceInterface {
  @override
  Future<void> initialize() async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<void> setString(String key, String value) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<void> setInt(String key, int value) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<void> setBool(String key, bool value) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<void> setDouble(String key, double value) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<String?> getString(String key) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<int?> getInt(String key) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<bool?> getBool(String key) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<double?> getDouble(String key) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<void> remove(String key) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<void> clear() async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<bool> containsKey(String key) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<Set<String>> getKeys() async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<bool> get supportsDatabase async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<void> executeSql(String sql, [List<Object?>? arguments]) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<List<Map<String, Object?>>> query(String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<int> insert(String table, Map<String, Object?> values) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<int> update(String table, Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<int> delete(String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<bool> get supportsFileStorage async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<String> saveFile(String fileName, List<int> bytes) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<List<int>?> readFile(String filePath) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<void> deleteFile(String filePath) async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<List<String>> listFiles() async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }

  @override
  Future<Map<String, dynamic>> getStorageInfo() async {
    throw UnsupportedError('WebStorageService只能在Web平台使用');
  }
}