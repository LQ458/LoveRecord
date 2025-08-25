import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'romantic_themes.dart';

/// Provides localized theme information
class ThemeLocalization {
  /// Get localized theme description
  static String getThemeDescription(BuildContext context, RomanticTheme theme) {
    final l10n = AppLocalizations.of(context);
    switch (theme) {
      case RomanticTheme.sweetheartBliss:
        return l10n.sweetheartBlissDescription;
      case RomanticTheme.romanticDreams:
        return l10n.romanticDreamsDescription;
      case RomanticTheme.heartfeltHarmony:
        return l10n.heartfeltHarmonyDescription;
      case RomanticTheme.vintageRose:
        return l10n.vintageRoseDescription;
      case RomanticTheme.modernLove:
        return l10n.modernLoveDescription;
      case RomanticTheme.twilightPassion:
        return l10n.twilightPassionDescription;
    }
  }

  /// Get localized theme display name
  static String getThemeDisplayName(BuildContext context, RomanticTheme theme) {
    final l10n = AppLocalizations.of(context);
    return l10n.getThemeDisplayName(theme.name);
  }

  /// Get all available themes with localized names
  static Map<RomanticTheme, String> getLocalizedThemeNames(BuildContext context) {
    return {
      for (var theme in RomanticTheme.values)
        theme: getThemeDisplayName(context, theme),
    };
  }

  /// Get theme selection dialog items
  static List<Widget> buildThemeSelectionItems(
    BuildContext context, 
    RomanticTheme currentTheme,
    Function(RomanticTheme) onThemeSelected,
  ) {
    return RomanticTheme.values.map((theme) {
      final themeData = RomanticThemes.getTheme(theme);
      final isSelected = theme == currentTheme;
      
      return ListTile(
        leading: Icon(
          themeData.icon,
          color: themeData.primary,
        ),
        title: Text(getThemeDisplayName(context, theme)),
        subtitle: Text(getThemeDescription(context, theme)),
        trailing: isSelected ? const Icon(Icons.check) : null,
        selected: isSelected,
        onTap: () => onThemeSelected(theme),
      );
    }).toList();
  }
}