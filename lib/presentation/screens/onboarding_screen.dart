import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/settings_service.dart';
import '../../services/ai/ai_service_factory.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  String _selectedAiProvider = 'ernie_bot';
  String _selectedTheme = 'system';
  String _selectedLanguage = 'zh_CN';
  bool _autoBackup = false;
  String _backupFrequency = 'weekly';

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 进度指示器
            LinearProgressIndicator(
              value: (_currentPage + 1) / 4,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            
            // 页面内容
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildNamePage(),
                  _buildApiConfigPage(),
                  _buildSettingsPage(),
                ],
              ),
            ),
            
            // 底部按钮
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: const Text('上一步'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPage == 3 ? _completeSetup : _nextPage,
                      child: Text(_currentPage == 3 ? '完成设置' : '下一步'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Icon(
            Icons.favorite,
            size: 120,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            '欢迎使用 LoveRecord',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '你的个人AI驱动爱情记录应用\n记录美好时光，智能管理内容',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildFeatureCard(
            icon: Icons.auto_awesome,
            title: 'AI智能分析',
            description: '自动分析内容，提供智能标签和建议',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.security,
            title: '本地存储',
            description: '所有数据本地存储，保护你的隐私',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.sync,
            title: '多平台同步',
            description: '支持多设备同步，随时随地访问',
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            '告诉我你的名字',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '这样我们可以为你提供更个性化的体验',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '你的名字',
              hintText: '请输入你的名字',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildApiConfigPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.api,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            '配置AI服务',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '选择AI提供商并配置API密钥以启用智能功能',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          // AI提供商选择
          DropdownButtonFormField<String>(
            value: _selectedAiProvider,
            decoration: const InputDecoration(
              labelText: 'AI提供商',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'ernie_bot',
                child: Text('文心一言 (推荐)'),
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
            onChanged: (value) {
              setState(() {
                _selectedAiProvider = value!;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // API密钥输入
          TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'API密钥',
              hintText: '请输入你的API密钥',
              border: OutlineInputBorder(),
              helperText: 'API密钥将安全存储在本地，不会上传到服务器',
            ),
            obscureText: true,
          ),
          
          const SizedBox(height: 16),
          
          // 帮助链接
          TextButton.icon(
            onPressed: () {
              _showApiKeyHelp();
            },
            icon: const Icon(Icons.help_outline),
            label: const Text('如何获取API密钥？'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            '个性化设置',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '根据你的偏好调整应用设置',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          // 主题设置
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('主题模式'),
            subtitle: Text(_getThemeDisplayName(_selectedTheme)),
            trailing: DropdownButton<String>(
              value: _selectedTheme,
              items: const [
                DropdownMenuItem(value: 'system', child: Text('跟随系统')),
                DropdownMenuItem(value: 'light', child: Text('浅色')),
                DropdownMenuItem(value: 'dark', child: Text('深色')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
              },
            ),
          ),
          
          // 语言设置
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
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
          ),
          
          // 自动备份设置
          SwitchListTile(
            secondary: const Icon(Icons.backup),
            title: const Text('自动备份'),
            subtitle: const Text('定期备份数据到本地'),
            value: _autoBackup,
            onChanged: (value) {
              setState(() {
                _autoBackup = value;
              });
            },
          ),
          
          if (_autoBackup) ...[
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
                onChanged: (value) {
                  setState(() {
                    _backupFrequency = value!;
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'system':
        return '跟随系统';
      case 'light':
        return '浅色';
      case 'dark':
        return '深色';
      default:
        return '跟随系统';
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

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeSetup() async {
    // 保存设置
    if (_nameController.text.isNotEmpty) {
      await SettingsService.setUserName(_nameController.text);
    }
    
    if (_apiKeyController.text.isNotEmpty) {
      await SettingsService.setApiKey(_apiKeyController.text);
    }
    
    await SettingsService.setAiProvider(_selectedAiProvider);
    await SettingsService.setThemeMode(_selectedTheme);
    await SettingsService.setLanguage(_selectedLanguage);
    await SettingsService.setAutoBackup(_autoBackup);
    await SettingsService.setBackupFrequency(_backupFrequency);
    await SettingsService.setFirstLaunchComplete();

    // 导航到主页
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _showApiKeyHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('如何获取API密钥'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('文心一言 (推荐):'),
            const Text('1. 访问 https://console.bce.baidu.com/'),
            const Text('2. 注册并登录百度智能云账号'),
            const Text('3. 开通文心一言服务'),
            const Text('4. 在控制台获取API Key'),
            const SizedBox(height: 16),
            const Text('OpenAI GPT:'),
            const Text('1. 访问 https://platform.openai.com/'),
            const Text('2. 注册并登录OpenAI账号'),
            const Text('3. 在API Keys页面创建新的密钥'),
            const SizedBox(height: 16),
            const Text('Claude:'),
            const Text('1. 访问 https://console.anthropic.com/'),
            const Text('2. 注册并登录Anthropic账号'),
            const Text('3. 在API Keys页面创建新的密钥'),
          ],
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
} 