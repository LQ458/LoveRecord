import 'package:flutter/foundation.dart';
import 'env_config.dart';

enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  static const Environment _environment = kDebugMode 
      ? Environment.development 
      : Environment.production;

  static Environment get environment => _environment;
  
  // Database configuration
  static bool get useDemoData => EnvConfig.getBool('USE_DEMO_DATA', 
      defaultValue: _environment == Environment.development);
  static bool get enableDebugLogging => EnvConfig.getBool('ENABLE_DEBUG_LOGGING',
      defaultValue: _environment != Environment.production);
  
  // AI Service configuration
  static String get aiProvider => EnvConfig.getString('AI_PROVIDER', 
      defaultValue: _environment == Environment.development ? 'mock' : 'dashscope');
  
  static String get aiApiKey => EnvConfig.getString('AI_API_KEY');
  
  // Specific AI Service API Keys
  static String getDashScopeApiKey() => EnvConfig.getString('DASHSCOPE_API_KEY');
  static String getBaiduClientId() => EnvConfig.getString('BAIDU_CLIENT_ID');
  static String getBaiduClientSecret() => EnvConfig.getString('BAIDU_CLIENT_SECRET');
  
  static String get defaultAiProvider {
    switch (_environment) {
      case Environment.development:
        return aiProvider.isNotEmpty ? aiProvider : 'mock';
      case Environment.staging:
      case Environment.production:
        return aiProvider.isNotEmpty ? aiProvider : 'dashscope';
    }
  }
  
  // Database configuration
  static String get databaseName {
    switch (_environment) {
      case Environment.development:
        return 'loverecord_dev.db';
      case Environment.staging:
        return 'loverecord_staging.db';
      case Environment.production:
        return 'loverecord.db';
    }
  }
  
  // Feature flags
  static bool get enableAnalytics => _environment == Environment.production;
  static bool get enableCrashReporting => _environment != Environment.development;
  
  // API configuration
  static Duration get apiTimeout {
    switch (_environment) {
      case Environment.development:
        return const Duration(seconds: 60); // Longer timeout for debugging
      case Environment.staging:
      case Environment.production:
        return const Duration(seconds: 30);
    }
  }
}