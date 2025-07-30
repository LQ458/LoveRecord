import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  // Common strings
  String get appName;
  String get ok;
  String get cancel;
  String get save;
  String get delete;
  String get edit;
  String get add;
  String get search;
  String get settings;
  String get loading;
  String get error;
  String get retry;
  
  // Home Screen
  String get loveRecord;
  String get noRecordsYet;
  String get startRecordingMemories;
  String get createFirstRecord;
  String get loadFailed;
  String get searchRecords;
  String get switchDisplayStyle;
  String get selectTheme;
  String get emotionalAnalysis;
  
  // Create Record Screen
  String get createRecord;
  String get recordType;
  String get title;
  String get content;
  String get mediaFiles;
  String get tags;
  String get aiAnalysis;
  String get aiWillAnalyze;
  String get startAnalysis;
  String get pleaseEnterTitle;
  String get pleaseEnterContent;
  String get recordSaved;
  String get saveFailed;
  
  // Record Types
  String get diary;
  String get work;
  String get study;
  String get travel;
  String get health;
  String get finance;
  String get creative;
  
  // Settings Screen
  String get personalInfo;
  String get userName;
  String get pleaseEnterName;
  String get aiServiceConfig;
  String get aiProvider;
  String get apiKey;
  String get pleaseEnterApiKey;
  String get testConnection;
  String get verifyApiKey;
  String get test;
  String get appearanceSettings;
  String get romanticTheme;
  String get brightnessMode;
  String get language;
  String get light;
  String get dark;
  String get chinese;
  String get english;
  String get dataManagement;
  String get autoBackup;
  String get regularBackup;
  String get backupFrequency;
  String get daily;
  String get weekly;
  String get monthly;
  String get exportData;
  String get exportAllRecords;
  String get export;
  String get importData;
  String get restoreFromBackup;
  String get import;
  String get clearAllData;
  String get deleteAllRecords;
  String get clear;
  String get aboutApp;
  String get version;
  String get privacyPolicy;
  String get userAgreement;
  String get feedback;
  String get settingsAutoSave;
  String get languageChangeRestart;
  String get pleaseEnterApiKeyFirst;
  String get apiTestSuccess;
  String get provider;
  String get responseContent;
  String get apiTestFailed;
  
  // Theme Names
  String get sweetheartBliss;
  String get romanticDreams;
  String get heartfeltHarmony;
  String get vintageRose;
  String get modernLove;
  String get twilightPassion;
  
  // Presentation Styles
  String get timeline;
  String get masonry;
  String get moodBased;
  String get memoryBook;
  String get compact;
  
  // Analytics Screen
  String get emotionTrends;
  String get emotionInsights;
  String get memoryStats;
  String get howAreYouToday;
  String get recordMood;
  String get totalRecords;
  String get thisMonthRecords;
  String get mediaFilesCount;
  String get tagsCount;
  String get moodRecorded;
  String get intensity;
  
  // Emotions
  String get happy;
  String get love;
  String get calm;
  String get sweet;
  String get sad;
  String get angry;
  String get tired;
  String get warm;
  String get joy;
  String get peace;
  String get excitement;
  String get sorrow;
  String get rage;
  String get other;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'zh':
        return AppLocalizationsZh();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}