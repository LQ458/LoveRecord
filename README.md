# LoveRecord - AI驱动的智能个人记录应用

LoveRecord是一个基于Flutter开发的跨平台个人记录应用，集成Notion API和国内AI大模型，为用户提供智能化的内容管理、分类和分析服务。

## 功能特性

### 🎯 核心功能
- **多媒体记录**：支持文字、图片、音频、视频、文档等多种媒体类型
- **智能分类**：AI自动分析内容并分类（工作、学习、旅行、健康等）
- **情感分析**：AI分析记录的情感倾向，帮助用户了解自己的情绪变化
- **智能摘要**：自动生成内容摘要和标题建议
- **AI聊天助手**：与AI对话，获得内容回顾和情感支持

### 🔗 外部集成
- **Notion同步**：双向同步Notion数据库和页面
- **Markdown导入**：批量导入Markdown文件和文件夹
- **多种AI服务**：支持百度文心一言、阿里通义千问、腾讯混元等

### 🎨 个性化体验
- **主题系统**：多种预设主题 + 完全自定义
- **深色/浅色模式**：自动跟随系统主题
- **背景音乐**：内置音乐库，支持自定义音乐
- **跨平台同步**：iOS、Android、桌面端数据同步

### 🔒 隐私安全
- **完全本地存储**：用户数据完全可控
- **加密保护**：AES-256加密存储敏感数据
- **离线使用**：所有核心功能支持离线使用

## 技术架构

### 前端技术栈
- **Flutter 3.16+**：跨平台开发框架
- **Riverpod 2.4+**：响应式状态管理
- **Go Router**：声明式路由管理

### 数据存储
- **SQLite**：结构化数据存储（记录、标签、分类）
- **Hive**：非结构化数据存储（媒体文件、缓存）
- **AES-256**：数据加密保护

### AI服务集成
- **百度文心一言**：中文理解强，知识丰富
- **阿里通义千问**：多模态能力强
- **腾讯混元**：对话能力强
- **智谱AI**：开源友好，成本低
- **讯飞星火**：语音交互强

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── core/                     # 核心工具和常量
│   ├── constants/           # 常量定义
│   ├── utils/              # 工具函数
│   └── extensions/         # 扩展方法
├── data/                    # 数据层
│   ├── models/             # 数据模型
│   ├── repositories/       # 数据访问
│   ├── local/             # 本地存储
│   └── remote/            # 远程API
├── presentation/           # 表现层
│   ├── screens/           # 页面
│   ├── widgets/           # 组件
│   └── themes/            # 主题
├── business_logic/         # 业务逻辑
│   ├── providers/         # Riverpod提供者
│   └── state/             # 状态管理
└── services/              # 外部服务
    ├── ai/                # AI服务集成
    ├── notion/            # Notion API
    ├── sync/              # 同步服务
    └── media/             # 媒体处理
```

## 开发环境

### 系统要求
- Flutter 3.16+
- Dart 3.8+
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### 安装依赖
```bash
# 克隆项目
git clone https://github.com/your-username/loverecord.git
cd loverecord

# 安装依赖
flutter pub get

# 生成代码
flutter packages pub run build_runner build

# 运行应用
flutter run
```

### 开发命令
```bash
# 代码分析
flutter analyze

# 格式化代码
dart format .

# 运行测试
flutter test

# 构建应用
flutter build apk --release
flutter build ios --release
```

## 配置说明

### AI服务配置
在应用设置中配置AI服务API密钥：

1. **百度文心一言**
   - API Key: 从百度智能云获取
   - Secret Key: 从百度智能云获取

2. **阿里通义千问**
   - API Key: 从阿里云获取

3. **腾讯混元**
   - API Key: 从腾讯云获取

### Notion集成配置
1. 在Notion中创建Integration
2. 获取API Token
3. 在应用中配置Token和Database ID

## 开发计划

### 第一阶段：基础功能（已完成）
- ✅ 项目架构搭建
- ✅ 数据模型设计
- ✅ 本地存储实现
- ✅ 基础UI框架
- ✅ 主题系统

### 第二阶段：AI集成（进行中）
- 🔄 AI服务抽象层
- 🔄 百度文心一言集成
- ⏳ 其他AI服务集成
- ⏳ 智能分类功能

### 第三阶段：外部集成（计划中）
- ⏳ Notion API集成
- ⏳ Markdown导入功能
- ⏳ 同步功能

### 第四阶段：高级功能（计划中）
- ⏳ 个性化设置
- ⏳ 音乐背景
- ⏳ 性能优化

## 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 联系方式

- 项目主页：https://github.com/your-username/loverecord
- 问题反馈：https://github.com/your-username/loverecord/issues
- 邮箱：your-email@example.com

## 致谢

感谢以下开源项目的支持：
- [Flutter](https://flutter.dev/)
- [Riverpod](https://riverpod.dev/)
- [百度文心一言](https://cloud.baidu.com/product/wenxinworkshop)
- [阿里通义千问](https://dashscope.aliyun.com/)
- [Notion API](https://developers.notion.com/)
