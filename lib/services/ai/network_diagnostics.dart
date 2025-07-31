import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class NetworkDiagnostics {
  static const String tag = 'NetworkDiagnostics';
  
  /// 诊断网络连接问题（专为macOS优化）
  static Future<NetworkDiagnosticResult> diagnoseConnection() async {
    final result = NetworkDiagnosticResult();
    
    try {
      developer.log('开始网络诊断...', name: tag);
      
      // 步骤1: 检查基本网络连接
      result.hasInternetAccess = await _checkInternetAccess();
      developer.log('基本网络连接: ${result.hasInternetAccess}', name: tag);
      
      if (!result.hasInternetAccess) {
        result.issues.add('设备无法访问互联网，请检查网络连接');
        return result;
      }
      
      // 步骤2: 检查DNS解析
      result.canResolveBaiduDns = await _checkDnsResolution();
      developer.log('DNS解析状态: ${result.canResolveBaiduDns}', name: tag);
      
      if (!result.canResolveBaiduDns) {
        result.issues.add('DNS解析失败，无法解析aip.baidubce.com');
        result.suggestions.add('尝试更换DNS服务器（如8.8.8.8或114.114.114.114）');
      }
      
      // 步骤3: 检查HTTPS连接
      result.canConnectToApi = await _checkApiConnection();
      developer.log('API连接状态: ${result.canConnectToApi}', name: tag);
      
      if (!result.canConnectToApi) {
        result.issues.add('无法建立HTTPS连接到百度API服务器');
        result.suggestions.add('检查防火墙设置是否阻止了HTTPS连接');
        result.suggestions.add('如使用代理或VPN，请确保配置正确');
      }
      
      // 步骤4: 检查地理位置访问
      result.geographicRestriction = await _checkGeographicAccess();
      developer.log('地理位置限制: ${result.geographicRestriction}', name: tag);
      
      if (result.geographicRestriction) {
        result.issues.add('可能受到地理位置限制');
        result.suggestions.add('确认当前网络位置是否支持访问百度API');
      }
      
      // 步骤5: macOS特定检查
      await _checkMacOSSpecific(result);
      
      result.overallStatus = _calculateOverallStatus(result);
      
    } catch (e) {
      developer.log('网络诊断异常: $e', name: tag);
      result.issues.add('网络诊断过程中发生错误: $e');
    }
    
    return result;
  }
  
  static Future<bool> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      try {
        // 备用测试：使用国内可访问的服务器
        final result = await InternetAddress.lookup('www.baidu.com');
        return result.isNotEmpty;
      } catch (e) {
        return false;
      }
    }
  }
  
  static Future<bool> _checkDnsResolution() async {
    try {
      final result = await InternetAddress.lookup('aip.baidubce.com');
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> _checkApiConnection() async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      
      final response = await dio.get(
        'https://aip.baidubce.com/',
        options: Options(
          validateStatus: (status) => true, // 接受所有状态码
        ),
      );
      
      // 只要能收到响应就说明连接正常
      return response.statusCode != null;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> _checkGeographicAccess() async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 8);
      
      final response = await dio.post(
        'https://aip.baidubce.com/oauth/2.0/token',
        data: {
          'grant_type': 'client_credentials',
          'client_id': 'test',
          'client_secret': 'test',
        },
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
      
      // 如果返回403或其他地理限制错误
      if (response.statusCode == 403) {
        final data = response.data;
        if (data is Map && data.containsKey('error_description')) {
          final description = data['error_description'].toString().toLowerCase();
          return description.contains('region') || 
                 description.contains('country') || 
                 description.contains('location');
        }
      }
      
      return false; // 没有地理限制
    } catch (e) {
      return false; // 无法确定，假设没有限制
    }
  }
  
  static Future<void> _checkMacOSSpecific(NetworkDiagnosticResult result) async {
    // 检查macOS防火墙
    try {
      final firewallResult = await Process.run('sudo', ['-n', 'pfctl', '-s', 'info']);
      if (firewallResult.exitCode == 0) {
        result.suggestions.add('macOS防火墙可能影响网络连接，请检查应用程序的网络权限');
      }
    } catch (e) {
      // 无法检查防火墙状态
    }
    
    // 检查网络代理设置
    try {
      final proxyResult = await Process.run('scutil', ['--proxy']);
      if (proxyResult.exitCode == 0 && proxyResult.stdout.toString().contains('HTTPProxy')) {
        result.suggestions.add('检测到系统代理设置，请确认代理配置是否正确');
      }
    } catch (e) {
      // 无法检查代理设置
    }
  }
  
  static NetworkStatus _calculateOverallStatus(NetworkDiagnosticResult result) {
    if (result.hasInternetAccess && result.canResolveBaiduDns && result.canConnectToApi) {
      return NetworkStatus.good;
    } else if (result.hasInternetAccess && result.canResolveBaiduDns) {
      return NetworkStatus.limited;
    } else if (result.hasInternetAccess) {
      return NetworkStatus.poor;
    } else {
      return NetworkStatus.disconnected;
    }
  }
}

class NetworkDiagnosticResult {
  bool hasInternetAccess = false;
  bool canResolveBaiduDns = false;
  bool canConnectToApi = false;
  bool geographicRestriction = false;
  NetworkStatus overallStatus = NetworkStatus.disconnected;
  List<String> issues = [];
  List<String> suggestions = [];
  
  String getStatusDescription() {
    switch (overallStatus) {
      case NetworkStatus.good:
        return '网络连接正常，可以正常使用百度API';
      case NetworkStatus.limited:
        return '网络连接受限，可能影响API使用';
      case NetworkStatus.poor:
        return '网络连接质量较差，建议检查网络设置';
      case NetworkStatus.disconnected:
        return '网络连接断开，无法访问互联网';
    }
  }
  
  List<String> getAllSuggestions() {
    final allSuggestions = List<String>.from(suggestions);
    
    if (!hasInternetAccess) {
      allSuggestions.addAll([
        '检查Wi-Fi或以太网连接',
        '重启网络适配器',
        '联系网络管理员',
      ]);
    }
    
    if (!canResolveBaiduDns) {
      allSuggestions.addAll([
        '尝试刷新DNS缓存：sudo dscacheutil -flushcache',
        '更换DNS服务器为8.8.8.8或114.114.114.114',
      ]);
    }
    
    if (!canConnectToApi) {
      allSuggestions.addAll([
        '检查防火墙是否阻止了应用程序的网络访问',
        '暂时关闭VPN或代理软件进行测试',
        '确认系统时间和时区设置正确',
      ]);
    }
    
    return allSuggestions;
  }
}

enum NetworkStatus {
  good,
  limited,
  poor,
  disconnected,
}