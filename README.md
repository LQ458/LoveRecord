# LoveRecord - AI-Powered Smart Personal Record App

LoveRecord is a cross-platform personal record application developed with Flutter, integrating Notion API and domestic AI large models to provide users with intelligent content management, classification, and analysis services.

## Features

### 🎯 Core Features
- **Multimedia Records**: Support for text, images, audio, video, documents, and other media types
- **Smart Classification**: AI automatically analyzes content and categorizes it (work, study, travel, health, etc.)
- **Emotion Analysis**: AI analyzes the emotional tendency of records to help users understand their emotional changes
- **Smart Summaries**: Automatically generates content summaries and title suggestions
- **AI Chat Assistant**: Chat with AI for content review and emotional support

### 🔗 External Integrations
- **Notion Sync**: Bidirectional synchronization with Notion databases and pages
- **Markdown Import**: Batch import Markdown files and folders
- **Multiple AI Services**: Support for Baidu Ernie Bot, Alibaba Tongyi Qianwen, Tencent Hunyuan, and more

### 🎨 Personalized Experience
- **Theme System**: Multiple preset themes + fully customizable
- **Dark/Light Mode**: Automatically follows system theme
- **Background Music**: Built-in music library with custom music support
- **Cross-platform Sync**: Data synchronization across iOS, Android, and desktop

### 🔒 Privacy & Security
- **Complete Local Storage**: User data is fully controllable
- **Encryption Protection**: AES-256 encrypted storage for sensitive data
- **Offline Usage**: All core features support offline use

## Technical Architecture

### Frontend Tech Stack
- **Flutter 3.16+**: Cross-platform development framework
- **Riverpod 2.4+**: Reactive state management
- **Go Router**: Declarative routing management

### Data Storage
- **SQLite**: Structured data storage (records, tags, categories)
- **Hive**: Unstructured data storage (media files, cache)
- **AES-256**: Data encryption protection

### AI Service Integration
- **Baidu Ernie Bot**: Strong Chinese understanding, rich knowledge
- **Alibaba Tongyi Qianwen**: Strong multimodal capabilities
- **Tencent Hunyuan**: Strong conversational abilities
- **Zhipu AI**: Open source friendly, low cost
- **iFlytek Spark**: Strong voice interaction

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── core/                     # Core utilities and constants
│   ├── constants/           # Constant definitions
│   ├── utils/              # Utility functions
│   └── extensions/         # Extension methods
├── data/                    # Data layer
│   ├── models/             # Data models
│   ├── repositories/       # Data access
│   ├── local/             # Local storage
│   └── remote/            # Remote APIs
├── presentation/           # Presentation layer
│   ├── screens/           # Pages
│   ├── widgets/           # Components
│   └── themes/            # Themes
├── business_logic/         # Business logic
│   ├── providers/         # Riverpod providers
│   └── state/             # State management
└── services/              # External services
    ├── ai/                # AI service integration
    ├── notion/            # Notion API
    ├── sync/              # Sync services
    └── media/             # Media processing
```

## Development Environment

### System Requirements
- Flutter 3.16+
- Dart 3.8+
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Install Dependencies
```bash
# Clone the project
git clone https://github.com/your-username/loverecord.git
cd loverecord

# Install dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build

# Run the app
flutter run
```

### Development Commands
```bash
# Code analysis
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Build app
flutter build apk --release
flutter build ios --release
```

## Configuration

### AI Service Configuration
Configure AI service API keys in the app settings:

1. **Baidu Ernie Bot**
   - API Key: Get from Baidu Cloud
   - Client Secret: Get from Baidu Cloud

2. **Alibaba Tongyi Qianwen**
   - API Key: Get from Alibaba Cloud

3. **Tencent Hunyuan**
   - API Key: Get from Tencent Cloud

### Notion Integration Configuration
1. Create an Integration in Notion
2. Get the API Token
3. Configure Token and Database ID in the app

## Development Roadmap

### Phase 1: Basic Features (Completed)
- ✅ Project architecture setup
- ✅ Data model design
- ✅ Local storage implementation
- ✅ Basic UI framework
- ✅ Theme system

### Phase 2: AI Integration (In Progress)
- 🔄 AI service abstraction layer
- 🔄 Baidu Ernie Bot integration
- ⏳ Other AI service integrations
- ⏳ Smart classification features

### Phase 3: External Integration (Planned)
- ⏳ Notion API integration
- ⏳ Markdown import functionality
- ⏳ Sync features

### Phase 4: Advanced Features (Planned)
- ⏳ Personalization settings
- ⏳ Background music
- ⏳ Performance optimization

## Contributing

Welcome to contribute code! Please follow these steps:

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

- Project homepage: https://github.com/your-username/loverecord
- Issue feedback: https://github.com/your-username/loverecord/issues
- Email: your-email@example.com

## Acknowledgments

Thanks to the following open source projects:
- [Flutter](https://flutter.dev/)
- [Riverpod](https://riverpod.dev/)
- [Baidu Ernie Bot](https://cloud.baidu.com/product/wenxinworkshop)
- [Alibaba Tongyi Qianwen](https://dashscope.aliyun.com/)
- [Notion API](https://developers.notion.com/)
