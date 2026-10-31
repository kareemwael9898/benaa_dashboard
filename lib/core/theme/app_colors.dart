import 'package:flutter/material.dart';

/// Colors lifted 1:1 from the Figma export of node `2003:3140`
/// (screen: العوائد المالية).
abstract final class AppColors {
  /// Page background.
  static const Color pureBlack = Color(0xFF000000);

  /// Primary text / icon color.
  static const Color pureWhite = Color(0xFFFFFFFF);

  /// KPI value color.
  static const Color textPrimary = Color(0xFFF5F7FC);

  /// Placeholder / hint text.
  static const Color textMuted = Color(0xFF6F7075);

  /// Sidebar, top bar and panel surface.
  static const Color surface = Color(0xFF141519);

  /// Search field background.
  static const Color surfaceField = Color(0xFF1E1F23);

  /// Table header cells.
  static const Color tableHeader = Color(0xFF2D3037);

  /// KPI card background.
  static const Color kpiSurface = Color(0xFF131E1C);

  /// Table / outlined borders.
  static const Color border = Color(0xFFB3B5B9);

  /// Primary action + success chip.
  static const Color green = Color(0xFF478751);

  /// Destructive action.
  static const Color red = Color(0xFFE8454F);

  /// Brand / active navigation color.
  static const Color gold = Color(0xFFE8C15B);

  /// Brighter gold used for the active glow and outline icons.
  static const Color goldBright = Color(0xFFFCC459);

  /// Neutral icon fill used by a few sidebar icons.
  static const Color iconNeutral = Color(0xFFD9D9D9);

  /// Active navigation row background.
  static const Color navActiveSurface = Color(0xFF1D1A15);

  /// Active navigation row border (rgba(237, 212, 145, 0.5)).
  static const Color navActiveBorder = Color(0x80EDD491);
}
