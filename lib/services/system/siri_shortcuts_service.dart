import 'package:flutter/services.dart';
import 'dart:convert';

/// Shortcut categories for organization
enum ShortcutCategory {
  diary,          // Diary-related shortcuts
  todos,          // Todo and task shortcuts
  communication,  // Love notes, messages
  status,         // Partner status, mood
  calendar,       // Events, dates
  mood,           // Mood tracking
}

/// Apple Siri Shortcuts and App Intents integration service
/// Enables voice commands and system-wide app integration
class SiriShortcutsService {
  static const MethodChannel _channel = MethodChannel('com.loverecord.siri_shortcuts');

  /// Initialize Siri Shortcuts system
  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
      await _registerAllShortcuts();
    } on PlatformException catch (e) {
      print('Failed to initialize Siri Shortcuts: ${e.message}');
    }
  }

  /// Register all app shortcuts with the system
  static Future<void> _registerAllShortcuts() async {
    // Diary shortcuts
    await _registerShortcut(SiriShortcut(
      identifier: 'add_diary_entry',
      category: ShortcutCategory.diary,
      title: 'Add Diary Entry',
      subtitle: 'Create a new diary entry',
      systemImageName: 'book.fill',
      suggestedPhrase: 'Add diary entry',
      alternativePhrases: [
        'Record today\'s diary',
        'Write in my diary',
        'Create diary entry',
      ],
      parameters: {},
    ));

    await _registerShortcut(SiriShortcut(
      identifier: 'quick_mood_entry',
      category: ShortcutCategory.mood,
      title: 'Log My Mood',
      subtitle: 'Quickly record current mood',
      systemImageName: 'heart.fill',
      suggestedPhrase: 'Log my mood',
      alternativePhrases: [
        'Record my mood',
        'How am I feeling',
        'Update my mood',
      ],
      parameters: {},
    ));

    // Todo shortcuts
    await _registerShortcut(SiriShortcut(
      identifier: 'add_shared_todo',
      category: ShortcutCategory.todos,
      title: 'Add Shared Todo',
      subtitle: 'Create a shared todo with partner',
      systemImageName: 'checkmark.circle.fill',
      suggestedPhrase: 'Add shared todo',
      alternativePhrases: [
        'Create couple todo',
        'Add task for us',
        'New shared task',
      ],
      parameters: {
        'todoText': {'type': 'string', 'required': true},
        'priority': {'type': 'string', 'default': 'medium'},
        'dueDate': {'type': 'date', 'required': false},
      },
    ));

    await _registerShortcut(SiriShortcut(
      identifier: 'complete_todo',
      category: ShortcutCategory.todos,
      title: 'Complete Todo',
      subtitle: 'Mark a todo as completed',
      systemImageName: 'checkmark.seal.fill',
      suggestedPhrase: 'Complete todo',
      alternativePhrases: [
        'Mark todo done',
        'Finish task',
        'Todo completed',
      ],
      parameters: {
        'todoTitle': {'type': 'string', 'required': true},
      },
    ));

    // Communication shortcuts
    await _registerShortcut(SiriShortcut(
      identifier: 'send_love_note',
      category: ShortcutCategory.communication,
      title: 'Send Love Note',
      subtitle: 'Send a quick love message to partner',
      systemImageName: 'heart.text.square.fill',
      suggestedPhrase: 'Send love note',
      alternativePhrases: [
        'Send love message',
        'Message my partner',
        'Send romantic note',
      ],
      parameters: {
        'message': {'type': 'string', 'required': true},
        'includeLocation': {'type': 'boolean', 'default': false},
      },
    ));

    // Status shortcuts
    await _registerShortcut(SiriShortcut(
      identifier: 'check_partner_status',
      category: ShortcutCategory.status,
      title: 'Check Partner Status',
      subtitle: 'View partner\'s current mood and status',
      systemImageName: 'person.fill.questionmark',
      suggestedPhrase: 'Check partner status',
      alternativePhrases: [
        'How is my partner',
        'Partner mood check',
        'What\'s my partner doing',
      ],
      parameters: {},
    ));

    // Calendar shortcuts
    await _registerShortcut(SiriShortcut(
      identifier: 'schedule_date_night',
      category: ShortcutCategory.calendar,
      title: 'Schedule Date Night',
      subtitle: 'Plan a date night with partner',
      systemImageName: 'calendar.badge.plus',
      suggestedPhrase: 'Schedule date night',
      alternativePhrases: [
        'Plan date night',
        'Book date night',
        'Create date event',
      ],
      parameters: {
        'dateTime': {'type': 'date', 'required': true},
        'location': {'type': 'string', 'required': false},
        'activity': {'type': 'string', 'required': false},
      },
    ));
  }

  /// Register a single shortcut with the system
  static Future<bool> _registerShortcut(SiriShortcut shortcut) async {
    try {
      final result = await _channel.invokeMethod('registerShortcut', shortcut.toJson());
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to register shortcut ${shortcut.identifier}: ${e.message}');
      return false;
    }
  }

  /// Handle shortcut execution from Siri
  static Future<Map<String, dynamic>?> handleShortcut({
    required String identifier,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      switch (identifier) {
        case 'add_diary_entry':
          return await _handleAddDiaryEntry(parameters);
        case 'quick_mood_entry':
          return await _handleQuickMoodEntry(parameters);
        case 'add_shared_todo':
          return await _handleAddSharedTodo(parameters);
        case 'complete_todo':
          return await _handleCompleteTodo(parameters);
        case 'send_love_note':
          return await _handleSendLoveNote(parameters);
        case 'check_partner_status':
          return await _handleCheckPartnerStatus(parameters);
        case 'schedule_date_night':
          return await _handleScheduleDateNight(parameters);
        default:
          return {'success': false, 'error': 'Unknown shortcut'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Handle diary entry creation via Siri
  static Future<Map<String, dynamic>> _handleAddDiaryEntry(Map<String, dynamic> parameters) async {
    try {
      // Extract text from Siri dictation
      final text = parameters['text'] as String? ?? '';
      final mood = parameters['mood'] as String? ?? 'neutral';
      
      // Create diary entry (integrate with your diary service)
      await _channel.invokeMethod('createDiaryEntry', {
        'content': text,
        'mood': mood,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      return {
        'success': true,
        'message': 'Diary entry created successfully',
        'response': 'Your diary entry has been saved.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'response': 'Sorry, I couldn\'t save your diary entry.',
      };
    }
  }

  /// Handle quick mood logging via Siri
  static Future<Map<String, dynamic>> _handleQuickMoodEntry(Map<String, dynamic> parameters) async {
    try {
      final mood = parameters['mood'] as String? ?? 'neutral';
      final notes = parameters['notes'] as String? ?? '';
      
      await _channel.invokeMethod('logMood', {
        'mood': mood,
        'notes': notes,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      return {
        'success': true,
        'message': 'Mood logged successfully',
        'response': 'I\'ve recorded that you\'re feeling $mood.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'response': 'I couldn\'t log your mood right now.',
      };
    }
  }

  /// Handle shared todo creation via Siri
  static Future<Map<String, dynamic>> _handleAddSharedTodo(Map<String, dynamic> parameters) async {
    try {
      final todoText = parameters['todoText'] as String;
      final priority = parameters['priority'] as String? ?? 'medium';
      final dueDate = parameters['dueDate'] as DateTime?;
      
      await _channel.invokeMethod('createSharedTodo', {
        'title': todoText,
        'priority': priority,
        'dueDate': dueDate?.millisecondsSinceEpoch,
        'createdBy': 'siri_shortcut',
      });
      
      return {
        'success': true,
        'message': 'Shared todo created',
        'response': 'I\'ve added "$todoText" to your shared todo list.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'response': 'I couldn\'t create that todo right now.',
      };
    }
  }

  /// Handle todo completion via Siri
  static Future<Map<String, dynamic>> _handleCompleteTodo(Map<String, dynamic> parameters) async {
    try {
      final todoTitle = parameters['todoTitle'] as String;
      
      // Find and complete the todo
      final result = await _channel.invokeMethod('completeTodoByTitle', {
        'title': todoTitle,
      });
      
      if (result['found'] == true) {
        return {
          'success': true,
          'message': 'Todo completed',
          'response': 'Great! I\'ve marked "$todoTitle" as completed.',
        };
      } else {
        return {
          'success': false,
          'error': 'Todo not found',
          'response': 'I couldn\'t find a todo with that name.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'response': 'I couldn\'t complete that todo right now.',
      };
    }
  }

  /// Handle sending love note via Siri
  static Future<Map<String, dynamic>> _handleSendLoveNote(Map<String, dynamic> parameters) async {
    try {
      final message = parameters['message'] as String;
      final includeLocation = parameters['includeLocation'] as bool? ?? false;
      
      await _channel.invokeMethod('sendLoveNote', {
        'message': message,
        'includeLocation': includeLocation,
        'sentVia': 'siri_shortcut',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      return {
        'success': true,
        'message': 'Love note sent',
        'response': 'Your love note has been sent to your partner.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'response': 'I couldn\'t send that message right now.',
      };
    }
  }

  /// Handle checking partner status via Siri
  static Future<Map<String, dynamic>> _handleCheckPartnerStatus(Map<String, dynamic> parameters) async {
    try {
      final result = await _channel.invokeMethod('getPartnerStatus');
      
      final status = result as Map<String, dynamic>;
      final mood = status['mood'] as String? ?? 'unknown';
      final activity = status['activity'] as String? ?? 'unknown';
      final battery = status['batteryLevel'] as int? ?? 0;
      final location = status['location'] as String? ?? 'unknown location';
      
      String response = 'Your partner is feeling $mood';
      if (activity != 'unknown') {
        response += ' and is currently $activity';
      }
      if (battery > 0) {
        response += '. Their battery is at $battery%';
      }
      response += '.';
      
      return {
        'success': true,
        'message': 'Partner status retrieved',
        'response': response,
        'data': status,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'response': 'I couldn\'t get your partner\'s status right now.',
      };
    }
  }

  /// Handle date night scheduling via Siri
  static Future<Map<String, dynamic>> _handleScheduleDateNight(Map<String, dynamic> parameters) async {
    try {
      final dateTime = parameters['dateTime'] as DateTime;
      final location = parameters['location'] as String? ?? '';
      final activity = parameters['activity'] as String? ?? 'Date Night';
      
      await _channel.invokeMethod('scheduleDateNight', {
        'dateTime': dateTime.millisecondsSinceEpoch,
        'location': location,
        'activity': activity,
        'scheduledVia': 'siri_shortcut',
      });
      
      return {
        'success': true,
        'message': 'Date night scheduled',
        'response': 'Perfect! I\'ve scheduled your date night for ${_formatDateTime(dateTime)}.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'response': 'I couldn\'t schedule that date night.',
      };
    }
  }

  /// Donate user activity to Siri for suggestions
  static Future<void> donateShortcutActivity({
    required String identifier,
    required String title,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _channel.invokeMethod('donateActivity', {
        'identifier': identifier,
        'title': title,
        'parameters': parameters != null ? jsonEncode(parameters) : null,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      print('Failed to donate shortcut activity: ${e.message}');
    }
  }

  /// Update shortcut suggestions based on usage patterns
  static Future<void> updateShortcutSuggestions() async {
    try {
      await _channel.invokeMethod('updateShortcutSuggestions');
    } on PlatformException catch (e) {
      print('Failed to update shortcut suggestions: ${e.message}');
    }
  }

  /// Helper method to format date/time for responses
  static String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays == 0) {
      if (difference.inHours < 1) {
        return 'in ${difference.inMinutes} minutes';
      } else {
        return 'today at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } else if (difference.inDays == 1) {
      return 'tomorrow at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return 'on ${dateTime.month}/${dateTime.day} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Siri Shortcut data model
class SiriShortcut {
  final String identifier;
  final ShortcutCategory category;
  final String title;
  final String subtitle;
  final String systemImageName;
  final String suggestedPhrase;
  final List<String> alternativePhrases;
  final Map<String, dynamic> parameters;

  const SiriShortcut({
    required this.identifier,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.systemImageName,
    required this.suggestedPhrase,
    required this.alternativePhrases,
    required this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'category': category.name,
      'title': title,
      'subtitle': subtitle,
      'systemImageName': systemImageName,
      'suggestedPhrase': suggestedPhrase,
      'alternativePhrases': alternativePhrases,
      'parameters': parameters,
    };
  }
}