import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/settings_service.dart';
import '../../data/local/database_service.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../../business_logic/providers/locale_provider.dart';
import '../themes/romantic_themes.dart';
import '../../services/ai/ai_service_factory.dart';
import '../../services/ai/ai_service.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _selectedAiProvider = 'ernie_bot';
  RomanticTheme _selectedRomanticTheme = RomanticTheme.sweetheartBliss;
  Brightness _selectedBrightness = Brightness.light;
  String _selectedLanguage = 'zh_CN';
  bool _autoBackup = false;
  String _backupFrequency = 'weekly';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _secretKeyController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    _apiKeyController.text = SettingsService.apiKey ?? '';
    _secretKeyController.text = SettingsService.secretKey ?? '';
    _nameController.text = SettingsService.userName ?? '';
    _selectedAiProvider = SettingsService.aiProvider;
    _selectedLanguage = SettingsService.language;
    _autoBackup = SettingsService.autoBackup;
    _backupFrequency = SettingsService.backupFrequency;
    
    // Load current theme from theme provider
    final themeState = ref.read(themeNotifierProvider);
    themeState.whenData((state) {
      setState(() {
        _selectedRomanticTheme = state.romanticTheme;
        _selectedBrightness = state.brightness;
      });
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 监听主题变化，实时更新UI
    final themeState = ref.watch(themeNotifierProvider);
    themeState.whenData((state) {
      if (_selectedRomanticTheme != state.romanticTheme || 
          _selectedBrightness != state.brightness) {
        setState(() {
          _selectedRomanticTheme = state.romanticTheme;
          _selectedBrightness = state.brightness;
        });
      }
    });

    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '设置',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置会自动保存')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildProfileSection(),
                _buildAiSection(),
                _buildAppearanceSection(),
                _buildDataSection(),
                _buildAboutSection(),
              ],
            ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '个人信息',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('用户名'),
            subtitle: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '请输入你的名字',
                border: InputBorder.none,
              ),
              onChanged: (value) async {
                await SettingsService.setUserName(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'AI服务配置',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.api),
            title: const Text('AI提供商'),
            subtitle: Text(_getAiProviderDisplayName(_selectedAiProvider)),
            trailing: DropdownButton<String>(
              value: _selectedAiProvider,
              items: const [
                DropdownMenuItem(
                  value: 'ernie_bot',
                  child: Text('文心一言'),
                ),
                DropdownMenuItem(
                  value: 'openai',
                  child: Text('OpenAI GPT'),
                ),
                DropdownMenuItem(
                  value: 'claude',
                  child: Text('Claude'),
                ),
              ],
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    _selectedAiProvider = value;
                  });
                  await SettingsService.setAiProvider(value);
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('API密钥'),
            subtitle: TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                hintText: '请输入API密钥',
                border: InputBorder.none,
              ),
              obscureText: true,
              onChanged: (value) async {
                await SettingsService.setApiKey(value);
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: _showApiKeyHelp,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('Secret密钥'),
            subtitle: TextField(
              controller: _secretKeyController,
              decoration: const InputDecoration(
                hintText: '请输入Secret密钥',
                border: InputBorder.none,
              ),
              obscureText: true,
              onChanged: (value) async {
                await SettingsService.setSecretKey(value);
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: _showSecretKeyHelp,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.api),
            title: const Text('测试连接'),
            subtitle: const Text('验证API密钥是否有效'),
            trailing: ElevatedButton(
              onPressed: _testApiConnection,
              child: const Text('测试'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '外观设置',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('浪漫主题'),
            subtitle: Text(_selectedRomanticTheme.displayName),
            trailing: ElevatedButton(
              onPressed: _showRomanticThemeDialog,
              child: const Text('选择'),
            ),
          ),
          SwitchListTile(
            secondary: Icon(
              _selectedBrightness == Brightness.dark ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('深色模式'),
            subtitle: Text(_selectedBrightness == Brightness.dark ? '深色主题已启用' : '浅色主题已启用'),
            value: _selectedBrightness == Brightness.dark,
            onChanged: (value) async {
              final newBrightness = value ? Brightness.dark : Brightness.light;
              setState(() {
                _selectedBrightness = newBrightness;
              });
              await ref.read(themeNotifierProvider.notifier).setBrightness(newBrightness);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('语言'),
            subtitle: Text(_getLanguageDisplayName(_selectedLanguage)),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: const [
                DropdownMenuItem(value: 'zh_CN', child: Text('中文')),
                DropdownMenuItem(value: 'en_US', child: Text('English')),
              ],
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                  await ref.read(localeNotifierProvider.notifier).changeLocale(value);
                  _showLanguageChangeInfo();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '数据管理',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.backup),
            title: const Text('自动备份'),
            subtitle: const Text('定期备份数据到本地'),
            value: _autoBackup,
            onChanged: (value) async {
              setState(() {
                _autoBackup = value;
              });
              await SettingsService.setAutoBackup(value);
            },
          ),
          if (_autoBackup)
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('备份频率'),
              subtitle: Text(_getBackupFrequencyDisplayName(_backupFrequency)),
              trailing: DropdownButton<String>(
                value: _backupFrequency,
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('每天')),
                  DropdownMenuItem(value: 'weekly', child: Text('每周')),
                  DropdownMenuItem(value: 'monthly', child: Text('每月')),
                ],
                onChanged: (value) async {
                  if (value != null) {
                    setState(() {
                      _backupFrequency = value;
                    });
                    await SettingsService.setBackupFrequency(value);
                  }
                },
              ),
            ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('导出数据'),
            subtitle: const Text('导出所有记录和设置'),
            trailing: ElevatedButton(
              onPressed: _exportData,
              child: const Text('导出'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('导入数据'),
            subtitle: const Text('从备份文件恢复数据'),
            trailing: ElevatedButton(
              onPressed: _importData,
              child: const Text('导入'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('清除所有数据'),
            subtitle: const Text('删除所有记录和设置'),
            trailing: ElevatedButton(
              onPressed: _clearAllData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('清除'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '关于应用',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('版本'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('隐私政策'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showPrivacyPolicy,
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('用户协议'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showUserAgreement,
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('反馈建议'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showFeedback,
          ),
        ],
      ),
    );
  }

  String _getAiProviderDisplayName(String provider) {
    switch (provider) {
      case 'ernie_bot':
        return '文心一言';
      case 'openai':
        return 'OpenAI GPT';
      case 'claude':
        return 'Claude';
      default:
        return '文心一言';
    }
  }

  String _getBrightnessDisplayName(Brightness brightness) {
    switch (brightness) {
      case Brightness.light:
        return '浅色';
      case Brightness.dark:
        return '深色';
    }
  }

  String _getLanguageDisplayName(String language) {
    switch (language) {
      case 'zh_CN':
        return '中文';
      case 'en_US':
        return 'English';
      default:
        return '中文';
    }
  }

  String _getBackupFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case 'daily':
        return '每天';
      case 'weekly':
        return '每周';
      case 'monthly':
        return '每月';
      default:
        return '每周';
    }
  }

  void _showLanguageChangeInfo() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('语言已切换 / Language switched'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showApiKeyHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('如何获取API密钥'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('文心一言 (推荐):'),
              Text('1. 访问 https://console.bce.baidu.com/'),
              Text('2. 注册并登录百度智能云账号'),
              Text('3. 开通文心一言服务'),
              Text('4. 在控制台获取API Key'),
              SizedBox(height: 16),
              Text('OpenAI GPT:'),
              Text('1. 访问 https://platform.openai.com/'),
              Text('2. 注册并登录OpenAI账号'),
              Text('3. 在API Keys页面创建新的密钥'),
              SizedBox(height: 16),
              Text('Claude:'),
              Text('1. 访问 https://console.anthropic.com/'),
              Text('2. 注册并登录Anthropic账号'),
              Text('3. 在API Keys页面创建新的密钥'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _showSecretKeyHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Secret密钥说明'),
        content: const Text(
          'Secret密钥用于API身份验证：\n\n'
          '• 文心一言：需要同时配置API Key和Secret Key\n'
          '• 其他服务：通常只需要API Key\n\n'
          '请确保API Key和Secret Key的安全性，不要泄露给他人。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  Future<void> _testApiConnection() async {
    final apiKey = _apiKeyController.text.trim();
    final secretKey = _secretKeyController.text.trim();
    
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先输入API密钥'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedAiProvider == 'ernie_bot' && secretKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('文心一言需要同时输入API密钥和Secret密钥'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final aiService = AiServiceFactory.createService(_selectedAiProvider);
      final result = await aiService.generateText('你好，请简单回复一句话。');
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('API测试成功'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('提供商: ${_getAiProviderDisplayName(_selectedAiProvider)}'),
                const SizedBox(height: 12),
                const Text('响应内容:'),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result.length > 100 ? '${result.substring(0, 100)}...' : result,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API测试失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportData() async {
    // TODO: 实现数据导出
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数据导出功能即将推出')),
    );
  }

  Future<void> _importData() async {
    // TODO: 实现数据导入
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数据导入功能即将推出')),
    );
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('此操作将删除所有记录和设置，无法撤销。确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SettingsService.clearAllSettings();
        // TODO: 清除数据库数据
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('所有数据已清除')),
          );
          Navigator.of(context).pushReplacementNamed('/onboarding');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('清除数据失败: $e')),
          );
        }
      }
    }
  }

  void _showPrivacyPolicy() {
    // TODO: 显示隐私政策
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('隐私政策页面即将推出')),
    );
  }

  void _showUserAgreement() {
    // TODO: 显示用户协议
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('用户协议页面即将推出')),
    );
  }

  void _showFeedback() {
    // TODO: 显示反馈页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('反馈页面即将推出')),
    );
  }

  /// 显示浪漫主题选择对话框
  void _showRomanticThemeDialog() {
    final currentTheme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: currentTheme.dialogBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '选择浪漫主题',
                style: currentTheme.textTheme.headlineSmall?.copyWith(
                  color: currentTheme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 400,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: RomanticTheme.values.length,
                  itemBuilder: (context, index) {
                    final theme = RomanticTheme.values[index];
                    final themeData = RomanticThemes.getTheme(theme);
                    final isSelected = theme == _selectedRomanticTheme;
                    
                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          _selectedRomanticTheme = theme;
                        });
                        await ref.read(themeNotifierProvider.notifier).changeRomanticTheme(theme);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: themeData.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected 
                              ? Border.all(color: Colors.white, width: 3)
                              : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: themeData.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                themeData.icon,
                                size: 32,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                themeData.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                themeData.description,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 