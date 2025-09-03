import 'package:flutter/foundation.dart';
import 'widget_service.dart';
import 'calendar_service.dart';
import 'system_monitor_service.dart';
import 'siri_shortcuts_service.dart';
import 'smart_notifications_service.dart';
import '../../data/local/database_service.dart';
import '../../data/models/record.dart';
import 'dart:async';

/// Apple-style system integration manager
/// Orchestrates all system integrations for seamless user experience
class SystemIntegrationManager {
  static bool _isInitialized = false;
  static Timer? _periodicUpdateTimer;
  static StreamSubscription? _batterySubscription;
  static StreamSubscription? _locationSubscription;
  static StreamSubscription? _activitySubscription;

  /// Initialize all system integrations
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🚀 Initializing Apple-style System Integration...');

      // Initialize all services in parallel for better performance
      // Handle platform channel errors gracefully for services not yet implemented natively
      final results = await Future.wait([
        WidgetService.initialize().catchError((e) {
          debugPrint('⚠️ Widget service not implemented natively yet: $e');
          return;
        }),
        CalendarService.requestCalendarAccess().catchError((e) {
          debugPrint('⚠️ Calendar service not implemented natively yet: $e');
          return CalendarAccess.none;
        }),
        SystemMonitorService.initialize().catchError((e) {
          debugPrint('⚠️ System monitor service not implemented natively yet: $e');
          return;
        }),
        SiriShortcutsService.initialize().catchError((e) {
          debugPrint('⚠️ Siri shortcuts service not implemented natively yet: $e');
          return;
        }),
        SmartNotificationsService.initialize().catchError((e) {
          debugPrint('⚠️ Smart notifications service partially initialized: $e');
          return;
        }),
      ], eagerError: false);

      // Set up real-time data streams (with error handling)
      _setupDataStreams();

      // Start periodic widget updates (with error handling)  
      _startPeriodicUpdates();

      _isInitialized = true;
      debugPrint('✅ System Integration Architecture Initialized');
      debugPrint('ℹ️ Note: Native platform implementations pending for full functionality');

      // Update widgets immediately (with error handling)
      await updateAllWidgets();

    } catch (e) {
      debugPrint('❌ Failed to initialize system integration: $e');
      debugPrint('ℹ️ App will continue with basic functionality');
    }
  }

  /// Set up real-time data streams for reactive updates
  static void _setupDataStreams() {
    try {
      // Battery status stream
      _batterySubscription = SystemMonitorService.batteryStream.listen(
        (battery) => _onBatteryStatusChanged(battery),
        onError: (e) => debugPrint('Battery stream error: $e'),
      );

      // Location updates stream
      _locationSubscription = SystemMonitorService.locationStream.listen(
        (location) => _onLocationChanged(location),
        onError: (e) => debugPrint('Location stream error: $e'),
      );

      // Activity updates stream
      _activitySubscription = SystemMonitorService.activityStream.listen(
        (activity) => _onActivityChanged(activity),
        onError: (e) => debugPrint('Activity stream error: $e'),
      );
    } catch (e) {
      debugPrint('Error setting up data streams: $e');
    }
  }

  /// Start periodic updates for widgets and system sync
  static void _startPeriodicUpdates() {
    _periodicUpdateTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _performPeriodicUpdate(),
    );
  }

  /// Handle battery status changes
  static void _onBatteryStatusChanged(BatteryStatus battery) async {
    debugPrint('🔋 Battery status changed: ${battery.level}%');

    // Update partner status widget
    await _updatePartnerStatusWidget();

    // Donate Siri activity for suggestions
    if (battery.needsAttention) {
      await SiriShortcutsService.donateShortcutActivity(
        identifier: 'check_partner_status',
        title: 'Check Partner Battery',
        parameters: {'reason': 'low_battery'},
      );
    }
  }

  /// Handle location changes
  static void _onLocationChanged(LocationUpdate location) async {
    debugPrint('📍 Location changed: ${location.displayName}');

    // Update widgets with new location
    await _updatePartnerStatusWidget();

    // Sync with calendar for location-based events
    await _syncLocationWithCalendar(location);

    // Donate Siri activity
    await SiriShortcutsService.donateShortcutActivity(
      identifier: 'send_love_note',
      title: 'Send Location Update',
      parameters: {
        'location': location.locationName,
        'includeLocation': true,
      },
    );
  }

  /// Handle activity changes
  static void _onActivityChanged(ActivityUpdate activity) async {
    debugPrint('📱 Activity changed: ${activity.activityDescription}');

    // Update partner status widget
    await _updatePartnerStatusWidget();

    // Smart notification based on activity
    if (activity.focusMode != 'none') {
      await SmartNotificationsService.triggerSmartNotification(
        SmartTrigger.workHoursEnding,
        data: {'focusMode': activity.focusMode},
      );
    }
  }

  /// Perform periodic system updates
  static Future<void> _performPeriodicUpdate() async {
    try {
      debugPrint('🔄 Performing periodic system update...');

      await Future.wait([
        _updateAllWidgets(),
        _syncTodosWithCalendar(),
        _updateShortcutSuggestions(),
        _cleanupOldNotifications(),
      ]);

    } catch (e) {
      debugPrint('Error in periodic update: $e');
    }
  }

  /// Update all home screen widgets
  static Future<void> updateAllWidgets() async {
    await _updateAllWidgets();
  }

  static Future<void> _updateAllWidgets() async {
    try {
      await Future.wait([
        _updatePartnerStatusWidget(),
        _updateSharedTodosWidget(),
        _updateDaysCounterWidget(),
        _updateQuickLoveNoteWidget(),
      ]);
    } catch (e) {
      debugPrint('Error updating widgets: $e');
    }
  }

  /// Update partner status widget
  static Future<void> _updatePartnerStatusWidget() async {
    try {
      final batteryStatus = await SystemMonitorService.getBatteryStatus();
      final activityUpdate = await SystemMonitorService.getCurrentActivity();
      final locationUpdate = await SystemMonitorService.getCurrentLocation();

      if (batteryStatus != null) {
        final partnerStatus = PartnerStatusWidget(
          partnerName: 'Partner', // Get from settings
          mood: 'happy', // Get from mood tracking
          batteryLevel: batteryStatus.level,
          currentActivity: activityUpdate?.activityDescription ?? 'Unknown',
          location: locationUpdate?.displayName ?? 'Unknown',
          lastSeen: DateTime.now(),
        );

        await WidgetService.updateWidget(
          type: WidgetType.partnerStatus,
          size: WidgetSize.small,
          data: partnerStatus.toJson(),
        );
      }
    } catch (e) {
      debugPrint('Error updating partner status widget: $e');
    }
  }

  /// Update shared todos widget
  static Future<void> _updateSharedTodosWidget() async {
    try {
      final databaseService = DatabaseService();
      final records = await databaseService.getRecords(limit: 10);
      
      // Convert records to todos (simplified example)
      final todos = records.map((record) => TodoItem(
        id: record.id,
        title: record.title,
        isCompleted: false, // Implement todo completion tracking
        priority: 'medium',
      )).take(5).toList();

      final sharedTodos = SharedTodosWidget(
        todos: todos,
        completedToday: 2, // Calculate from database
        totalCount: todos.length,
      );

      await WidgetService.updateWidget(
        type: WidgetType.sharedTodos,
        size: WidgetSize.medium,
        data: sharedTodos.toJson(),
      );
    } catch (e) {
      debugPrint('Error updating shared todos widget: $e');
    }
  }

  /// Update days counter widget
  static Future<void> _updateDaysCounterWidget() async {
    try {
      // Calculate days since relationship started (get from settings)
      final relationshipStartDate = DateTime(2024, 1, 1); // Example date
      final daysSince = DateTime.now().difference(relationshipStartDate).inDays;

      final daysCounter = DaysCounterWidget(
        milestone: 'Together',
        daysSince: daysSince,
        description: 'Days of love and happiness',
        startDate: relationshipStartDate,
      );

      await WidgetService.updateWidget(
        type: WidgetType.daysCounter,
        size: WidgetSize.small,
        data: daysCounter.toJson(),
      );
    } catch (e) {
      debugPrint('Error updating days counter widget: $e');
    }
  }

  /// Update quick love note widget
  static Future<void> _updateQuickLoveNoteWidget() async {
    try {
      final quickLoveNote = QuickLoveNoteWidget(
        quickMessages: [
          'Thinking of you ❤️',
          'Love you!',
          'Hope you\'re having a great day!',
          'Can\'t wait to see you',
          'You\'re amazing',
        ],
        lastSentMessage: 'Good morning beautiful!',
        lastSentTime: DateTime.now().subtract(const Duration(hours: 2)),
      );

      await WidgetService.updateWidget(
        type: WidgetType.quickLoveNote,
        size: WidgetSize.small,
        data: quickLoveNote.toJson(),
      );
    } catch (e) {
      debugPrint('Error updating quick love note widget: $e');
    }
  }

  /// Sync todos with system calendar
  static Future<void> _syncTodosWithCalendar() async {
    try {
      final databaseService = DatabaseService();
      final records = await databaseService.getRecords();
      
      final todoEvents = records
          .where((record) => record.type == RecordType.work) // Filter relevant records
          .map((record) => SharedTodoCalendarEvent(
                todoId: record.id,
                title: record.title,
                dueDate: record.createdAt.add(const Duration(days: 7)), // Example due date
                priority: 'medium',
                createCalendarEvent: true,
              ))
          .toList();

      await CalendarService.syncTodosWithCalendar(todos: todoEvents);
    } catch (e) {
      debugPrint('Error syncing todos with calendar: $e');
    }
  }

  /// Sync location with calendar for location-based reminders
  static Future<void> _syncLocationWithCalendar(LocationUpdate location) async {
    try {
      // Check for upcoming events near current location
      final upcomingEvents = await CalendarService.getCoupleEvents(
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );

      for (final event in upcomingEvents) {
        if (event.location != null && event.location!.isNotEmpty) {
          // Check if current location is near event location
          // This would require geocoding implementation
          debugPrint('Checking proximity to event: ${event.title} at ${event.location}');
        }
      }
    } catch (e) {
      debugPrint('Error syncing location with calendar: $e');
    }
  }

  /// Update Siri shortcut suggestions based on usage patterns
  static Future<void> _updateShortcutSuggestions() async {
    try {
      await SiriShortcutsService.updateShortcutSuggestions();
    } catch (e) {
      debugPrint('Error updating shortcut suggestions: $e');
    }
  }

  /// Clean up old notifications
  static Future<void> _cleanupOldNotifications() async {
    try {
      // Implementation for cleaning up old notifications
      debugPrint('Cleaning up old notifications...');
    } catch (e) {
      debugPrint('Error cleaning up notifications: $e');
    }
  }

  /// Handle app entering background
  static Future<void> onAppBackground() async {
    try {
      debugPrint('📱 App entering background, updating widgets...');
      await updateAllWidgets();
      
      // Donate Siri activity for app backgrounding
      await SiriShortcutsService.donateShortcutActivity(
        identifier: 'quick_mood_entry',
        title: 'Log Mood Before Leaving App',
      );
    } catch (e) {
      debugPrint('Error handling app background: $e');
    }
  }

  /// Handle app entering foreground
  static Future<void> onAppForeground() async {
    try {
      debugPrint('📱 App entering foreground, refreshing data...');
      await updateAllWidgets();
    } catch (e) {
      debugPrint('Error handling app foreground: $e');
    }
  }

  /// Create a new diary entry with system integration
  static Future<void> createDiaryEntryWithIntegration({
    required String title,
    required String content,
    required RecordType type,
    String? mood,
  }) async {
    try {
      // Create the diary entry
      final record = Record.create(
        title: title,
        content: content,
        type: type,
      );

      final databaseService = DatabaseService();
      await databaseService.saveRecord(record);

      // Update widgets
      await _updateSharedTodosWidget();

      // Donate to Siri
      await SiriShortcutsService.donateShortcutActivity(
        identifier: 'add_diary_entry',
        title: 'Added Diary Entry: $title',
        parameters: {'mood': mood},
      );

      debugPrint('✅ Diary entry created with system integration');
    } catch (e) {
      debugPrint('Error creating diary entry with integration: $e');
    }
  }

  /// Send love note with system integration
  static Future<void> sendLoveNoteWithIntegration({
    required String message,
    bool includeLocation = false,
  }) async {
    try {
      // Store the love note in database
      final record = Record.create(
        title: 'Love Note',
        content: message,
        type: RecordType.diary,
      );

      final databaseService = DatabaseService();
      await databaseService.saveRecord(record);

      // Update widgets
      await _updateQuickLoveNoteWidget();

      // Create calendar event for follow-up
      if (includeLocation) {
        final location = await SystemMonitorService.getCurrentLocation();
        if (location != null) {
          await CalendarService.createCoupleEvent(
            title: 'Love Note Sent',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(minutes: 1)),
            eventType: CoupleEventType.coupleActivity,
            description: message,
            location: location.displayName,
          );
        }
      }

      // Donate to Siri
      await SiriShortcutsService.donateShortcutActivity(
        identifier: 'send_love_note',
        title: 'Sent Love Note',
        parameters: {
          'message': message,
          'includeLocation': includeLocation,
        },
      );

      debugPrint('💌 Love note sent with system integration');
    } catch (e) {
      debugPrint('Error sending love note with integration: $e');
    }
  }

  /// Get system integration status
  static Map<String, bool> getSystemIntegrationStatus() {
    return {
      'initialized': _isInitialized,
      'widgets': true, // Check actual widget status
      'calendar': true, // Check calendar permissions
      'notifications': true, // Check notification permissions
      'siri': true, // Check Siri shortcuts status
      'monitoring': _batterySubscription != null,
    };
  }

  /// Dispose of all resources
  static Future<void> dispose() async {
    _periodicUpdateTimer?.cancel();
    await _batterySubscription?.cancel();
    await _locationSubscription?.cancel();
    await _activitySubscription?.cancel();
    
    SystemMonitorService.dispose();
    SmartNotificationsService.dispose();
    
    _isInitialized = false;
    debugPrint('🛑 System Integration Disposed');
  }
}