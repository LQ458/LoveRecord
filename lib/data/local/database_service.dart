import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../models/record.dart';
import '../models/media_file.dart';
import '../models/ai_analysis_result.dart';
import 'demo_data.dart';
import 'storage/storage_service_factory.dart';
import 'storage/storage_service_interface.dart';
import '../../core/config/app_config.dart';

class DatabaseService {
  static Database? _database;
  static StorageServiceInterface? _storageService;
  static String get _databaseName => AppConfig.databaseName;
  static const int _databaseVersion = 1;

  /// 获取存储服务实例
  static StorageServiceInterface get storageService {
    _storageService ??= StorageServiceFactory.instance;
    return _storageService!;
  }

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    await _performIntegrityCheck();
    return _database!;
  }

  /// 执行数据库完整性检查
  Future<void> _performIntegrityCheck() async {
    if (_database == null) return;
    
    try {
      final result = await _database!.rawQuery('PRAGMA integrity_check');
      if (result.isNotEmpty && result.first.values.first != 'ok') {
        if (AppConfig.enableDebugLogging) {
          print('Database integrity check failed: ${result.first.values.first}');
        }
        // Could implement recovery logic here
      }
    } catch (e) {
      if (AppConfig.enableDebugLogging) {
        print('Database integrity check error: $e');
      }
    }
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    // 为web平台配置sqflite
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 记录表
    await db.execute('''
      CREATE TABLE records (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT,
        type TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        metadata TEXT
      )
    ''');

    // 标签表
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        color TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // 记录标签关联表
    await db.execute('''
      CREATE TABLE record_tags (
        record_id TEXT NOT NULL,
        tag_id INTEGER NOT NULL,
        PRIMARY KEY (record_id, tag_id),
        FOREIGN KEY (record_id) REFERENCES records (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    // 媒体文件表
    await db.execute('''
      CREATE TABLE media_files (
        id TEXT PRIMARY KEY,
        record_id TEXT NOT NULL,
        path TEXT NOT NULL,
        type TEXT NOT NULL,
        size INTEGER,
        created_at INTEGER NOT NULL,
        metadata TEXT,
        FOREIGN KEY (record_id) REFERENCES records (id) ON DELETE CASCADE
      )
    ''');

    // AI分析结果表
    await db.execute('''
      CREATE TABLE ai_analysis (
        id TEXT PRIMARY KEY,
        record_id TEXT NOT NULL,
        analysis_type TEXT NOT NULL,
        result TEXT NOT NULL,
        confidence REAL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (record_id) REFERENCES records (id) ON DELETE CASCADE
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX idx_records_type ON records (type)');
    await db.execute('CREATE INDEX idx_records_created_at ON records (created_at)');
    await db.execute('CREATE INDEX idx_media_files_record_id ON media_files (record_id)');
    await db.execute('CREATE INDEX idx_ai_analysis_record_id ON ai_analysis (record_id)');
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 处理数据库版本升级
    if (oldVersion < 2) {
      // 未来版本升级逻辑
    }
  }

  /// 保存记录
  Future<void> saveRecord(Record record) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // 保存记录
      await txn.insert(
        'records',
        {
          'id': record.id,
          'title': record.title,
          'content': record.content,
          'type': record.type.name,
          'created_at': record.createdAt.millisecondsSinceEpoch,
          'updated_at': record.updatedAt.millisecondsSinceEpoch,
          'metadata': jsonEncode(record.metadata),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 保存标签
      for (final tag in record.tags) {
        await txn.insert(
          'tags',
          {
            'name': tag,
            'created_at': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // 保存标签关联
      for (final tag in record.tags) {
        final tagResult = await txn.query(
          'tags',
          where: 'name = ?',
          whereArgs: [tag],
        );
        
        if (tagResult.isNotEmpty) {
          await txn.insert(
            'record_tags',
            {
              'record_id': record.id,
              'tag_id': tagResult.first['id'],
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }

      // 保存媒体文件
      for (final mediaFile in record.mediaFiles) {
        await txn.insert(
          'media_files',
          {
            'id': mediaFile.id,
            'record_id': record.id,
            'path': mediaFile.path,
            'type': mediaFile.type.name,
            'size': mediaFile.size,
            'created_at': mediaFile.createdAt.millisecondsSinceEpoch,
            'metadata': jsonEncode(mediaFile.metadata),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// 初始化演示数据 (仅在开发环境)
  Future<void> initializeDemoData() async {
    // Only initialize demo data in development environment
    if (!AppConfig.useDemoData) {
      if (AppConfig.enableDebugLogging) {
        print('Demo data initialization skipped - not in development environment');
      }
      return;
    }
    
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM records'));
    
    if (count == 0) {
      if (AppConfig.enableDebugLogging) {
        print('Initializing demo data for development environment');
      }
      final demoRecords = DemoData.getDemoRecords();
      for (final record in demoRecords) {
        await saveRecord(record);
      }
    }
  }

  /// 获取记录列表
  Future<List<Record>> getRecords({
    RecordType? type,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int? limit,
    int? offset,
    bool includeAIAnalysis = false,
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (type != null) {
      whereClause += ' AND r.type = ?';
      whereArgs.add(type.name);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause += ' AND (r.title LIKE ? OR r.content LIKE ?)';
      whereArgs.addAll(['%$searchQuery%', '%$searchQuery%']);
    }

    if (startDate != null) {
      whereClause += ' AND r.created_at >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }

    if (endDate != null) {
      whereClause += ' AND r.created_at <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    String limitClause = '';
    if (limit != null) {
      limitClause = 'LIMIT $limit';
      if (offset != null) {
        limitClause += ' OFFSET $offset';
      }
    }

    final results = await db.rawQuery('''
      SELECT DISTINCT r.*, GROUP_CONCAT(t.name) as tags
      FROM records r
      LEFT JOIN record_tags rt ON r.id = rt.record_id
      LEFT JOIN tags t ON rt.tag_id = t.id
      WHERE $whereClause
      GROUP BY r.id
      ORDER BY r.created_at DESC
      $limitClause
    ''', whereArgs);

    final records = <Record>[];
    for (final row in results) {
      final record = await _buildRecordFromRow(row, includeAIAnalysis: includeAIAnalysis);
      if (record != null) {
        records.add(record);
      }
    }

    return records;
  }

  /// 根据ID获取记录
  Future<Record?> getRecordById(String id) async {
    final db = await database;
    
    final results = await db.rawQuery('''
      SELECT r.*, GROUP_CONCAT(t.name) as tags
      FROM records r
      LEFT JOIN record_tags rt ON r.id = rt.record_id
      LEFT JOIN tags t ON rt.tag_id = t.id
      WHERE r.id = ?
      GROUP BY r.id
    ''', [id]);

    if (results.isEmpty) return null;
    
    return await _buildRecordFromRow(results.first, includeAIAnalysis: true);
  }

  /// 更新记录
  Future<void> updateRecord(Record record) async {
    final db = await database;
    
    await db.update(
      'records',
      {
        'title': record.title,
        'content': record.content,
        'type': record.type.name,
        'created_at': record.createdAt.millisecondsSinceEpoch,
        'updated_at': record.updatedAt.millisecondsSinceEpoch,
        'tags': jsonEncode(record.tags),
        'metadata': jsonEncode(record.metadata),
      },
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// 删除记录
  Future<void> deleteRecord(String id) async {
    final db = await database;
    await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取所有标签
  Future<List<String>> getAllTags() async {
    final db = await database;
    final results = await db.query('tags', columns: ['name']);
    return results.map((row) => row['name'] as String).toList();
  }

  /// 从数据库行构建记录对象
  Future<Record?> _buildRecordFromRow(Map<String, dynamic> row, {bool includeAIAnalysis = false}) async {
    try {
      final db = await database;
      
      // 获取媒体文件
      final mediaResults = await db.query(
        'media_files',
        where: 'record_id = ?',
        whereArgs: [row['id']],
      );

      final mediaFiles = mediaResults.map((mediaRow) {
        return MediaFile(
          id: mediaRow['id'] as String,
          path: mediaRow['path'] as String,
          type: MediaType.values.firstWhere(
            (e) => e.name == mediaRow['type'],
            orElse: () => MediaType.text,
          ),
          size: mediaRow['size'] as int?,
          createdAt: DateTime.fromMillisecondsSinceEpoch(mediaRow['created_at'] as int),
          metadata: mediaRow['metadata'] != null 
              ? jsonDecode(mediaRow['metadata'] as String) 
              : <String, dynamic>{},
        );
      }).toList();

      // 解析标签
      final tagsString = row['tags'] as String?;
      final tags = tagsString?.split(',').where((tag) => tag.isNotEmpty).toList() ?? [];
      
      // 获取AI分析结果（如果需要）
      AIAnalysisResult? aiAnalysis;
      if (includeAIAnalysis) {
        final analysisData = await getAIAnalysisForRecord(row['id'] as String);
        if (analysisData.isNotEmpty) {
          aiAnalysis = AIAnalysisResult.fromDatabaseMap(analysisData);
        }
      }

      return Record(
        id: row['id'] as String,
        title: row['title'] as String,
        content: row['content'] as String? ?? '',
        mediaFiles: mediaFiles,
        tags: tags,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
        type: RecordType.values.firstWhere(
          (e) => e.name == row['type'],
          orElse: () => RecordType.diary,
        ),
        metadata: row['metadata'] != null 
            ? jsonDecode(row['metadata'] as String) 
            : <String, dynamic>{},
        aiAnalysis: aiAnalysis,
      );
    } catch (e) {
      print('Error building record from row: $e');
      return null;
    }
  }

  // ==================== AI Analysis 相关方法 ====================
  
  /// 保存AI分析结果
  Future<void> saveAIAnalysis({
    required String recordId,
    required String analysisType, // 'content', 'emotion', 'summary', etc.
    required String result,
    double? confidence,
  }) async {
    final db = await database;
    final id = const Uuid().v4();
    
    await db.insert(
      'ai_analysis',
      {
        'id': id,
        'record_id': recordId,
        'analysis_type': analysisType,
        'result': result,
        'confidence': confidence,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// 批量保存AI分析结果
  Future<void> saveAIAnalysisResults({
    required String recordId,
    String? summary,
    List<String>? keywords,
    List<String>? categories,
    String? emotion,
    double? emotionConfidence,
    double? contentConfidence,
  }) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // 先删除该记录的旧分析结果
      await txn.delete('ai_analysis', where: 'record_id = ?', whereArgs: [recordId]);
      
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // 保存摘要
      if (summary != null && summary.isNotEmpty) {
        await txn.insert('ai_analysis', {
          'id': const Uuid().v4(),
          'record_id': recordId,
          'analysis_type': 'summary',
          'result': summary,
          'confidence': contentConfidence,
          'created_at': now,
        });
      }
      
      // 保存关键词
      if (keywords != null && keywords.isNotEmpty) {
        await txn.insert('ai_analysis', {
          'id': const Uuid().v4(),
          'record_id': recordId,
          'analysis_type': 'keywords',
          'result': jsonEncode(keywords),
          'confidence': contentConfidence,
          'created_at': now,
        });
      }
      
      // 保存分类
      if (categories != null && categories.isNotEmpty) {
        await txn.insert('ai_analysis', {
          'id': const Uuid().v4(),
          'record_id': recordId,
          'analysis_type': 'categories',
          'result': jsonEncode(categories),
          'confidence': contentConfidence,
          'created_at': now,
        });
      }
      
      // 保存情感分析
      if (emotion != null && emotion.isNotEmpty) {
        await txn.insert('ai_analysis', {
          'id': const Uuid().v4(),
          'record_id': recordId,
          'analysis_type': 'emotion',
          'result': emotion,
          'confidence': emotionConfidence,
          'created_at': now,
        });
      }
    });
  }
  
  /// 获取记录的AI分析结果
  Future<Map<String, dynamic>> getAIAnalysisForRecord(String recordId) async {
    final db = await database;
    final results = await db.query(
      'ai_analysis',
      where: 'record_id = ?',
      whereArgs: [recordId],
      orderBy: 'created_at DESC',
    );
    
    final analysis = <String, dynamic>{};
    
    for (final row in results) {
      final type = row['analysis_type'] as String;
      final result = row['result'] as String;
      final confidence = row['confidence'] as double?;
      
      switch (type) {
        case 'summary':
          analysis['summary'] = result;
          analysis['summaryConfidence'] = confidence;
          break;
        case 'keywords':
          try {
            analysis['keywords'] = jsonDecode(result) as List<String>;
          } catch (e) {
            analysis['keywords'] = <String>[];
          }
          break;
        case 'categories':
          try {
            analysis['categories'] = jsonDecode(result) as List<String>;
          } catch (e) {
            analysis['categories'] = <String>[];
          }
          break;
        case 'emotion':
          analysis['emotion'] = result;
          analysis['emotionConfidence'] = confidence;
          break;
      }
    }
    
    return analysis;
  }
  
  /// 获取所有缺少AI分析的记录
  Future<List<Record>> getRecordsWithoutAIAnalysis() async {
    final db = await database;
    
    final results = await db.rawQuery('''
      SELECT r.* FROM records r
      LEFT JOIN ai_analysis a ON r.id = a.record_id
      WHERE a.record_id IS NULL
      ORDER BY r.created_at DESC
    ''');
    
    final records = <Record>[];
    for (final row in results) {
      final record = await _buildRecordFromRow(row);
      if (record != null) {
        records.add(record);
      }
    }
    
    return records;
  }
  
  /// 删除记录的AI分析结果
  Future<void> deleteAIAnalysis(String recordId) async {
    final db = await database;
    await db.delete('ai_analysis', where: 'record_id = ?', whereArgs: [recordId]);
  }
  
  /// 获取AI分析统计信息
  Future<Map<String, int>> getAIAnalysisStats() async {
    final db = await database;
    
    final totalRecords = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM records')
    ) ?? 0;
    
    final analyzedRecords = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(DISTINCT record_id) FROM ai_analysis')
    ) ?? 0;
    
    return {
      'totalRecords': totalRecords,
      'analyzedRecords': analyzedRecords,
      'unanalyzedRecords': totalRecords - analyzedRecords,
    };
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
} 