import 'package:flutter/material.dart';

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
  String get confirm;
  String get yes;
  String get no;
  String get close;
  String get back;
  String get next;
  String get previous;
  String get done;
  String get select;
  String get choose;
  
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
  String get selectDisplayStyle;
  String get selectRomanticTheme;
  String get confirmDelete;
  String get confirmDeleteRecord;
  String get recordDeleted;
  String get recordDeleteFailed;
  
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
  String get selectImageFailed;
  String get selectVideoFailed;
  String get selectFileFailed;
  String get addTag;
  String get popularTags;
  String get enterTag;
  
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
  String get brightness;
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
  String get confirmClearAllData;
  String get clearAllDataWarning;
  String get networkDiagnosis;
  String get networkStatus;
  String get connectionTest;
  String get dnsTest;
  String get networkConnected;
  String get networkDisconnected;
  String get dnsResolved;
  String get dnsFailed;
  String get switchToMockService;
  String get troubleshooting;
  String get checkNetworkConnection;
  String get checkApiKey;
  String get checkServiceStatus;
  
  // Theme Names
  String get sweetheartBliss;
  String get romanticDreams;
  String get heartfeltHarmony;
  String get vintageRose;
  String get modernLove;
  String get twilightPassion;
  
  // Theme Selection
  String get chooseTheme;
  
  // Presentation Styles
  String get timeline;
  String get masonry;
  String get moodBased;
  String get memoryBook;
  String get compact;
  String get statistics;
  
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
  
  // Record Detail Screen
  String get recordDetails;
  String get editRecord;
  String get recordEditFailed;
  String get recordUpdateFailed;
  String get recordUpdated;
  String get confirmDeleteRecordDetail;
  String get deleteRecordWarning;
  String get recordInfo;
  String get noContent;
  
  // Onboarding Screen
  String get welcomeToLoveRecord;
  String get recordBeautifulMoments;
  String get aiPoweredAnalysis;
  String get smartTagsAndInsights;
  String get beautifulThemes;
  String get customizeYourExperience;
  String get getStarted;
  String get skip;
  String get selectAiProvider;
  String get configureApiKey;
  String get enableSmartFeatures;
  String get chooseAiProvider;
  String get configureApiKeyDescription;
  String get aiProviderSelection;
  
  // Calendar View
  String get calendar;
  String get today;
  String get yesterday;
  String get tomorrow;
  String get thisWeek;
  String get lastWeek;
  String get thisMonth;
  String get lastMonth;
  String get noRecordsOnDate;
  String get recordsOnDate;
  
  // System Messages
  String get operationSuccessful;
  String get operationFailed;
  String get networkError;
  String get serverError;
  String get unknownError;
  String get pleaseTryAgain;
  String get pleaseCheckNetwork;
  String get pleaseCheckSettings;
  String get pleaseWait;
  String get processing;
  String get completed;
  String get failed;
  String get success;
  String get warning;
  String get info;
  String get notice;
  
  // AI Service Messages
  String get aiServiceNotConfigured;
  String get aiServiceConnectionFailed;
  String get aiAnalysisInProgress;
  String get aiAnalysisCompleted;
  String get aiAnalysisFailed;
  String get mockAiServiceNotice;
  String get switchingToOfflineMode;
  String get imageAnalysisNotImplemented;
  
  // Network Diagnostics
  String get checkingNetworkConnection;
  String get basicInternetAccess;
  String get dnsResolutionTest;
  String get httpsConnectionTest;
  String get geographicRestrictionTest;
  String get macosSpecificChecks;
  String get networkIssuesFound;
  String get networkSuggestionsTitle;
  String get checkFirewallSettings;
  String get checkVpnSettings;
  String get checkProxySettings;
  String get checkSystemTime;
  String get retryConnectionMethod;
  String get allConnectionMethodsFailed;
  
  // Theme Descriptions
  String get sweetheartBlissDescription;
  String get romanticDreamsDescription;
  String get heartfeltHarmonyDescription;
  String get vintageRoseDescription;
  String get modernLoveDescription;
  String get twilightPassionDescription;
  
  // Record Type Helpers
  String getRecordTypeDisplayName(String type);
  String getEmotionDisplayName(String emotion);
  String getThemeDisplayName(String theme);
  
  // Filter Options
  String get allRecords;
  String get diaryRecords;
  String get workRecords;
  String get studyRecords;
  String get lifeRecords;
  String get otherRecords;
  
  // Date and Time Formatting
  String get justNow;
  String get minutesAgo;
  String get hoursAgo;
  String get daysAgo;
  String get weeksAgo;
  String get monthsAgo;
  String get yearsAgo;
  String formatRelativeTime(DateTime dateTime);
  
  // Calendar Specific
  String get sunday;
  String get monday;
  String get tuesday;
  String get wednesday;
  String get thursday;
  String get friday;
  String get saturday;
  List<String> get weekDaysShort;
  
  // Enhanced UI Messages
  String get noMatchingRecords;
  String get searchError;
  String get filterRecords;
  String get clearFilters;
  String get recordsFound;
  String get totalFiles;
  String get selectedTags;
  String get addNewTag;
  String get enterTagName;
  String get popularTagsRecommendation;
  String get intensityLevel;
  String get moodRecordedWithIntensity;
  
  // System and App State
  String get appTitle;
  String get recordExists;
  String get recordNotFound;
  String get apiKeyRequired;
  String get apiKeyConfigured;
  String get offlineMode;
  String get onlineMode;
  String get featureComingSoon;
  String get underDevelopment;
  String get contactSupport;
  String get reportIssue;
  
  // Additional Settings
  String get diagnostics;
  String get runDiagnostics;
  String get systemInformation;
  String get aboutApplication;
  String get applicationVersion;
  String get buildNumber;
  String get installationDate;
  String get lastUpdated;
  
  // Multi-language Support Preparation
  String get languageSelection;
  String get currentLanguage;
  String get availableLanguages;
  String get languageCode;
  String get regionCode;
  String get systemLanguage;
  String get useSystemLanguage;
  String get customLanguage;
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