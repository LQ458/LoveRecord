import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'storage_service_interface.dart';

/// 原生平台（iOS、Android、macOS、Windows、Linux）存储服务实现
class NativeStorageService implements StorageServiceInterface {
  SharedPreferences? _prefs;
  Database? _database;
  String? _documentsPath;

  @override
  Future<void> initialize() async {
    // 初始化 SharedPreferences
    _prefs = await SharedPreferences.getInstance();

    // 初始化数据库
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      // 获取文档目录
      final documentsDir = await getApplicationDocumentsDirectory();
      _documentsPath = documentsDir.path;

      // 初始化数据库
      final dbPath = path.join(_documentsPath!, 'loverecord.db');
      _database = await openDatabase(
        dbPath,
        version: 1,
        onCreate: _createDatabase,
      );
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    // 创建数据库表结构
    await db.execute('''
      CREATE TABLE records (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        category TEXT,
        tags TEXT,
        mood_score INTEGER,
        weather TEXT,
        location TEXT,
        is_favorite INTEGER DEFAULT 0,
        ai_analysis TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE media_files (
        id TEXT PRIMARY KEY,
        record_id TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        file_size INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (record_id) REFERENCES records (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // SharedPreferences 操作
  @override
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs?.getString(key);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs?.getInt(key);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs?.getBool(key);
  }

  @override
  Future<double?> getDouble(String key) async {
    return _prefs?.getDouble(key);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    return _prefs?.getStringList(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs?.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs?.containsKey(key) ?? false;
  }

  @override
  Future<Set<String>> getKeys() async {
    return _prefs?.getKeys() ?? <String>{};
  }

  // 数据库操作
  @override
  Future<bool> get supportsDatabase async => _database != null;

  @override
  Future<void> executeSql(String sql, [List<Object?>? arguments]) async {
    await _database?.execute(sql, arguments);
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
    if (_database == null) return [];
    
    return await _database!.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> insert(String table, Map<String, Object?> values) async {
    if (_database == null) return 0;
    return await _database!.insert(table, values);
  }

  @override
  Future<int> update(String table, Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    if (_database == null) return 0;
    return await _database!.update(table, values, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> delete(String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    if (_database == null) return 0;
    return await _database!.delete(table, where: where, whereArgs: whereArgs);
  }

  // 文件存储操作
  @override
  Future<bool> get supportsFileStorage async => _documentsPath != null;

  @override
  Future<String> saveFile(String fileName, List<int> bytes) async {
    if (_documentsPath == null) throw Exception('文件存储未初始化');
    
    final filePath = path.join(_documentsPath!, 'media', fileName);
    final file = File(filePath);
    
    // 确保目录存在
    await file.parent.create(recursive: true);
    
    // 写入文件
    await file.writeAsBytes(bytes);
    
    return filePath;
  }

  @override
  Future<List<int>?> readFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // 忽略删除错误
    }
  }

  @override
  Future<List<String>> listFiles() async {
    if (_documentsPath == null) return [];
    
    try {
      final mediaDir = Directory(path.join(_documentsPath!, 'media'));
      if (await mediaDir.exists()) {
        final files = await mediaDir.list().toList();
        return files.whereType<File>().map((f) => f.path).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getStorageInfo() async {
    final info = <String, dynamic>{
      'platform': 'native',
      'supportsDatabase': await supportsDatabase,
      'supportsFileStorage': await supportsFileStorage,
    };

    if (_documentsPath != null) {
      info['documentsPath'] = _documentsPath;
      
      // 计算存储使用情况
      try {
        final mediaDir = Directory(path.join(_documentsPath!, 'media'));
        if (await mediaDir.exists()) {
          int totalSize = 0;
          int fileCount = 0;
          
          await for (final entity in mediaDir.list(recursive: true)) {
            if (entity is File) {
              fileCount++;
              final stat = await entity.stat();
              totalSize += stat.size;
            }
          }
          
          info['mediaFiles'] = {
            'count': fileCount,
            'totalSize': totalSize,
            'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
          };
        }
      } catch (e) {
        info['error'] = e.toString();
      }
    }

    return info;
  }
}