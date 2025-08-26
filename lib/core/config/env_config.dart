import 'dart:io';
import 'package:flutter/foundation.dart';

class EnvConfig {
  static final Map<String, String> _env = {};
  static bool _initialized = false;

  /// 初始化环境配置
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 尝试加载.env文件
      final envFile = File('.env');
      if (await envFile.exists()) {
        final content = await envFile.readAsString();
        _parseEnvContent(content);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not load .env file: $e');
      }
    }

    _initialized = true;
  }

  /// 解析环境变量内容
  static void _parseEnvContent(String content) {
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      final parts = trimmed.split('=');
      if (parts.length >= 2) {
        final key = parts[0].trim();
        final value = parts.sublist(1).join('=').trim();
        _env[key] = value;
      }
    }
  }

  /// 获取环境变量值
  static String? get(String key) {
    return _env[key];
  }

  /// 获取环境变量值，如果不存在则返回默认值
  static String getString(String key, {String defaultValue = ''}) {
    return _env[key] ?? defaultValue;
  }

  /// 获取布尔值环境变量
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = _env[key]?.toLowerCase();
    if (value == null) return defaultValue;
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// 获取整数环境变量
  static int getInt(String key, {int defaultValue = 0}) {
    final value = _env[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// 检查是否已初始化
  static bool get isInitialized => _initialized;

  /// 获取所有环境变量（调试用）
  static Map<String, String> get all => Map.unmodifiable(_env);
}