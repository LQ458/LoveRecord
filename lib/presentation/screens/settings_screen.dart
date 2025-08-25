import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/local/settings_service.dart';
import '../../data/local/database_service.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../../business_logic/providers/locale_provider.dart';
import '../themes/romantic_themes.dart';
import '../../services/ai/ai_service_factory.dart';
import '../../services/ai/ai_service.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/theme_brightness_selector.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _selectedAiProvider = 'ernie_bot';
  RomanticTheme _selectedRomanticTheme = RomanticTheme.sweetheartBliss;
  ThemeBrightnessMode _selectedBrightnessMode = ThemeBrightnessMode.system;
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
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    _apiKeyController.text = SettingsService.apiKey ?? '';
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
        _selectedBrightnessMode = state.brightnessMode;
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
          _selectedBrightnessMode != state.brightnessMode) {
        setState(() {
          _selectedRomanticTheme = state.romanticTheme;
          _selectedBrightnessMode = state.brightnessMode;
        });
      }
    });
    
    // 监听语言变化，实时更新UI
    final localeState = ref.watch(localeNotifierProvider);
    localeState.whenData((locale) {
      final languageCode = locale.languageCode == 'zh' ? 'zh_CN' : 'en_US';
      if (_selectedLanguage != languageCode) {
        setState(() {
          _selectedLanguage = languageCode;
        });
      }
    });

    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settingsAutoSave)),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildProfileSection(l10n),
                _buildAiSection(l10n),
                _buildAppearanceSection(l10n),
                _buildDataSection(l10n),
                _buildAboutSection(l10n),
              ],
            ),
    );
  }

  Widget _buildProfileSection(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.personalInfo,
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

  Widget _buildAiSection(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.aiServiceConfig,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.psychology),
            title: Text(l10n.aiProvider),
            subtitle: Text(_getAiProviderDisplayName(_selectedAiProvider)),
            trailing: DropdownButton<String>(
              value: _selectedAiProvider,
              items: [
                const DropdownMenuItem(
                  value: 'ernie_bot',
                  child: Text('文心一言'),
                ),
                const DropdownMenuItem(
                  value: 'mock',
                  child: Text('模拟AI服务（离线模式）'),
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
            title: Text(l10n.apiKey),
            subtitle: TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                hintText: l10n.pleaseEnterApiKey,
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
            leading: const Icon(Icons.api),
            title: Text(l10n.testConnection),
            subtitle: Text(l10n.verifyApiKey),
            trailing: ElevatedButton(
              onPressed: _testApiConnection,
              child: Text(l10n.test),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.wifi_find),
            title: Text(l10n.networkDiagnosis),
            subtitle: Text(l10n.checkingNetworkConnection),
            trailing: ElevatedButton(
              onPressed: _diagnoseNetwork,
              child: Text(l10n.runDiagnostics),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.appearanceSettings,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l10n.romanticTheme),
            subtitle: Text(_selectedRomanticTheme.displayName),
            trailing: ElevatedButton(
              onPressed: _showRomanticThemeDialog,
              child: Text(l10n.select),
            ),
          ),
          // Theme brightness selector
          const ThemeBrightnessSelector(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(_getLanguageDisplayName(_selectedLanguage)),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: [
                DropdownMenuItem(value: 'zh_CN', child: Text(l10n.chinese)),
                DropdownMenuItem(value: 'en_US', child: Text(l10n.english)),
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

  Widget _buildDataSection(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.dataManagement,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.backup),
            title: Text(l10n.autoBackup),
            subtitle: Text(l10n.regularBackup),
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
              title: Text(l10n.backupFrequency),
              subtitle: Text(_getBackupFrequencyDisplayName(_backupFrequency)),
              trailing: DropdownButton<String>(
                value: _backupFrequency,
                items: [
                  DropdownMenuItem(value: 'daily', child: Text(l10n.daily)),
                  DropdownMenuItem(value: 'weekly', child: Text(l10n.weekly)),
                  DropdownMenuItem(value: 'monthly', child: Text(l10n.monthly)),
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
            title: Text(l10n.exportData),
            subtitle: Text(l10n.exportAllRecords),
            trailing: ElevatedButton(
              onPressed: _exportData,
              child: Text(l10n.export),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: Text(l10n.importData),
            subtitle: Text(l10n.restoreFromBackup),
            trailing: ElevatedButton(
              onPressed: _importData,
              child: Text(l10n.import),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: Text(l10n.clearAllData),
            subtitle: Text(l10n.deleteAllRecords),
            trailing: ElevatedButton(
              onPressed: _clearAllData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: Text(l10n.clear),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.aboutApp,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(l10n.version),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showPrivacyPolicy,
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(l10n.userAgreement),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showUserAgreement,
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: Text(l10n.feedback),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showFeedback,
          ),
        ],
      ),
    );
  }

  String _getAiProviderDisplayName(String provider) {
    final l10n = AppLocalizations.of(context);
    switch (provider) {
      case 'ernie_bot':
        return '文心一言'; // Keep brand name as is
      case 'openai':
        return 'OpenAI GPT'; // Keep brand name as is
      case 'claude':
        return 'Claude'; // Keep brand name as is
      case 'mock':
        return l10n.mockAiServiceNotice;
      default:
        return '文心一言';
    }
  }



  String _getLanguageDisplayName(String language) {
    final l10n = AppLocalizations.of(context);
    switch (language) {
      case 'zh_CN':
        return l10n.chinese;
      case 'en_US':
        return l10n.english;
      default:
        return l10n.chinese;
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
        content: Text('语言已切换 / Language switched'), // Keep bilingual for language switching
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showApiKeyHelp() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.configureApiKey),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.configureApiKeyDescription),
              const SizedBox(height: 12),
              const Text('1. 访问 百度智能云 Qianfan 平台'), // Keep specific instructions
              const Text('   https://console.bce.baidu.com/qianfan/'),
              const SizedBox(height: 8),
              const Text('2. 注册并登录百度账号'),
              const SizedBox(height: 8),
              const Text('3. 开通文心一言服务'),
              const SizedBox(height: 8),
              const Text('4. 在应用管理中创建应用'),
              const SizedBox(height: 8),
              const Text('5. 获取 Client ID 和 Client Secret'),
              SizedBox(height: 8),
              Text('6. 将 Client ID 填入API密钥框'),
              SizedBox(height: 12),
              Text('注意事项：'),
              Text('• 需要实名认证后才能使用'),
              Text('• 新用户可获得免费额度'),
              Text('• 使用量超出后按量计费'),
              SizedBox(height: 12),
              Text('故障排查：'),
              Text('• 检查网络连接是否正常'),
              Text('• 确认API密钥是否正确'),
              Text('• 确认服务是否已开通'),
              Text('2. 注册并登录百度智能云账号'),
              Text('3. 开通文心一言服务'),
              Text('4. 在控制台获取API Key'),
              Text('5. 将API Key粘贴到设置中'),
              SizedBox(height: 16),
              Text('注意事项：'),
              Text('• 确保网络连接正常'),
              Text('• API Key需要妥善保管'),
              Text('• 如遇连接问题，请检查网络设置'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }



  Future<void> _testApiConnection() async {
    final l10n = AppLocalizations.of(context);
    final apiKey = _apiKeyController.text.trim();
    
    if (_selectedAiProvider == 'ernie_bot') {
      if (apiKey.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseEnterApiKeyFirst),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      final aiService = AiServiceFactory.createService(
        _selectedAiProvider,
        apiKey: apiKey,
      );
      
      if (_selectedAiProvider == 'mock') {
        // 模拟服务不需要网络测试
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.connectionTest),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        // 先测试网络连接
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('正在测试网络连接...'),
            backgroundColor: Colors.blue,
          ),
        );
        
        await aiService.testConnection();
        
        // 网络连接成功，测试API功能
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('网络连接正常，正在测试API功能...'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      
      final result = await aiService.generateText('你好，请简单回复一句话。');
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.apiTestSuccess),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l10n.provider}: ${_getAiProviderDisplayName(_selectedAiProvider)}'),
                const SizedBox(height: 12),
                Text(l10n.responseContent),
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
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.apiTestFailed}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _diagnoseNetwork() async {
    final l10n = AppLocalizations.of(context);
    final connectivityResult = await Connectivity().checkConnectivity();
    String message = '';
    String status = '';

    switch (connectivityResult) {
      case ConnectivityResult.mobile:
        message = '当前网络为移动网络，请注意流量消耗。';
        status = '移动网络';
        break;
      case ConnectivityResult.wifi:
        message = '当前网络为Wi-Fi，连接稳定。';
        status = 'Wi-Fi';
        break;
      case ConnectivityResult.ethernet:
        message = '当前网络为有线网络，连接稳定。';
        status = '有线网络';
        break;
      case ConnectivityResult.none:
        message = '当前网络不可用，请检查网络设置。';
        status = '无网络';
        break;
      default:
        message = '无法确定网络状态。';
        status = '未知';
        break;
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('网络诊断'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('当前网络状态: $status'),
              const SizedBox(height: 8),
              Text(message),
              const SizedBox(height: 16),
              const Text('如果无法连接百度API，建议：'),
              const SizedBox(height: 8),
              const Text('1. 使用模拟AI服务进行测试'),
              const Text('2. 检查防火墙设置'),
              const Text('3. 尝试使用VPN'),
              const Text('4. 联系网络管理员'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.ok),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 自动切换到模拟AI服务
                setState(() {
                  _selectedAiProvider = 'mock';
                });
                SettingsService.setAiProvider('mock');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已切换到模拟AI服务'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('切换到模拟服务'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _exportData() async {
    final l10n = AppLocalizations.of(context);
    // TODO: 实现数据导出
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.featureComingSoon)),
    );
  }

  Future<void> _importData() async {
    final l10n = AppLocalizations.of(context);
    // TODO: 实现数据导入
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.featureComingSoon)),
    );
  }

  Future<void> _clearAllData() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmClearAllData),
        content: Text(l10n.clearAllDataWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.clear),
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
    final l10n = AppLocalizations.of(context);
    // TODO: 显示隐私政策
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.featureComingSoon)),
    );
  }

  void _showUserAgreement() {
    final l10n = AppLocalizations.of(context);
    // TODO: 显示用户协议
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.featureComingSoon)),
    );
  }

  void _showFeedback() {
    final l10n = AppLocalizations.of(context);
    // TODO: 显示反馈页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.featureComingSoon)),
    );
  }

  /// 显示浪漫主题选择对话框
  void _showRomanticThemeDialog() {
    final l10n = AppLocalizations.of(context);
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
                l10n.chooseTheme,
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
                    final themeData = RomanticThemes.getLocalizedTheme(theme, l10n);
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
                              ? Border.all(
                                  color: currentTheme.brightness == Brightness.dark
                                      ? Colors.white
                                      : currentTheme.colorScheme.primary,
                                  width: 3
                                )
                              : Border.all(
                                  color: currentTheme.brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.3),
                                  width: 1
                                ),
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