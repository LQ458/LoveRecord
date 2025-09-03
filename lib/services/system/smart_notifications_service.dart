import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:async';
import 'system_monitor_service.dart';
import 'calendar_service.dart';

/// Notification categories with different priorities and behaviors
enum NotificationCategory {
  urgent,        // Critical notifications (emergency, low battery)
  important,     // High priority (anniversaries, date reminders)
  social,        // Social interactions (love notes, mood updates)
  informational, // General updates (activity status, weather)
  promotional,   // Suggestions and tips
}

/// Smart notification triggers based on context
enum SmartTrigger {
  batteryLow,           // Partner's battery is low
  arrivedHome,          // Partner arrived home
  leftWork,             // Partner left work
  longTimeNoContact,    // Haven't communicated in a while
  anniversaryApproaching, // Anniversary coming up
  moodChange,           // Significant mood change detected
  locationNearby,       // Near partner's favorite place
  workHoursEnding,      // Work day ending
  bedtimeReminder,      // Time for goodnight message
  weatherAlert,         // Weather might affect plans
}

/// Apple-style intelligent notification system with context awareness
/// Learns from user behavior and provides smart, timely notifications
class SmartNotificationsService {
  static const MethodChannel _channel = MethodChannel('com.loverecord.smart_notifications');
  static late FlutterLocalNotificationsPlugin _localNotifications;
  
  static bool _isInitialized = false;
  static Timer? _contextMonitoringTimer;

  /// Initialize smart notifications system
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      _localNotifications = FlutterLocalNotificationsPlugin();
      
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const macosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      await _localNotifications.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
          macOS: macosSettings,
        ),
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      // Request permissions
      await _requestPermissions();
      
      // Initialize platform-specific smart features
      await _channel.invokeMethod('initialize');
      
      // Start context monitoring
      _startContextMonitoring();
      
      _isInitialized = true;
    } on PlatformException catch (e) {
      print('Failed to initialize smart notifications: ${e.message}');
    }
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Start monitoring context for smart notifications
  static void _startContextMonitoring() {
    _contextMonitoringTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _checkSmartTriggers(),
    );
  }

  /// Check for smart notification triggers
  static Future<void> _checkSmartTriggers() async {
    try {
      // Monitor partner's battery status
      final batteryStatus = await SystemMonitorService.getBatteryStatus();
      if (batteryStatus != null && batteryStatus.needsAttention) {
        await triggerSmartNotification(
          SmartTrigger.batteryLow,
          data: {'batteryLevel': batteryStatus.level},
        );
      }

      // Monitor location changes
      final locationUpdate = await SystemMonitorService.getCurrentLocation();
      if (locationUpdate != null && locationUpdate.isSignificantChange) {
        await _processLocationUpdate(locationUpdate);
      }

      // Check upcoming anniversaries
      await _checkAnniversaries();
      
      // Check communication patterns
      await _checkCommunicationGaps();
      
      // Check work schedule context
      await _checkWorkScheduleContext();
      
    } catch (e) {
      print('Error checking smart triggers: $e');
    }
  }

  /// Process location updates for smart notifications
  static Future<void> _processLocationUpdate(LocationUpdate location) async {
    try {
      final result = await _channel.invokeMethod('processLocationUpdate', {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'address': location.address,
        'locationName': location.locationName,
        'timestamp': location.timestamp.millisecondsSinceEpoch,
      });

      if (result['triggerNotification'] == true) {
        final trigger = SmartTrigger.values.firstWhere(
          (t) => t.name == result['trigger'],
          orElse: () => SmartTrigger.locationNearby,
        );
        
        await triggerSmartNotification(trigger, data: result['data']);
      }
    } catch (e) {
      print('Error processing location update: $e');
    }
  }

  /// Check for upcoming anniversaries
  static Future<void> _checkAnniversaries() async {
    try {
      final upcomingEvents = await CalendarService.getCoupleEvents(
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        eventType: CoupleEventType.anniversary,
      );

      for (final event in upcomingEvents) {
        final daysUntil = event.startDate.difference(DateTime.now()).inDays;
        
        if (daysUntil <= 3 && daysUntil > 0) {
          await triggerSmartNotification(
            SmartTrigger.anniversaryApproaching,
            data: {
              'eventTitle': event.title,
              'daysUntil': daysUntil,
              'eventDate': event.startDate.toIso8601String(),
            },
          );
        }
      }
    } catch (e) {
      print('Error checking anniversaries: $e');
    }
  }

  /// Check for communication gaps
  static Future<void> _checkCommunicationGaps() async {
    try {
      final result = await _channel.invokeMethod('checkCommunicationGaps');
      
      if (result['hasGap'] == true) {
        final hoursSinceLastContact = result['hoursSinceLastContact'] as int;
        
        if (hoursSinceLastContact >= 6) { // 6 hours without contact
          await triggerSmartNotification(
            SmartTrigger.longTimeNoContact,
            data: {'hoursSinceLastContact': hoursSinceLastContact},
          );
        }
      }
    } catch (e) {
      print('Error checking communication gaps: $e');
    }
  }

  /// Check work schedule context
  static Future<void> _checkWorkScheduleContext() async {
    try {
      final now = DateTime.now();
      final hour = now.hour;
      
      // Check if it's near end of work day (5-7 PM)
      if (hour >= 17 && hour <= 19) {
        await triggerSmartNotification(
          SmartTrigger.workHoursEnding,
          data: {'currentHour': hour},
        );
      }
      
      // Check if it's bedtime (9-11 PM)
      if (hour >= 21 && hour <= 23) {
        await triggerSmartNotification(
          SmartTrigger.bedtimeReminder,
          data: {'currentHour': hour},
        );
      }
    } catch (e) {
      print('Error checking work schedule context: $e');
    }
  }

  /// Trigger a smart notification based on context
  static Future<void> triggerSmartNotification(
    SmartTrigger trigger, {
    Map<String, dynamic>? data,
  }) async {
    try {
      // Check if we should actually send this notification
      final shouldSend = await _shouldSendNotification(trigger, data);
      if (!shouldSend) return;

      final notification = await _buildSmartNotification(trigger, data);
      await _sendNotification(notification);
      
      // Learn from this notification for future improvements
      await _recordNotificationSent(trigger, data);
      
    } catch (e) {
      print('Error triggering smart notification: $e');
    }
  }

  /// Determine if a notification should be sent based on context
  static Future<bool> _shouldSendNotification(
    SmartTrigger trigger,
    Map<String, dynamic>? data,
  ) async {
    try {
      final result = await _channel.invokeMethod('shouldSendNotification', {
        'trigger': trigger.name,
        'data': data != null ? jsonEncode(data) : null,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      return result == true;
    } catch (e) {
      print('Error checking if should send notification: $e');
      return false; // Default to not sending if unsure
    }
  }

  /// Build notification content based on trigger and context
  static Future<SmartNotification> _buildSmartNotification(
    SmartTrigger trigger,
    Map<String, dynamic>? data,
  ) async {
    switch (trigger) {
      case SmartTrigger.batteryLow:
        final batteryLevel = data?['batteryLevel'] ?? 0;
        return SmartNotification(
          id: trigger.hashCode,
          title: '🔋 Partner\'s Battery Low',
          body: 'Your partner\'s battery is at $batteryLevel%. Maybe check in on them?',
          category: NotificationCategory.important,
          actions: [
            NotificationAction(id: 'send_message', title: 'Send Message'),
            NotificationAction(id: 'ignore', title: 'Not Now'),
          ],
        );

      case SmartTrigger.arrivedHome:
        return SmartNotification(
          id: trigger.hashCode,
          title: '🏠 Welcome Home!',
          body: 'Your partner just arrived home. Perfect time to connect!',
          category: NotificationCategory.social,
          actions: [
            NotificationAction(id: 'call_partner', title: 'Call'),
            NotificationAction(id: 'send_love_note', title: 'Send Love Note'),
          ],
        );

      case SmartTrigger.anniversaryApproaching:
        final eventTitle = data?['eventTitle'] ?? 'Anniversary';
        final daysUntil = data?['daysUntil'] ?? 0;
        return SmartNotification(
          id: trigger.hashCode,
          title: '💕 ${eventTitle} Approaching',
          body: 'Your $eventTitle is in $daysUntil days. Start planning something special!',
          category: NotificationCategory.important,
          actions: [
            NotificationAction(id: 'plan_celebration', title: 'Plan Celebration'),
            NotificationAction(id: 'set_reminder', title: 'Remind Me Later'),
          ],
        );

      case SmartTrigger.longTimeNoContact:
        final hours = data?['hoursSinceLastContact'] ?? 0;
        return SmartNotification(
          id: trigger.hashCode,
          title: '💭 Missing Your Partner?',
          body: 'It\'s been $hours hours since you last connected. Send them some love!',
          category: NotificationCategory.social,
          actions: [
            NotificationAction(id: 'send_message', title: 'Send Message'),
            NotificationAction(id: 'schedule_call', title: 'Schedule Call'),
          ],
        );

      case SmartTrigger.workHoursEnding:
        return SmartNotification(
          id: trigger.hashCode,
          title: '⏰ Work Day Ending',
          body: 'Time to transition from work mode! How about connecting with your partner?',
          category: NotificationCategory.informational,
          actions: [
            NotificationAction(id: 'send_update', title: 'Share Day Update'),
            NotificationAction(id: 'plan_evening', title: 'Plan Evening'),
          ],
        );

      case SmartTrigger.bedtimeReminder:
        return SmartNotification(
          id: trigger.hashCode,
          title: '🌙 Goodnight Time',
          body: 'Don\'t forget to send your partner a goodnight message!',
          category: NotificationCategory.informational,
          actions: [
            NotificationAction(id: 'send_goodnight', title: 'Send Goodnight'),
            NotificationAction(id: 'not_tonight', title: 'Not Tonight'),
          ],
        );

      default:
        return SmartNotification(
          id: trigger.hashCode,
          title: '💕 Love Reminder',
          body: 'Take a moment to connect with your partner today!',
          category: NotificationCategory.informational,
        );
    }
  }

  /// Send the notification to the system
  static Future<void> _sendNotification(SmartNotification notification) async {
    try {
      await _localNotifications.show(
        notification.id,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            notification.category.name,
            notification.category.name,
            channelDescription: 'Smart couple notifications',
            importance: _getAndroidImportance(notification.category),
            priority: _getAndroidPriority(notification.category),
            actions: notification.actions?.map((action) => 
              AndroidNotificationAction(
                action.id,
                action.title,
              ),
            ).toList(),
          ),
          iOS: DarwinNotificationDetails(
            categoryIdentifier: notification.category.name,
          ),
        ),
        payload: jsonEncode(notification.toJson()),
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// Handle notification response
  static void _handleNotificationResponse(NotificationResponse response) async {
    try {
      final payload = response.payload;
      if (payload != null) {
        final notificationData = jsonDecode(payload) as Map<String, dynamic>;
        
        // Handle different action types
        if (response.actionId != null) {
          await _handleNotificationAction(response.actionId!, notificationData);
        } else {
          // Handle notification tap
          await _handleNotificationTap(notificationData);
        }
      }
    } catch (e) {
      print('Error handling notification response: $e');
    }
  }

  /// Handle notification action button press
  static Future<void> _handleNotificationAction(
    String actionId,
    Map<String, dynamic> notificationData,
  ) async {
    try {
      await _channel.invokeMethod('handleNotificationAction', {
        'actionId': actionId,
        'notificationData': jsonEncode(notificationData),
      });
    } catch (e) {
      print('Error handling notification action: $e');
    }
  }

  /// Handle notification tap
  static Future<void> _handleNotificationTap(Map<String, dynamic> notificationData) async {
    try {
      await _channel.invokeMethod('handleNotificationTap', {
        'notificationData': jsonEncode(notificationData),
      });
    } catch (e) {
      print('Error handling notification tap: $e');
    }
  }

  /// Record that a notification was sent for learning purposes
  static Future<void> _recordNotificationSent(
    SmartTrigger trigger,
    Map<String, dynamic>? data,
  ) async {
    try {
      await _channel.invokeMethod('recordNotificationSent', {
        'trigger': trigger.name,
        'data': data != null ? jsonEncode(data) : null,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error recording notification sent: $e');
    }
  }

  /// Get Android importance level from category
  static Importance _getAndroidImportance(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.urgent:
        return Importance.max;
      case NotificationCategory.important:
        return Importance.high;
      case NotificationCategory.social:
        return Importance.defaultImportance;
      case NotificationCategory.informational:
        return Importance.low;
      case NotificationCategory.promotional:
        return Importance.min;
    }
  }

  /// Get Android priority from category
  static Priority _getAndroidPriority(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.urgent:
        return Priority.max;
      case NotificationCategory.important:
        return Priority.high;
      case NotificationCategory.social:
        return Priority.defaultPriority;
      case NotificationCategory.informational:
        return Priority.low;
      case NotificationCategory.promotional:
        return Priority.min;
    }
  }

  /// Dispose of resources
  static void dispose() {
    _contextMonitoringTimer?.cancel();
  }
}

/// Smart notification data model
class SmartNotification {
  final int id;
  final String title;
  final String body;
  final NotificationCategory category;
  final List<NotificationAction>? actions;
  final Map<String, dynamic>? data;

  const SmartNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.actions,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': category.name,
      'actions': actions?.map((a) => a.toJson()).toList(),
      'data': data,
    };
  }
}

/// Notification action button
class NotificationAction {
  final String id;
  final String title;

  const NotificationAction({
    required this.id,
    required this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}