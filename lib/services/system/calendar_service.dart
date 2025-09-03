import 'package:flutter/services.dart';
import 'dart:convert';

/// Calendar access levels (following Apple's EventKit model)
enum CalendarAccess {
  none,       // No access
  writeOnly,  // Can add events only
  full,       // Can read and modify existing events
}

/// Event types specific to love/couple activities
enum CoupleEventType {
  dateNight,
  anniversary,
  sharedGoal,
  travelPlan,
  coupleActivity,
  relationship_milestone,
  surprisePlanning,
}

/// Apple EventKit-style calendar integration service
/// Handles deep integration with system calendar for couple activities
class CalendarService {
  static const MethodChannel _channel = MethodChannel('com.loverecord.calendar');

  /// Request calendar access permission (iOS EventKit style)
  static Future<CalendarAccess> requestCalendarAccess() async {
    try {
      final result = await _channel.invokeMethod('requestCalendarAccess');
      return CalendarAccess.values.firstWhere(
        (e) => e.name == result,
        orElse: () => CalendarAccess.none,
      );
    } on PlatformException catch (e) {
      print('Failed to request calendar access: ${e.message}');
      return CalendarAccess.none;
    }
  }

  /// Get current calendar access level
  static Future<CalendarAccess> getCalendarAccessStatus() async {
    try {
      final result = await _channel.invokeMethod('getCalendarAccessStatus');
      return CalendarAccess.values.firstWhere(
        (e) => e.name == result,
        orElse: () => CalendarAccess.none,
      );
    } on PlatformException catch (e) {
      print('Failed to get calendar access status: ${e.message}');
      return CalendarAccess.none;
    }
  }

  /// Create a couple-related event in system calendar
  static Future<String?> createCoupleEvent({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required CoupleEventType eventType,
    String? description,
    String? location,
    List<String>? attendees,
    bool setReminder = true,
    Duration? reminderOffset,
  }) async {
    try {
      final result = await _channel.invokeMethod('createCoupleEvent', {
        'title': title,
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
        'eventType': eventType.name,
        'description': description,
        'location': location,
        'attendees': attendees,
        'setReminder': setReminder,
        'reminderOffset': reminderOffset?.inMinutes ?? 15,
      });
      return result; // Returns event identifier
    } on PlatformException catch (e) {
      print('Failed to create couple event: ${e.message}');
      return null;
    }
  }

  /// Get couple events from system calendar
  static Future<List<CoupleEvent>> getCoupleEvents({
    DateTime? startDate,
    DateTime? endDate,
    CoupleEventType? eventType,
  }) async {
    try {
      final result = await _channel.invokeMethod('getCoupleEvents', {
        'startDate': startDate?.millisecondsSinceEpoch,
        'endDate': endDate?.millisecondsSinceEpoch,
        'eventType': eventType?.name,
      });
      
      final List<dynamic> eventsJson = jsonDecode(result);
      return eventsJson.map((json) => CoupleEvent.fromJson(json)).toList();
    } on PlatformException catch (e) {
      print('Failed to get couple events: ${e.message}');
      return [];
    }
  }

  /// Update existing couple event
  static Future<bool> updateCoupleEvent({
    required String eventId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? location,
  }) async {
    try {
      final result = await _channel.invokeMethod('updateCoupleEvent', {
        'eventId': eventId,
        'title': title,
        'startDate': startDate?.millisecondsSinceEpoch,
        'endDate': endDate?.millisecondsSinceEpoch,
        'description': description,
        'location': location,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to update couple event: ${e.message}');
      return false;
    }
  }

  /// Delete couple event from system calendar
  static Future<bool> deleteCoupleEvent(String eventId) async {
    try {
      final result = await _channel.invokeMethod('deleteCoupleEvent', {
        'eventId': eventId,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to delete couple event: ${e.message}');
      return false;
    }
  }

  /// Sync shared todos with calendar (create calendar events for important todos)
  static Future<void> syncTodosWithCalendar({
    required List<SharedTodoCalendarEvent> todos,
  }) async {
    try {
      final todosJson = todos.map((todo) => todo.toJson()).toList();
      await _channel.invokeMethod('syncTodosWithCalendar', {
        'todos': jsonEncode(todosJson),
      });
    } on PlatformException catch (e) {
      print('Failed to sync todos with calendar: ${e.message}');
    }
  }

  /// Smart calendar analysis - find optimal date night slots
  static Future<List<DateTimeSlot>> findOptimalDateSlots({
    required Duration duration,
    DateTime? preferredStartDate,
    DateTime? preferredEndDate,
    List<String>? preferredTimeRanges, // e.g., ["evening", "weekend"]
  }) async {
    try {
      final result = await _channel.invokeMethod('findOptimalDateSlots', {
        'duration': duration.inMinutes,
        'preferredStartDate': preferredStartDate?.millisecondsSinceEpoch,
        'preferredEndDate': preferredEndDate?.millisecondsSinceEpoch,
        'preferredTimeRanges': preferredTimeRanges,
      });
      
      final List<dynamic> slotsJson = jsonDecode(result);
      return slotsJson.map((json) => DateTimeSlot.fromJson(json)).toList();
    } on PlatformException catch (e) {
      print('Failed to find optimal date slots: ${e.message}');
      return [];
    }
  }

  /// Create recurring anniversary events (Apple-style recurring events)
  static Future<String?> createRecurringAnniversary({
    required String title,
    required DateTime anniversaryDate,
    String? description,
    bool setReminder = true,
  }) async {
    try {
      final result = await _channel.invokeMethod('createRecurringAnniversary', {
        'title': title,
        'anniversaryDate': anniversaryDate.millisecondsSinceEpoch,
        'description': description,
        'setReminder': setReminder,
      });
      return result;
    } on PlatformException catch (e) {
      print('Failed to create recurring anniversary: ${e.message}');
      return null;
    }
  }

  /// Get partner's availability (requires partner's calendar sharing)
  static Future<PartnerAvailability?> getPartnerAvailability({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await _channel.invokeMethod('getPartnerAvailability', {
        'startDate': startDate.millisecondsSinceEpoch,
        'endDate': endDate.millisecondsSinceEpoch,
      });
      
      return result != null 
          ? PartnerAvailability.fromJson(jsonDecode(result))
          : null;
    } on PlatformException catch (e) {
      print('Failed to get partner availability: ${e.message}');
      return null;
    }
  }
}

/// Data models for calendar integration
class CoupleEvent {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final CoupleEventType eventType;
  final String? description;
  final String? location;
  final List<String> attendees;
  final bool hasReminder;

  const CoupleEvent({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.eventType,
    this.description,
    this.location,
    required this.attendees,
    required this.hasReminder,
  });

  factory CoupleEvent.fromJson(Map<String, dynamic> json) {
    return CoupleEvent(
      id: json['id'],
      title: json['title'],
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(json['endDate']),
      eventType: CoupleEventType.values.firstWhere(
        (e) => e.name == json['eventType'],
        orElse: () => CoupleEventType.coupleActivity,
      ),
      description: json['description'],
      location: json['location'],
      attendees: List<String>.from(json['attendees'] ?? []),
      hasReminder: json['hasReminder'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'eventType': eventType.name,
      'description': description,
      'location': location,
      'attendees': attendees,
      'hasReminder': hasReminder,
    };
  }
}

class SharedTodoCalendarEvent {
  final String todoId;
  final String title;
  final DateTime? dueDate;
  final String priority;
  final bool createCalendarEvent;

  const SharedTodoCalendarEvent({
    required this.todoId,
    required this.title,
    this.dueDate,
    required this.priority,
    required this.createCalendarEvent,
  });

  Map<String, dynamic> toJson() {
    return {
      'todoId': todoId,
      'title': title,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'priority': priority,
      'createCalendarEvent': createCalendarEvent,
    };
  }
}

class DateTimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final double suitabilityScore; // 0-1, how suitable this slot is
  final List<String> reasons; // Why this slot is good

  const DateTimeSlot({
    required this.startTime,
    required this.endTime,
    required this.suitabilityScore,
    required this.reasons,
  });

  factory DateTimeSlot.fromJson(Map<String, dynamic> json) {
    return DateTimeSlot(
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime']),
      suitabilityScore: json['suitabilityScore'].toDouble(),
      reasons: List<String>.from(json['reasons'] ?? []),
    );
  }
}

class PartnerAvailability {
  final List<DateTimeSlot> freeSlots;
  final List<DateTimeSlot> busySlots;
  final DateTime lastUpdated;

  const PartnerAvailability({
    required this.freeSlots,
    required this.busySlots,
    required this.lastUpdated,
  });

  factory PartnerAvailability.fromJson(Map<String, dynamic> json) {
    return PartnerAvailability(
      freeSlots: (json['freeSlots'] as List)
          .map((slot) => DateTimeSlot.fromJson(slot))
          .toList(),
      busySlots: (json['busySlots'] as List)
          .map((slot) => DateTimeSlot.fromJson(slot))
          .toList(),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated']),
    );
  }
}