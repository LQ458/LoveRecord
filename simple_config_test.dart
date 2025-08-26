import 'dart:io';

void main() async {
  print('=== 简单配置测试 ===');
  
  // 直接读取.env文件
  try {
    final envFile = File('.env');
    if (await envFile.exists()) {
      final content = await envFile.readAsString();
      print('✅ .env文件存在');
      print('文件内容:');
      print(content);
      
      // 解析API Key
      final lines = content.split('\n');
      String? apiKey;
      String? provider;
      
      for (final line in lines) {
        if (line.startsWith('AI_API_KEY=')) {
          apiKey = line.substring('AI_API_KEY='.length).trim();
        }
        if (line.startsWith('AI_PROVIDER=')) {
          provider = line.substring('AI_PROVIDER='.length).trim();
        }
      }
      
      print('\n解析结果:');
      print('AI_PROVIDER: $provider');
      print('AI_API_KEY: ${apiKey?.isNotEmpty == true ? "${apiKey!.substring(0, 8)}..." : "未配置"}');
      
      if (apiKey != null && apiKey.isNotEmpty) {
        print('\n✅ 配置正常，API Key已设置');
      } else {
        print('\n❌ API Key未配置');
      }
    } else {
      print('❌ .env文件不存在');
    }
  } catch (e) {
    print('❌ 读取.env文件失败: $e');
  }
}