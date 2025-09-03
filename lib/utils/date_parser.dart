import 'dart:developer' as developer;

/// Smart date parser that extracts due dates from natural language text
class SmartDateParser {
  static final Map<String, int> _weekdays = {
    'monday': 1,
    'tuesday': 2,
    'wednesday': 3,
    'thursday': 4,
    'friday': 5,
    'saturday': 6,
    'sunday': 7,
    'mon': 1,
    'tue': 2,
    'wed': 3,
    'thu': 4,
    'fri': 5,
    'sat': 6,
    'sun': 7,
  };

  static final Map<String, int> _months = {
    'january': 1, 'jan': 1,
    'february': 2, 'feb': 2,
    'march': 3, 'mar': 3,
    'april': 4, 'apr': 4,
    'may': 5,
    'june': 6, 'jun': 6,
    'july': 7, 'jul': 7,
    'august': 8, 'aug': 8,
    'september': 9, 'sep': 9, 'sept': 9,
    'october': 10, 'oct': 10,
    'november': 11, 'nov': 11,
    'december': 12, 'dec': 12,
  };

  static final List<String> _timeKeywords = [
    'tonight', 'today', 'tomorrow', 'yesterday',
    'morning', 'afternoon', 'evening', 'noon',
    'midnight', 'am', 'pm'
  ];

  static final Map<String, String> _chineseKeywords = {
    '今天': 'today',
    '明天': 'tomorrow',
    '后天': 'day after tomorrow',
    '昨天': 'yesterday',
    '今晚': 'tonight',
    '明早': 'tomorrow morning',
    '下周': 'next week',
    '这周': 'this week',
    '下个月': 'next month',
    '周一': 'monday',
    '周二': 'tuesday', 
    '周三': 'wednesday',
    '周四': 'thursday',
    '周五': 'friday',
    '周六': 'saturday',
    '周日': 'sunday',
    '星期一': 'monday',
    '星期二': 'tuesday',
    '星期三': 'wednesday', 
    '星期四': 'thursday',
    '星期五': 'friday',
    '星期六': 'saturday',
    '星期日': 'sunday',
  };

  /// Parse a text string and extract date/time information
  static DateParseResult parseText(String text) {
    final lowercaseText = text.toLowerCase();
    final words = lowercaseText.split(RegExp(r'\s+'));
    
    DateTime? dueDate;
    String cleanedText = text;
    List<String> extractedKeywords = [];

    try {
      // Check for relative date keywords
      if (lowercaseText.contains('tonight')) {
        dueDate = DateTime.now().copyWith(hour: 20, minute: 0, second: 0, millisecond: 0);
        extractedKeywords.add('tonight');
        cleanedText = _removeKeywords(text, ['tonight']);
      } else if (lowercaseText.contains('today')) {
        dueDate = DateTime.now().copyWith(hour: 18, minute: 0, second: 0, millisecond: 0);
        extractedKeywords.add('today');
        cleanedText = _removeKeywords(text, ['today']);
      } else if (lowercaseText.contains('tomorrow')) {
        dueDate = DateTime.now().add(const Duration(days: 1)).copyWith(hour: 18, minute: 0, second: 0, millisecond: 0);
        extractedKeywords.add('tomorrow');
        cleanedText = _removeKeywords(text, ['tomorrow']);
      }
      
      // Check for "next [weekday]"
      for (final entry in _weekdays.entries) {
        if (lowercaseText.contains('next ${entry.key}')) {
          dueDate = _getNextWeekday(entry.value);
          extractedKeywords.add('next ${entry.key}');
          cleanedText = _removeKeywords(text, ['next ${entry.key}']);
          break;
        }
      }
      
      // Check for "this [weekday]"
      for (final entry in _weekdays.entries) {
        if (lowercaseText.contains('this ${entry.key}')) {
          dueDate = _getThisWeekday(entry.value);
          extractedKeywords.add('this ${entry.key}');
          cleanedText = _removeKeywords(text, ['this ${entry.key}']);
          break;
        }
      }
      
      // Check for standalone weekdays
      if (dueDate == null) {
        for (final entry in _weekdays.entries) {
          if (words.contains(entry.key)) {
            dueDate = _getNextWeekday(entry.value);
            extractedKeywords.add(entry.key);
            cleanedText = _removeKeywords(text, [entry.key]);
            break;
          }
        }
      }

      // Check for "in X days", "X days later", "1 week later", etc.
      final daysPattern = RegExp(r'(?:in )?(\d+) days?(?:\s+later)?');
      final daysMatch = daysPattern.firstMatch(lowercaseText);
      if (daysMatch != null) {
        final days = int.parse(daysMatch.group(1)!);
        dueDate = DateTime.now().add(Duration(days: days)).copyWith(hour: 18, minute: 0, second: 0, millisecond: 0);
        extractedKeywords.add(daysMatch.group(0)!);
        cleanedText = text.replaceAll(daysPattern, '').trim();
      }
      
      // Check for "X week(s) later/from now"
      final weeksPattern = RegExp(r'(?:in )?(\d+) weeks?(?:\s+(?:later|from now))?');
      final weeksMatch = weeksPattern.firstMatch(lowercaseText);
      if (weeksMatch != null) {
        final weeks = int.parse(weeksMatch.group(1)!);
        dueDate = DateTime.now().add(Duration(days: weeks * 7)).copyWith(hour: 18, minute: 0, second: 0, millisecond: 0);
        extractedKeywords.add(weeksMatch.group(0)!);
        cleanedText = text.replaceAll(weeksPattern, '').trim();
      }
      
      // Check for Chinese date expressions
      String translatedText = lowercaseText;
      for (final entry in _chineseKeywords.entries) {
        if (lowercaseText.contains(entry.key)) {
          translatedText = translatedText.replaceAll(entry.key, entry.value);
          extractedKeywords.add(entry.key);
        }
      }
      
      // Re-run English parsing on translated text if Chinese was found
      if (translatedText != lowercaseText && dueDate == null) {
        if (translatedText.contains('today')) {
          dueDate = DateTime.now().copyWith(hour: 18, minute: 0, second: 0, millisecond: 0);
          cleanedText = _removeChineseKeywords(text, extractedKeywords);
        } else if (translatedText.contains('tomorrow')) {
          dueDate = DateTime.now().add(const Duration(days: 1)).copyWith(hour: 18, minute: 0, second: 0, millisecond: 0);
          cleanedText = _removeChineseKeywords(text, extractedKeywords);
        } else if (translatedText.contains('day after tomorrow')) {
          dueDate = DateTime.now().add(const Duration(days: 2)).copyWith(hour: 18, minute: 0, second: 0, millisecond: 0);
          cleanedText = _removeChineseKeywords(text, extractedKeywords);
        } else if (translatedText.contains('tonight')) {
          dueDate = DateTime.now().copyWith(hour: 20, minute: 0, second: 0, millisecond: 0);
          cleanedText = _removeChineseKeywords(text, extractedKeywords);
        } else if (translatedText.contains('next week')) {
          dueDate = DateTime.now().add(const Duration(days: 7)).copyWith(hour: 18, minute: 0, second: 0, millisecond: 0);
          cleanedText = _removeChineseKeywords(text, extractedKeywords);
        }
        
        // Check for Chinese weekdays
        for (final entry in _weekdays.entries) {
          if (translatedText.contains(entry.key)) {
            dueDate = _getNextWeekday(entry.value);
            cleanedText = _removeChineseKeywords(text, extractedKeywords);
            break;
          }
        }
      }

      // Check for specific times
      final timePattern = RegExp(r'(\d{1,2}):?(\d{2})?\s*(am|pm)?');
      final timeMatch = timePattern.firstMatch(lowercaseText);
      if (timeMatch != null && dueDate != null) {
        int hour = int.parse(timeMatch.group(1)!);
        int minute = timeMatch.group(2) != null ? int.parse(timeMatch.group(2)!) : 0;
        String? period = timeMatch.group(3);
        
        if (period == 'pm' && hour != 12) hour += 12;
        if (period == 'am' && hour == 12) hour = 0;
        
        dueDate = dueDate.copyWith(hour: hour, minute: minute, second: 0, millisecond: 0);
        extractedKeywords.add(timeMatch.group(0)!);
        cleanedText = cleanedText.replaceAll(timePattern, '').trim();
      }

      // Check for date patterns (MM/DD, DD/MM, etc.)
      final datePattern = RegExp(r'(\d{1,2})[\/\-](\d{1,2})(?:[\/\-](\d{2,4}))?');
      final dateMatch = datePattern.firstMatch(lowercaseText);
      if (dateMatch != null && dueDate == null) {
        final month = int.parse(dateMatch.group(1)!);
        final day = int.parse(dateMatch.group(2)!);
        int year = DateTime.now().year;
        if (dateMatch.group(3) != null) {
          year = int.parse(dateMatch.group(3)!);
          if (year < 100) year += 2000;
        }
        
        try {
          dueDate = DateTime(year, month, day, 18, 0);
          extractedKeywords.add(dateMatch.group(0)!);
          cleanedText = text.replaceAll(datePattern, '').trim();
        } catch (e) {
          // Invalid date, ignore
        }
      }

      developer.log('Parsed text: "$text" -> cleanedText: "$cleanedText", dueDate: $dueDate', name: 'SmartDateParser');

    } catch (e) {
      developer.log('Error parsing date from text: $e', name: 'SmartDateParser');
    }

    return DateParseResult(
      cleanedText: cleanedText.trim(),
      dueDate: dueDate,
      extractedKeywords: extractedKeywords,
      hasDateInfo: dueDate != null,
    );
  }

  static String _removeKeywords(String text, List<String> keywords) {
    String result = text;
    for (final keyword in keywords) {
      result = result.replaceAll(RegExp(r'\b' + RegExp.escape(keyword) + r'\b', caseSensitive: false), '');
    }
    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
  
  static String _removeChineseKeywords(String text, List<String> keywords) {
    String result = text;
    for (final keyword in keywords) {
      result = result.replaceAll(keyword, '');
    }
    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static DateTime _getNextWeekday(int weekday) {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    int daysToAdd = weekday - currentWeekday;
    if (daysToAdd <= 0) daysToAdd += 7;
    
    return now.add(Duration(days: daysToAdd)).copyWith(hour: 18, minute: 0, second: 0, millisecond: 0);
  }

  static DateTime _getThisWeekday(int weekday) {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    int daysToAdd = weekday - currentWeekday;
    
    // If it's the same day, return today; if it's past, return next week
    if (daysToAdd < 0) daysToAdd += 7;
    
    return now.add(Duration(days: daysToAdd)).copyWith(hour: 18, minute: 0, second: 0, millisecond: 0);
  }

  /// Generate smart suggestions based on partial text
  static List<String> getSuggestions(String partialText) {
    final suggestions = <String>[];
    final lowercaseText = partialText.toLowerCase();

    // Time-based suggestions
    if (lowercaseText.contains('cook') || lowercaseText.contains('dinner')) {
      suggestions.addAll(['tonight', 'tomorrow evening', 'this weekend']);
    }
    
    if (lowercaseText.contains('meeting') || lowercaseText.contains('call')) {
      suggestions.addAll(['tomorrow', 'next monday', 'this friday']);
    }
    
    if (lowercaseText.contains('buy') || lowercaseText.contains('shop')) {
      suggestions.addAll(['today', 'tomorrow', 'this weekend']);
    }
    
    if (lowercaseText.contains('exercise') || lowercaseText.contains('workout')) {
      suggestions.addAll(['tomorrow morning', 'tonight', 'monday']);
    }

    // Generic suggestions
    suggestions.addAll(['today', 'tomorrow', 'tonight', 'this weekend', 'next week']);

    return suggestions.take(5).toList();
  }
}

/// Result of parsing text for date/time information
class DateParseResult {
  final String cleanedText;
  final DateTime? dueDate;
  final List<String> extractedKeywords;
  final bool hasDateInfo;

  const DateParseResult({
    required this.cleanedText,
    required this.dueDate,
    required this.extractedKeywords,
    required this.hasDateInfo,
  });

  @override
  String toString() {
    return 'DateParseResult(cleanedText: "$cleanedText", dueDate: $dueDate, keywords: $extractedKeywords)';
  }
}

/// Multi-step deadline support
enum DeadlineType {
  reminder,    // Reminder before the actual deadline
  deadline,    // Final deadline
  checkpoint,  // Intermediate checkpoint
}

class MultiStepDeadline {
  final String id;
  final String title;
  final DateTime date;
  final DeadlineType type;
  final String? parentTaskId;

  const MultiStepDeadline({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.parentTaskId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.millisecondsSinceEpoch,
      'type': type.name,
      'parentTaskId': parentTaskId,
    };
  }

  factory MultiStepDeadline.fromJson(Map<String, dynamic> json) {
    return MultiStepDeadline(
      id: json['id'],
      title: json['title'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      type: DeadlineType.values.firstWhere((t) => t.name == json['type']),
      parentTaskId: json['parentTaskId'],
    );
  }
}