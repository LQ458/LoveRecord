import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lib/core/config/env_config.dart';
import 'lib/data/local/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化服务
  await Hive.initFlutter();
  await EnvConfig.initialize();
  await SettingsService.initialize();
  
  print('=== 环境配置调试 ===');
  print('EnvConfig.isInitialized: ${EnvConfig.isInitialized}');
  print('EnvConfig AI_PROVIDER: ${EnvConfig.getString('AI_PROVIDER')}');
  print('EnvConfig AI_API_KEY: ${EnvConfig.getString('AI_API_KEY').isNotEmpty ? "已配置(${EnvConfig.getString('AI_API_KEY').length}字符)" : "未配置"}');
  
  print('\n=== SettingsService配置 ===');
  print('SettingsService.aiProvider: ${SettingsService.aiProvider}');
  print('SettingsService.apiKey: ${SettingsService.apiKey?.isNotEmpty == true ? "已配置(${SettingsService.apiKey!.length}字符)" : "未配置"}');
  
  // 如果SettingsService中没有配置，尝试从环境变量加载
  if (SettingsService.apiKey?.isEmpty ?? true) {
    final envApiKey = EnvConfig.getString('AI_API_KEY');
    if (envApiKey.isNotEmpty) {
      await SettingsService.setApiKey(envApiKey);
      print('\n✅ 从环境变量加载API Key到SettingsService');
      print('新的SettingsService.apiKey: 已配置(${SettingsService.apiKey!.length}字符)');
    } else {
      print('\n❌ 环境变量中也没有找到AI_API_KEY');
    }
  }
  
  print('\n=== 最终配置状态 ===');
  print('AI Provider: ${SettingsService.aiProvider}');
  print('API Key: ${SettingsService.apiKey?.isNotEmpty == true ? "✅ 已配置" : "❌ 未配置"}');
}