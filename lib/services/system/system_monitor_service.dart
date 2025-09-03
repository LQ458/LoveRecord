import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';

/// Privacy levels for different monitoring features
enum PrivacyLevel {
  off,        // No monitoring
  minimal,    // Basic status only
  standard,   // Regular updates
  detailed,   // Full monitoring
}

/// Apple-style system monitoring service
/// Monitors battery, location, app usage with privacy controls
class SystemMonitorService {
  static const MethodChannel _channel = MethodChannel('com.loverecord.system_monitor');
  static const EventChannel _batteryChannel = EventChannel('com.loverecord.battery_stream');
  static const EventChannel _locationChannel = EventChannel('com.loverecord.location_stream');
  static const EventChannel _activityChannel = EventChannel('com.loverecord.activity_stream');

  // Stream controllers for real-time data
  static StreamController<BatteryStatus>? _batteryController;
  static StreamController<LocationUpdate>? _locationController;
  static StreamController<ActivityUpdate>? _activityController;

  /// Initialize system monitoring with privacy preferences
  static Future<void> initialize({
    PrivacyLevel batteryMonitoring = PrivacyLevel.standard,
    PrivacyLevel locationMonitoring = PrivacyLevel.minimal,
    PrivacyLevel activityMonitoring = PrivacyLevel.off,
  }) async {
    try {
      await _channel.invokeMethod('initialize', {
        'batteryMonitoring': batteryMonitoring.name,
        'locationMonitoring': locationMonitoring.name,
        'activityMonitoring': activityMonitoring.name,
      });
      
      // Set up stream listeners
      _setupStreamListeners();
    } on PlatformException catch (e) {
      print('Failed to initialize system monitoring: ${e.message}');
    }
  }

  /// Set up stream listeners for real-time updates
  static void _setupStreamListeners() {
    _batteryController = StreamController<BatteryStatus>.broadcast();
    _locationController = StreamController<LocationUpdate>.broadcast();
    _activityController = StreamController<ActivityUpdate>.broadcast();
    
    // Battery status stream
    _batteryChannel.receiveBroadcastStream().listen((data) {
      final batteryStatus = BatteryStatus.fromJson(jsonDecode(data));
      _batteryController?.add(batteryStatus);
    });
    
    // Location updates stream
    _locationChannel.receiveBroadcastStream().listen((data) {
      final locationUpdate = LocationUpdate.fromJson(jsonDecode(data));
      _locationController?.add(locationUpdate);
    });
    
    // Activity/App usage stream
    _activityChannel.receiveBroadcastStream().listen((data) {
      final activityUpdate = ActivityUpdate.fromJson(jsonDecode(data));
      _activityController?.add(activityUpdate);
    });
  }

  /// Get current battery status
  static Future<BatteryStatus?> getBatteryStatus() async {
    try {
      final result = await _channel.invokeMethod('getBatteryStatus');
      return result != null ? BatteryStatus.fromJson(jsonDecode(result)) : null;
    } on PlatformException catch (e) {
      print('Failed to get battery status: ${e.message}');
      return null;
    }
  }

  /// Stream of battery status updates
  static Stream<BatteryStatus> get batteryStream {
    return _batteryController?.stream ?? const Stream.empty();
  }

  /// Get current location with privacy controls
  static Future<LocationUpdate?> getCurrentLocation({
    bool highAccuracy = false,
    bool shareWithPartner = true,
  }) async {
    try {
      final result = await _channel.invokeMethod('getCurrentLocation', {
        'highAccuracy': highAccuracy,
        'shareWithPartner': shareWithPartner,
      });
      return result != null ? LocationUpdate.fromJson(jsonDecode(result)) : null;
    } on PlatformException catch (e) {
      print('Failed to get current location: ${e.message}');
      return null;
    }
  }

  /// Stream of location updates
  static Stream<LocationUpdate> get locationStream {
    return _locationController?.stream ?? const Stream.empty();
  }

  /// Get current app usage/activity
  static Future<ActivityUpdate?> getCurrentActivity() async {
    try {
      final result = await _channel.invokeMethod('getCurrentActivity');
      return result != null ? ActivityUpdate.fromJson(jsonDecode(result)) : null;
    } on PlatformException catch (e) {
      print('Failed to get current activity: ${e.message}');
      return null;
    }
  }

  /// Stream of activity updates
  static Stream<ActivityUpdate> get activityStream {
    return _activityController?.stream ?? const Stream.empty();
  }

  /// Share status with partner (Apple-style sharing)
  static Future<void> shareStatusWithPartner({
    bool includeBattery = true,
    bool includeLocation = false,
    bool includeActivity = false,
    Duration? duration, // Temporary sharing duration
  }) async {
    try {
      await _channel.invokeMethod('shareStatusWithPartner', {
        'includeBattery': includeBattery,
        'includeLocation': includeLocation,
        'includeActivity': includeActivity,
        'duration': duration?.inMinutes,
      });
    } on PlatformException catch (e) {
      print('Failed to share status with partner: ${e.message}');
    }
  }

  /// Stop sharing status with partner
  static Future<void> stopSharingStatus() async {
    try {
      await _channel.invokeMethod('stopSharingStatus');
    } on PlatformException catch (e) {
      print('Failed to stop sharing status: ${e.message}');
    }
  }

  /// Set focus mode (Do Not Disturb integration)
  static Future<void> setFocusMode({
    required String modeName,
    Duration? duration,
    bool notifyPartner = true,
  }) async {
    try {
      await _channel.invokeMethod('setFocusMode', {
        'modeName': modeName,
        'duration': duration?.inMinutes,
        'notifyPartner': notifyPartner,
      });
    } on PlatformException catch (e) {
      print('Failed to set focus mode: ${e.message}');
    }
  }

  /// Get device health metrics
  static Future<DeviceHealth?> getDeviceHealth() async {
    try {
      final result = await _channel.invokeMethod('getDeviceHealth');
      return result != null ? DeviceHealth.fromJson(jsonDecode(result)) : null;
    } on PlatformException catch (e) {
      print('Failed to get device health: ${e.message}');
      return null;
    }
  }

  /// Smart notification based on partner's status
  static Future<void> enableSmartNotifications({
    required bool batteryAlerts,    // Alert when partner's battery is low
    required bool locationAlerts,   // Alert when partner arrives/leaves
    required bool activityAlerts,   // Alert on significant activity changes
  }) async {
    try {
      await _channel.invokeMethod('enableSmartNotifications', {
        'batteryAlerts': batteryAlerts,
        'locationAlerts': locationAlerts,
        'activityAlerts': activityAlerts,
      });
    } on PlatformException catch (e) {
      print('Failed to enable smart notifications: ${e.message}');
    }
  }

  /// Emergency sharing (auto-share critical info during emergencies)
  static Future<void> enableEmergencySharing({
    required bool enabled,
    required String emergencyContactNumber,
  }) async {
    try {
      await _channel.invokeMethod('enableEmergencySharing', {
        'enabled': enabled,
        'emergencyContactNumber': emergencyContactNumber,
      });
    } on PlatformException catch (e) {
      print('Failed to enable emergency sharing: ${e.message}');
    }
  }

  /// Dispose of resources
  static void dispose() {
    _batteryController?.close();
    _locationController?.close();
    _activityController?.close();
  }
}

/// Data models for system monitoring
class BatteryStatus {
  final int level;           // 0-100
  final bool isCharging;
  final bool isLowPowerMode;
  final int? estimatedMinutesRemaining;
  final DateTime timestamp;
  final String deviceName;

  const BatteryStatus({
    required this.level,
    required this.isCharging,
    required this.isLowPowerMode,
    this.estimatedMinutesRemaining,
    required this.timestamp,
    required this.deviceName,
  });

  factory BatteryStatus.fromJson(Map<String, dynamic> json) {
    return BatteryStatus(
      level: json['level'],
      isCharging: json['isCharging'],
      isLowPowerMode: json['isLowPowerMode'] ?? false,
      estimatedMinutesRemaining: json['estimatedMinutesRemaining'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      deviceName: json['deviceName'] ?? 'Unknown Device',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'isCharging': isCharging,
      'isLowPowerMode': isLowPowerMode,
      'estimatedMinutesRemaining': estimatedMinutesRemaining,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'deviceName': deviceName,
    };
  }

  /// Check if battery needs attention
  bool get needsAttention => level <= 20 && !isCharging;

  /// Get user-friendly status message
  String get statusMessage {
    if (isCharging) {
      return 'Charging ${level}%';
    } else if (isLowPowerMode) {
      return '${level}% (Low Power Mode)';
    } else if (level <= 10) {
      return '${level}% - Critically Low!';
    } else if (level <= 20) {
      return '${level}% - Low Battery';
    } else {
      return '${level}%';
    }
  }
}

class LocationUpdate {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double accuracy;        // in meters
  final double? speed;          // m/s
  final String? address;        // Reverse geocoded address
  final String? locationName;   // e.g., "Home", "Work", "Starbucks"
  final DateTime timestamp;
  final bool isSignificantChange; // Major location change vs minor update

  const LocationUpdate({
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.accuracy,
    this.speed,
    this.address,
    this.locationName,
    required this.timestamp,
    required this.isSignificantChange,
  });

  factory LocationUpdate.fromJson(Map<String, dynamic> json) {
    return LocationUpdate(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      altitude: json['altitude']?.toDouble(),
      accuracy: json['accuracy'].toDouble(),
      speed: json['speed']?.toDouble(),
      address: json['address'],
      locationName: json['locationName'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      isSignificantChange: json['isSignificantChange'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'speed': speed,
      'address': address,
      'locationName': locationName,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isSignificantChange': isSignificantChange,
    };
  }

  /// Get display name for location
  String get displayName => locationName ?? address ?? 'Unknown Location';
}

class ActivityUpdate {
  final String currentApp;           // Currently active app
  final String activityType;         // e.g., "working", "entertainment", "communication"
  final DateTime startTime;
  final Duration duration;           // How long in this activity
  final int screenUnlocks;          // Today's screen unlocks
  final Duration totalScreenTime;   // Today's total screen time
  final bool isIdle;               // Device is idle/locked
  final String focusMode;          // Current focus mode (if any)
  final DateTime timestamp;

  const ActivityUpdate({
    required this.currentApp,
    required this.activityType,
    required this.startTime,
    required this.duration,
    required this.screenUnlocks,
    required this.totalScreenTime,
    required this.isIdle,
    required this.focusMode,
    required this.timestamp,
  });

  factory ActivityUpdate.fromJson(Map<String, dynamic> json) {
    return ActivityUpdate(
      currentApp: json['currentApp'] ?? 'Unknown',
      activityType: json['activityType'] ?? 'unknown',
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
      duration: Duration(milliseconds: json['duration']),
      screenUnlocks: json['screenUnlocks'] ?? 0,
      totalScreenTime: Duration(milliseconds: json['totalScreenTime']),
      isIdle: json['isIdle'] ?? false,
      focusMode: json['focusMode'] ?? 'none',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }

  /// Get user-friendly activity description
  String get activityDescription {
    if (isIdle) return 'Device is idle';
    if (focusMode != 'none') return 'In $focusMode mode';
    return 'Using $currentApp';
  }
}

class DeviceHealth {
  final BatteryStatus battery;
  final String deviceModel;
  final String osVersion;
  final double availableStorage; // GB
  final double totalStorage;     // GB
  final int memoryUsage;        // Percentage
  final bool isDeviceSecure;    // Screen lock enabled
  final DateTime lastUpdated;

  const DeviceHealth({
    required this.battery,
    required this.deviceModel,
    required this.osVersion,
    required this.availableStorage,
    required this.totalStorage,
    required this.memoryUsage,
    required this.isDeviceSecure,
    required this.lastUpdated,
  });

  factory DeviceHealth.fromJson(Map<String, dynamic> json) {
    return DeviceHealth(
      battery: BatteryStatus.fromJson(json['battery']),
      deviceModel: json['deviceModel'],
      osVersion: json['osVersion'],
      availableStorage: json['availableStorage'].toDouble(),
      totalStorage: json['totalStorage'].toDouble(),
      memoryUsage: json['memoryUsage'],
      isDeviceSecure: json['isDeviceSecure'],
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated']),
    );
  }

  /// Check if device needs attention
  bool get needsAttention {
    return battery.needsAttention || 
           availableStorage < 1.0 ||  // Less than 1GB free
           memoryUsage > 90;          // Over 90% memory usage
  }

  /// Storage usage percentage
  double get storageUsagePercentage {
    return ((totalStorage - availableStorage) / totalStorage) * 100;
  }
}