import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'storage_service_interface.dart';

/// Web平台存储服务实现（简化版）
/// 使用 localStorage 作为主要存储方案
class WebStorageService implements StorageServiceInterface {
  static const String _prefix = 'loverecord_';
  static const String _filesPrefix = 'loverecord_files_';
  static const String _dbPrefix = 'loverecord_db_';
  
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  String _getKey(String key) => '$_prefix$key';

  // localStorage 操作
  @override
  Future<void> setString(String key, String value) async {
    html.window.localStorage[_getKey(key)] = value;
  }

  @override
  Future<void> setInt(String key, int value) async {
    html.window.localStorage[_getKey(key)] = value.toString();
  }

  @override
  Future<void> setBool(String key, bool value) async {
    html.window.localStorage[_getKey(key)] = value.toString();
  }

  @override
  Future<void> setDouble(String key, double value) async {
    html.window.localStorage[_getKey(key)] = value.toString();
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    html.window.localStorage[_getKey(key)] = jsonEncode(value);
  }

  @override
  Future<String?> getString(String key) async {
    return html.window.localStorage[_getKey(key)];
  }

  @override
  Future<int?> getInt(String key) async {
    final value = html.window.localStorage[_getKey(key)];
    return value != null ? int.tryParse(value) : null;
  }

  @override
  Future<bool?> getBool(String key) async {
    final value = html.window.localStorage[_getKey(key)];
    return value != null ? value.toLowerCase() == 'true' : null;
  }

  @override
  Future<double?> getDouble(String key) async {
    final value = html.window.localStorage[_getKey(key)];
    return value != null ? double.tryParse(value) : null;
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    final value = html.window.localStorage[_getKey(key)];
    if (value != null) {
      try {
        final List<dynamic> decoded = jsonDecode(value);
        return decoded.cast<String>();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> remove(String key) async {
    html.window.localStorage.remove(_getKey(key));
  }

  @override
  Future<void> clear() async {
    // 只清理我们的键
    final keysToRemove = <String>[];
    for (final key in html.window.localStorage.keys) {
      if (key.startsWith(_prefix) || 
          key.startsWith(_filesPrefix) || 
          key.startsWith(_dbPrefix)) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      html.window.localStorage.remove(key);
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    return html.window.localStorage.containsKey(_getKey(key));
  }

  @override
  Future<Set<String>> getKeys() async {
    final keys = <String>{};
    for (final key in html.window.localStorage.keys) {
      if (key.startsWith(_prefix)) {
        keys.add(key.substring(_prefix.length));
      }
    }
    return keys;
  }

  // 数据库操作（简化实现，使用localStorage模拟）
  @override
  Future<bool> get supportsDatabase async => true;

  @override
  Future<void> executeSql(String sql, [List<Object?>? arguments]) async {
    // Web平台不支持SQL，抛出异常
    throw UnsupportedError('Web平台不支持直接SQL操作');
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
    final tableKey = '$_dbPrefix$table';
    final dataJson = html.window.localStorage[tableKey];
    
    if (dataJson == null) return [];
    
    try {
      final List<dynamic> data = jsonDecode(dataJson);
      List<Map<String, Object?>> results = data.cast<Map<String, Object?>>();
      
      // 简单的where条件过滤
      if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
        results = results.where((row) {
          // 简单实现：只支持 "column = ?" 格式
          if (where.contains('=') && where.contains('?')) {
            final parts = where.split('=');
            if (parts.length == 2) {
              final column = parts[0].trim();
              final expectedValue = whereArgs[0];
              return row[column] == expectedValue;
            }
          }
          return true;
        }).toList();
      }
      
      // 排序
      if (orderBy != null) {
        results.sort((a, b) {
          final aValue = a[orderBy];
          final bValue = b[orderBy];
          if (aValue == null && bValue == null) return 0;
          if (aValue == null) return -1;
          if (bValue == null) return 1;
          return Comparable.compare(aValue as Comparable, bValue as Comparable);
        });
      }
      
      // 限制和偏移
      int start = offset ?? 0;
      int end = limit != null ? start + limit : results.length;
      
      return results.sublist(start, end.clamp(0, results.length));
      
    } catch (e) {
      return [];
    }
  }

  @override
  Future<int> insert(String table, Map<String, Object?> values) async {
    final tableKey = '$_dbPrefix$table';
    final dataJson = html.window.localStorage[tableKey];
    
    List<Map<String, Object?>> data = [];
    if (dataJson != null) {
      try {
        final List<dynamic> existing = jsonDecode(dataJson);
        data = existing.cast<Map<String, Object?>>();
      } catch (e) {
        // 忽略解析错误，使用空列表
      }
    }
    
    data.add(values);
    html.window.localStorage[tableKey] = jsonEncode(data);
    
    return 1; // 成功插入1条记录
  }

  @override
  Future<int> update(String table, Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final tableKey = '$_dbPrefix$table';
    final dataJson = html.window.localStorage[tableKey];
    
    if (dataJson == null) return 0;
    
    try {
      final List<dynamic> existing = jsonDecode(dataJson);
      List<Map<String, Object?>> data = existing.cast<Map<String, Object?>>();
      
      int updatedCount = 0;
      
      for (int i = 0; i < data.length; i++) {
        final row = data[i];
        
        // 简单的where条件匹配
        bool shouldUpdate = true;
        if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
          if (where.contains('=') && where.contains('?')) {
            final parts = where.split('=');
            if (parts.length == 2) {
              final column = parts[0].trim();
              final expectedValue = whereArgs[0];
              shouldUpdate = row[column] == expectedValue;
            }
          }
        }
        
        if (shouldUpdate) {
          data[i] = {...row, ...values};
          updatedCount++;
        }
      }
      
      html.window.localStorage[tableKey] = jsonEncode(data);
      return updatedCount;
      
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> delete(String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final tableKey = '$_dbPrefix$table';
    final dataJson = html.window.localStorage[tableKey];
    
    if (dataJson == null) return 0;
    
    try {
      final List<dynamic> existing = jsonDecode(dataJson);
      List<Map<String, Object?>> data = existing.cast<Map<String, Object?>>();
      
      int deletedCount = 0;
      
      data.removeWhere((row) {
        bool shouldDelete = true;
        if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
          if (where.contains('=') && where.contains('?')) {
            final parts = where.split('=');
            if (parts.length == 2) {
              final column = parts[0].trim();
              final expectedValue = whereArgs[0];
              shouldDelete = row[column] == expectedValue;
            }
          }
        }
        
        if (shouldDelete) {
          deletedCount++;
          return true;
        }
        return false;
      });
      
      html.window.localStorage[tableKey] = jsonEncode(data);
      return deletedCount;
      
    } catch (e) {
      return 0;
    }
  }

  // 文件存储操作（使用localStorage存储base64编码的文件）
  @override
  Future<bool> get supportsFileStorage async => true;

  @override
  Future<String> saveFile(String fileName, List<int> bytes) async {
    final fileKey = '$_filesPrefix$fileName';
    final base64Data = base64Encode(bytes);
    
    final fileInfo = {
      'fileName': fileName,
      'data': base64Data,
      'size': bytes.length,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    html.window.localStorage[fileKey] = jsonEncode(fileInfo);
    
    return 'web://$fileName'; // 返回Web平台的虚拟路径
  }

  @override
  Future<List<int>?> readFile(String filePath) async {
    final fileName = filePath.startsWith('web://') 
        ? filePath.substring(6) 
        : filePath;
    
    final fileKey = '$_filesPrefix$fileName';
    final fileInfoJson = html.window.localStorage[fileKey];
    
    if (fileInfoJson != null) {
      try {
        final fileInfo = jsonDecode(fileInfoJson) as Map<String, dynamic>;
        final base64Data = fileInfo['data'] as String;
        return base64Decode(base64Data);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }

  @override
  Future<void> deleteFile(String filePath) async {
    final fileName = filePath.startsWith('web://') 
        ? filePath.substring(6) 
        : filePath;
    
    final fileKey = '$_filesPrefix$fileName';
    html.window.localStorage.remove(fileKey);
  }

  @override
  Future<List<String>> listFiles() async {
    final files = <String>[];
    
    for (final key in html.window.localStorage.keys) {
      if (key.startsWith(_filesPrefix)) {
        final fileName = key.substring(_filesPrefix.length);
        files.add('web://$fileName');
      }
    }
    
    return files;
  }

  @override
  Future<Map<String, dynamic>> getStorageInfo() async {
    final info = <String, dynamic>{
      'platform': 'web',
      'supportsDatabase': await supportsDatabase,
      'supportsFileStorage': await supportsFileStorage,
    };

    // localStorage 使用情况
    try {
      int totalSize = 0;
      int appKeys = 0;
      int fileCount = 0;
      int dbTables = 0;
      
      for (final key in html.window.localStorage.keys) {
        final value = html.window.localStorage[key];
        if (value != null) {
          totalSize += value.length * 2; // 估算字符串大小（UTF-16）
          
          if (key.startsWith(_prefix)) {
            appKeys++;
          } else if (key.startsWith(_filesPrefix)) {
            fileCount++;
          } else if (key.startsWith(_dbPrefix)) {
            dbTables++;
          }
        }
      }
      
      info['localStorage'] = {
        'totalKeys': html.window.localStorage.length,
        'appKeys': appKeys,
        'fileCount': fileCount,
        'dbTables': dbTables,
        'estimatedSize': totalSize,
        'estimatedSizeKB': (totalSize / 1024).toStringAsFixed(2),
        'estimatedSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      info['localStorageError'] = e.toString();
    }

    return info;
  }
}