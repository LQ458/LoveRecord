import 'package:shared_preferences/shared_preferences.dart';
import 'storage/storage_service_factory.dart';
import 'storage/storage_service_interface.dart';

class SettingsService {
  static const String _apiKeyKey = 'api_key';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _userNameKey = 'user_name';
  static const String _themeModeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _aiProviderKey = 'ai_provider';
  static const String _autoBackupKey = 'auto_backup';
  static const String _backupFrequencyKey = 'backup_frequency';
  static const String _lastBackupTimeKey = 'last_backup_time';

  static SharedPreferences? _prefs;

  /// 初始化设置服务
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 检查是否首次启动
  static bool get isFirstLaunch {
    return _prefs?.getBool(_isFirstLaunchKey) ?? true;
  }

  /// 设置首次启动状态
  static Future<void> setFirstLaunchComplete() async {
    await _prefs?.setBool(_isFirstLaunchKey, false);
  }

  /// 获取API密钥
  static String? get apiKey {
    return _prefs?.getString(_apiKeyKey);
  }

  /// 设置API密钥
  static Future<void> setApiKey(String apiKey) async {
    await _prefs?.setString(_apiKeyKey, apiKey);
  }

  /// 获取用户名
  static String? get userName {
    return _prefs?.getString(_userNameKey);
  }

  /// 设置用户名
  static Future<void> setUserName(String userName) async {
    await _prefs?.setString(_userNameKey, userName);
  }

  /// 获取主题模式
  static String get themeMode {
    return _prefs?.getString(_themeModeKey) ?? 'system';
  }

  /// 设置主题模式
  static Future<void> setThemeMode(String themeMode) async {
    await _prefs?.setString(_themeModeKey, themeMode);
  }

  /// 获取语言设置
  static String get language {
    return _prefs?.getString(_languageKey) ?? 'zh_CN';
  }

  /// 设置语言
  static Future<void> setLanguage(String language) async {
    await _prefs?.setString(_languageKey, language);
  }

  /// 获取AI提供商
  static String get aiProvider {
    return _prefs?.getString(_aiProviderKey) ?? 'dashscope';
  }

  /// 设置AI提供商
  static Future<void> setAiProvider(String provider) async {
    await _prefs?.setString(_aiProviderKey, provider);
  }

  /// 获取自动备份设置
  static bool get autoBackup {
    return _prefs?.getBool(_autoBackupKey) ?? false;
  }

  /// 设置自动备份
  static Future<void> setAutoBackup(bool enabled) async {
    await _prefs?.setBool(_autoBackupKey, enabled);
  }

  /// 获取备份频率
  static String get backupFrequency {
    return _prefs?.getString(_backupFrequencyKey) ?? 'weekly';
  }

  /// 设置备份频率
  static Future<void> setBackupFrequency(String frequency) async {
    await _prefs?.setString(_backupFrequencyKey, frequency);
  }

  /// 获取最后备份时间
  static DateTime? get lastBackupTime {
    final timestamp = _prefs?.getInt(_lastBackupTimeKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// 设置最后备份时间
  static Future<void> setLastBackupTime(DateTime time) async {
    await _prefs?.setInt(_lastBackupTimeKey, time.millisecondsSinceEpoch);
  }

  /// 清除所有设置
  static Future<void> clearAllSettings() async {
    await _prefs?.clear();
  }

  /// 导出设置
  static Map<String, dynamic> exportSettings() {
    return {
      'userName': userName,
      'themeMode': themeMode,
      'language': language,
      'aiProvider': aiProvider,
      'autoBackup': autoBackup,
      'backupFrequency': backupFrequency,
    };
  }

  /// 导入设置
  static Future<void> importSettings(Map<String, dynamic> settings) async {
    if (settings['userName'] != null) {
      await setUserName(settings['userName']);
    }
    if (settings['themeMode'] != null) {
      await setThemeMode(settings['themeMode']);
    }
    if (settings['language'] != null) {
      await setLanguage(settings['language']);
    }
    if (settings['aiProvider'] != null) {
      await setAiProvider(settings['aiProvider']);
    }
    if (settings['autoBackup'] != null) {
      await setAutoBackup(settings['autoBackup']);
    }
    if (settings['backupFrequency'] != null) {
      await setBackupFrequency(settings['backupFrequency']);
    }
  }
} 