/// 存储服务接口
/// 定义所有平台通用的存储操作
abstract class StorageServiceInterface {
  /// 初始化存储服务
  Future<void> initialize();

  /// 保存键值对数据
  Future<void> setString(String key, String value);
  Future<void> setInt(String key, int value);
  Future<void> setBool(String key, bool value);
  Future<void> setDouble(String key, double value);
  Future<void> setStringList(String key, List<String> value);

  /// 获取键值对数据
  Future<String?> getString(String key);
  Future<int?> getInt(String key);
  Future<bool?> getBool(String key);
  Future<double?> getDouble(String key);
  Future<List<String>?> getStringList(String key);

  /// 删除数据
  Future<void> remove(String key);
  Future<void> clear();

  /// 检查键是否存在
  Future<bool> containsKey(String key);

  /// 获取所有键
  Future<Set<String>> getKeys();

  /// 数据库相关操作（如果支持）
  Future<bool> get supportsDatabase;
  Future<void> executeSql(String sql, [List<Object?>? arguments]);
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
  });
  Future<int> insert(String table, Map<String, Object?> values);
  Future<int> update(String table, Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  });
  Future<int> delete(String table, {
    String? where,
    List<Object?>? whereArgs,
  });

  /// 文件存储相关操作
  Future<bool> get supportsFileStorage;
  Future<String> saveFile(String fileName, List<int> bytes);
  Future<List<int>?> readFile(String filePath);
  Future<void> deleteFile(String filePath);
  Future<List<String>> listFiles();

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageInfo();
}