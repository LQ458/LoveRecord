import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Provides localized information for AI services
class AiServiceLocalization {
  static String getProviderDisplayName(BuildContext context, String provider) {
    final l10n = AppLocalizations.of(context);
    switch (provider) {
      case 'ernie_bot':
        return '文心一言'; // Keep brand name as is
      case 'mock':
        return l10n.mockAiServiceNotice;
      default:
        return provider;
    }
  }

  static String getProviderDescription(BuildContext context, String provider) {
    final l10n = AppLocalizations.of(context);
    switch (provider) {
      case 'ernie_bot':
        return '百度文心一言官方API，需要Client ID和Client Secret进行认证';
      case 'mock':
        return l10n.mockAiServiceNotice;
      default:
        return l10n.unknownError;
    }
  }

  static String getConnectionStatusMessage(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);
    switch (status.toLowerCase()) {
      case 'connected':
        return l10n.networkConnected;
      case 'disconnected':
        return l10n.networkDisconnected;
      case 'testing':
        return l10n.connectionTest;
      case 'failed':
        return l10n.aiServiceConnectionFailed;
      case 'offline':
        return l10n.offlineMode;
      case 'online':
        return l10n.onlineMode;
      default:
        return status;
    }
  }

  static String getAnalysisStatusMessage(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context);
    switch (status.toLowerCase()) {
      case 'in_progress':
        return l10n.aiAnalysisInProgress;
      case 'completed':
        return l10n.aiAnalysisCompleted;
      case 'failed':
        return l10n.aiAnalysisFailed;
      case 'not_configured':
        return l10n.aiServiceNotConfigured;
      default:
        return status;
    }
  }

  static List<String> getRecordTypeDisplayNames(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      l10n.diary,
      l10n.work,
      l10n.study,
      l10n.travel,
      l10n.health,
      l10n.finance,
      l10n.creative,
    ];
  }

  static List<String> getEmotionDisplayNames(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      l10n.happy,
      l10n.love,
      l10n.calm,
      l10n.sweet,
      l10n.sad,
      l10n.angry,
      l10n.tired,
      l10n.warm,
      l10n.joy,
      l10n.peace,
      l10n.excitement,
      l10n.sorrow,
      l10n.rage,
      l10n.other,
    ];
  }

  static String formatRelativeDate(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context);
    return l10n.formatRelativeTime(dateTime);
  }

  static List<String> getWeekDaysShort(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n.weekDaysShort;
  }
}