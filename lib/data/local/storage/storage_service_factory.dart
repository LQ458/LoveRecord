import 'package:flutter/foundation.dart';
import 'storage_service_interface.dart';
import 'native_storage_service.dart';
import 'web_storage_service.dart' if (dart.library.io) 'web_storage_stub.dart';

/// 存储服务工厂
/// 根据平台自动选择合适的存储服务实现
class StorageServiceFactory {
  static StorageServiceInterface? _instance;

  /// 获取存储服务实例（单例模式）
  static StorageServiceInterface get instance {
    _instance ??= _createStorageService();
    return _instance!;
  }

  /// 根据平台创建存储服务
  static StorageServiceInterface _createStorageService() {
    if (kIsWeb) {
      return WebStorageService();
    } else {
      return NativeStorageService();
    }
  }

  /// 重置实例（主要用于测试）
  static void reset() {
    _instance = null;
  }

  /// 获取平台信息
  static String get platformName {
    if (kIsWeb) {
      return 'Web';
    } else {
      return 'Native';
    }
  }

  /// 检查是否为Web平台
  static bool get isWeb => kIsWeb;

  /// 检查是否为原生平台
  static bool get isNative => !kIsWeb;
}