import 'package:flutter/services.dart';
import 'dart:convert';

/// Widget types following Apple's size conventions
enum WidgetSize {
  small,   // 2x2 - Quick status/actions
  medium,  // 4x2 - List views
  large,   // 4x4 - Dashboard views
}

/// Widget content types for the love app
enum WidgetType {
  partnerStatus,     // Partner's mood + battery
  sharedTodos,       // Shared todo list
  daysCounter,       // Relationship milestones
  quickLoveNote,     // Send love note button
  upcomingDate,      // Next date night
  moodTracker,       // Daily mood widget
  photoMemory,       // Today's memory photo
  goalProgress,      // Shared goals progress
}

/// Apple-style widget service for home screen integration
/// Handles communication between Flutter and native iOS/Android widgets
class WidgetService {
  static const MethodChannel _channel = MethodChannel('com.loverecord.widgets');

  /// Initialize the widget service
  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
      print('✅ Widget service initialized');
    } on PlatformException catch (e) {
      print('Failed to initialize widget service: ${e.message}');
    }
  }

  /// Update widget data on home screen (iOS WidgetKit style)
  static Future<void> updateWidget({
    required WidgetType type,
    required WidgetSize size,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'type': type.name,
        'size': size.name,
        'data': jsonEncode(data),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      print('Failed to update widget: ${e.message}');
    }
  }

  /// Request widget refresh (similar to iOS timeline refresh)
  static Future<void> requestWidgetRefresh(WidgetType type) async {
    try {
      await _channel.invokeMethod('refreshWidget', {
        'type': type.name,
        'refreshReason': 'userAction',
      });
    } on PlatformException catch (e) {
      print('Failed to refresh widget: ${e.message}');
    }
  }

  /// Handle widget interactions (iOS 17+ interactive widgets)
  static Future<void> handleWidgetAction({
    required String action,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      await _channel.invokeMethod('handleWidgetAction', {
        'action': action,
        'parameters': jsonEncode(parameters),
      });
    } on PlatformException catch (e) {
      print('Failed to handle widget action: ${e.message}');
    }
  }

  /// Configure widget appearance and behavior
  static Future<void> configureWidget({
    required WidgetType type,
    required Map<String, dynamic> configuration,
  }) async {
    try {
      await _channel.invokeMethod('configureWidget', {
        'type': type.name,
        'configuration': jsonEncode(configuration),
      });
    } on PlatformException catch (e) {
      print('Failed to configure widget: ${e.message}');
    }
  }

  /// Get widget configuration (for settings screen)
  static Future<Map<String, dynamic>?> getWidgetConfiguration(WidgetType type) async {
    try {
      final result = await _channel.invokeMethod('getWidgetConfiguration', {
        'type': type.name,
      });
      return result != null ? jsonDecode(result) : null;
    } on PlatformException catch (e) {
      print('Failed to get widget configuration: ${e.message}');
      return null;
    }
  }

  /// Apple-style Smart Stack intelligence
  /// Provides hints for when widget should be shown prominently
  static Future<void> donateWidgetIntent({
    required WidgetType type,
    required String userActivity,
    Map<String, dynamic>? context,
  }) async {
    try {
      await _channel.invokeMethod('donateWidgetIntent', {
        'type': type.name,
        'userActivity': userActivity,
        'context': context != null ? jsonEncode(context) : null,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      print('Failed to donate widget intent: ${e.message}');
    }
  }
}

/// Widget data models for different widget types
class PartnerStatusWidget {
  final String partnerName;
  final String mood;
  final int batteryLevel;
  final String currentActivity;
  final String location;
  final DateTime lastSeen;

  const PartnerStatusWidget({
    required this.partnerName,
    required this.mood,
    required this.batteryLevel,
    required this.currentActivity,
    required this.location,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() => {
    'partnerName': partnerName,
    'mood': mood,
    'batteryLevel': batteryLevel,
    'currentActivity': currentActivity,
    'location': location,
    'lastSeen': lastSeen.toIso8601String(),
  };
}

class SharedTodosWidget {
  final List<TodoItem> todos;
  final int completedToday;
  final int totalCount;

  const SharedTodosWidget({
    required this.todos,
    required this.completedToday,
    required this.totalCount,
  });

  Map<String, dynamic> toJson() => {
    'todos': todos.map((t) => t.toJson()).toList(),
    'completedToday': completedToday,
    'totalCount': totalCount,
  };
}

class TodoItem {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final String priority;

  const TodoItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.dueDate,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'dueDate': dueDate?.toIso8601String(),
    'priority': priority,
  };
}

class DaysCounterWidget {
  final String milestone;
  final int daysSince;
  final String description;
  final DateTime startDate;

  const DaysCounterWidget({
    required this.milestone,
    required this.daysSince,
    required this.description,
    required this.startDate,
  });

  Map<String, dynamic> toJson() => {
    'milestone': milestone,
    'daysSince': daysSince,
    'description': description,
    'startDate': startDate.toIso8601String(),
  };
}

class QuickLoveNoteWidget {
  final List<String> quickMessages;
  final String lastSentMessage;
  final DateTime? lastSentTime;

  const QuickLoveNoteWidget({
    required this.quickMessages,
    required this.lastSentMessage,
    this.lastSentTime,
  });

  Map<String, dynamic> toJson() => {
    'quickMessages': quickMessages,
    'lastSentMessage': lastSentMessage,
    'lastSentTime': lastSentTime?.toIso8601String(),
  };
}