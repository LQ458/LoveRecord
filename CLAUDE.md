# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LoveRecord is a cross-platform AI-driven personal recording application built with Flutter. It integrates with Notion API and Chinese AI models to provide intelligent content management, classification, and analysis services with complete local data control.

### Core Architecture
```
Frontend (Flutter UI) ↔ Business Logic (Dart) ↔ Data Layer (SQLite/Hive)
     ↓                      ↓                      ↓
External Services      AI Services             Sync Services
(Notion API)          (Chinese LLMs)          (Local/Cloud)
```

## Technology Stack

- **Framework**: Flutter 3.16+
- **State Management**: Riverpod 2.4+
- **Local Storage**: SQLite (structured data) + Hive (key-value data)
- **HTTP Client**: Dio 5.3+
- **Encryption**: crypto 3.0+ (AES-256)
- **Media Handling**: image_picker, path_provider
- **Platform**: iOS, Android, Desktop (Windows/macOS/Linux)

## Development Commands

### Project Setup
```bash
# Initialize Flutter project
flutter create --org com.loverecord loverecord .

# Get dependencies
flutter pub get

# Generate code (for json_serializable, etc.)
flutter packages pub run build_runner build

# Clean and rebuild
flutter clean && flutter pub get
```

### Development
```bash
# Run on specific platform
flutter run -d ios
flutter run -d android
flutter run -d macos
flutter run -d windows
flutter run -d linux

# Hot reload during development
# Press 'r' in terminal or save files in IDE

# Run with specific flavor (if implemented)
flutter run --flavor dev
flutter run --flavor prod
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/ai_service_test.dart

# Run integration tests
flutter test integration_test/
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Fix common issues
dart fix --apply
```

### Building
```bash
# Build APK (Android)
flutter build apk --release
flutter build apk --debug

# Build App Bundle (Android)
flutter build appbundle --release

# Build iOS
flutter build ios --release

# Build desktop
flutter build macos --release
flutter build windows --release
flutter build linux --release
```

## Key Architecture Components

### 1. Data Models
```dart
// Core record entity
class Record {
  final String id;
  final String title;
  final String content;
  final List<MediaFile> mediaFiles;
  final List<String> tags;
  final DateTime createdAt;
  final RecordType type;
  final Map<String, dynamic> metadata;
}

// Media types supported
enum MediaType { text, image, audio, video, document, location, contact }

// Record categories
enum RecordType { diary, work, study, travel, health, finance, creative }
```

### 2. AI Service Integration
The app integrates with multiple Chinese AI providers:
- **百度文心一言 (ERNIE Bot)** - Strong Chinese language understanding
- **阿里通义千问 (Qwen)** - Multimodal capabilities
- **腾讯混元 (Hunyuan)** - Conversational AI
- **智谱AI (ChatGLM)** - Open-source friendly
- **讯飞星火 (SparkDesk)** - Voice interaction

AI services are abstracted through a common interface:
```dart
abstract class AIService {
  Future<String> generateText(String prompt);
  Future<ContentAnalysis> analyzeContent(String content);
  Future<List<String>> classifyContent(String content);
  Future<EmotionAnalysis> analyzeEmotion(String content);
  Future<String> generateSummary(String content);
}
```

### 3. Database Schema
```sql
-- Main tables
records (id, title, content, type, created_at, updated_at, metadata)
tags (id, name, color, created_at)
record_tags (record_id, tag_id) -- Many-to-many relationship
media_files (id, record_id, path, type, size, created_at)
ai_analysis (id, record_id, analysis_type, result, confidence, created_at)
```

### 4. External Integrations

#### Notion API
- Two-way sync with Notion databases
- Content conversion between Notion blocks and local records
- Conflict resolution for simultaneous edits

#### Markdown Import
- Batch import from folder structures
- Automatic media file extraction and linking
- Metadata preservation from frontmatter

### 5. Sync Strategy
- **Incremental sync**: Only sync changes since last sync timestamp
- **Conflict resolution**: Last-write-wins with user override option
- **Offline-first**: All operations work without internet connection

## Development Guidelines

### State Management with Riverpod
- Use `StateNotifierProvider` for complex state
- Use `FutureProvider` for async data loading
- Use `StreamProvider` for real-time data updates
- Keep providers focused and single-responsibility

### Database Operations
- Always use transactions for multi-table operations
- Implement proper error handling and rollback
- Use parameterized queries to prevent SQL injection
- Consider pagination for large data sets

### AI Integration Best Practices
- Implement retry logic with exponential backoff
- Cache AI results to reduce API calls
- Handle rate limiting gracefully
- Provide fallback when AI services are unavailable
- Never send sensitive data to AI services without user consent

### Security Considerations
- Encrypt sensitive data at rest using AES-256
- Never commit API keys or tokens
- Use environment variables for sensitive configuration
- Implement proper authentication for cloud sync
- Validate all user inputs before processing

### Testing Strategy
- **Unit Tests**: Business logic, data models, utility functions
- **Integration Tests**: Database operations, API integrations
- **Widget Tests**: UI components and user interactions
- **End-to-End Tests**: Complete user workflows

Target coverage: >80% for core business logic

## File Structure
```
lib/
├── main.dart                 # App entry point
├── core/                     # Core utilities and constants
│   ├── constants/
│   ├── utils/
│   └── extensions/
├── data/                     # Data layer
│   ├── models/              # Data models
│   ├── repositories/        # Data access
│   ├── local/              # Local storage (SQLite/Hive)
│   └── remote/             # Remote APIs (Notion, AI)
├── presentation/            # UI layer
│   ├── screens/
│   ├── widgets/
│   └── themes/
├── business_logic/          # Business logic (Riverpod providers)
│   ├── providers/
│   └── state/
└── services/               # External services
    ├── ai/                 # AI service integrations
    ├── notion/             # Notion API
    ├── sync/               # Synchronization
    └── media/              # Media processing
```

## Environment Configuration

Create `.env` files for different environments:
```bash
# .env.dev
AI_SERVICE_API_KEY=your_dev_key
NOTION_API_KEY=your_dev_notion_key
ENCRYPTION_KEY=your_dev_encryption_key

# .env.prod  
AI_SERVICE_API_KEY=your_prod_key
NOTION_API_KEY=your_prod_notion_key
ENCRYPTION_KEY=your_prod_encryption_key
```

## Common Development Tasks

### Adding a New AI Service Provider
1. Implement the `AIService` abstract class
2. Add provider configuration in `ai_service_factory.dart`
3. Update UI to allow service selection
4. Add integration tests
5. Update documentation

### Adding a New Record Type
1. Update `RecordType` enum
2. Add type-specific UI components
3. Update database migrations if needed
4. Add type-specific AI analysis prompts
5. Update export/import logic

### Implementing a New Sync Source
1. Create service class implementing sync interface
2. Add authentication handling
3. Implement incremental sync logic
4. Add conflict resolution
5. Update sync manager to include new source

## Performance Considerations

- Use `const` constructors for immutable widgets
- Implement proper list virtualization for large datasets
- Optimize image loading with caching and compression
- Use database indexes for frequently queried fields
- Implement proper memory management for media files
- Consider lazy loading for AI analysis results

## Debugging

### Common Issues
- **AI API failures**: Check network connectivity and API keys
- **Sync conflicts**: Review conflict resolution logs
- **Performance issues**: Use Flutter DevTools profiler
- **Database errors**: Check SQL syntax and constraints

### Useful Debug Commands
```bash
# Flutter inspector
flutter inspector

# Performance overlay
flutter run --debug-performance

# Memory debugging
flutter run --enable-dart-profiling

# Network debugging
flutter run --observatory-port=8888
```

This architecture supports a scalable, maintainable codebase that can evolve as the project grows from MVP to full-featured application.