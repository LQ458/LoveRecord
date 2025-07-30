import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/record.dart';
import '../../data/local/database_service.dart';
import '../../services/ai/ai_service.dart';

part 'record_provider.g.dart';

@riverpod
DatabaseService databaseService(DatabaseServiceRef ref) {
  return DatabaseService();
}

@riverpod
class RecordsNotifier extends _$RecordsNotifier {
  @override
  Future<List<Record>> build() async {
    final db = ref.read(databaseServiceProvider);
    await db.initializeDemoData(); // 初始化演示数据
    return await db.getRecords();
  }

  /// 添加新记录
  Future<void> addRecord(Record record) async {
    final db = ref.read(databaseServiceProvider);
    await db.saveRecord(record);
    ref.invalidateSelf();
  }

  /// 更新记录
  Future<void> updateRecord(Record record) async {
    final db = ref.read(databaseServiceProvider);
    await db.saveRecord(record);
    ref.invalidateSelf();
  }

  /// 删除记录
  Future<void> deleteRecord(String id) async {
    final db = ref.read(databaseServiceProvider);
    await db.deleteRecord(id);
    ref.invalidateSelf();
  }

  /// 搜索记录
  Future<List<Record>> searchRecords(String query) async {
    final db = ref.read(databaseServiceProvider);
    return await db.getRecords(searchQuery: query);
  }

  /// 按类型获取记录
  Future<List<Record>> getRecordsByType(RecordType type) async {
    final db = ref.read(databaseServiceProvider);
    return await db.getRecords(type: type);
  }

  /// 按标签获取记录
  Future<List<Record>> getRecordsByTags(List<String> tags) async {
    final db = ref.read(databaseServiceProvider);
    // TODO: 实现按标签过滤
    return await db.getRecords();
  }
}

@riverpod
class RecordNotifier extends _$RecordNotifier {
  @override
  Future<Record?> build(String id) async {
    final db = ref.read(databaseServiceProvider);
    return await db.getRecordById(id);
  }

  /// 更新记录
  Future<void> updateRecord(Record record) async {
    final db = ref.read(databaseServiceProvider);
    await db.saveRecord(record);
    ref.invalidateSelf();
  }
}

@riverpod
class TagsNotifier extends _$TagsNotifier {
  @override
  Future<List<String>> build() async {
    final db = ref.read(databaseServiceProvider);
    return await db.getAllTags();
  }

  /// 刷新标签列表
  Future<void> refreshTags() async {
    ref.invalidateSelf();
  }
}

@riverpod
class AIServiceNotifier extends _$AIServiceNotifier {
  @override
  AIService? build() {
    // TODO: 从配置中获取AI服务
    return null;
  }

  /// 设置AI服务
  void setAIService(AIService service) {
    state = service;
  }

  /// 分析内容
  Future<ContentAnalysis> analyzeContent(String content) async {
    final service = state;
    if (service == null) {
      throw Exception('AI service not configured');
    }
    return await service.analyzeContent(content);
  }

  /// 分析情感
  Future<EmotionAnalysis> analyzeEmotion(String content) async {
    final service = state;
    if (service == null) {
      throw Exception('AI service not configured');
    }
    return await service.analyzeEmotion(content);
  }

  /// 生成摘要
  Future<String> generateSummary(String content) async {
    final service = state;
    if (service == null) {
      throw Exception('AI service not configured');
    }
    return await service.generateSummary(content);
  }

  /// 聊天对话
  Future<String> chat(String message, List<String> context) async {
    final service = state;
    if (service == null) {
      throw Exception('AI service not configured');
    }
    return await service.chat(message, context);
  }
} 