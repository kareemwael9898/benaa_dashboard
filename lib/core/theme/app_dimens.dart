import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Layout constants from the Figma frame (1440 × 1199).
///
/// Everything is expressed in design pixels and adapted through ScreenUtil so
/// the dashboard keeps its proportions at any window size.
abstract final class AppDimens {
  /// Figma frame width.
  static const double designWidth = 1440;

  /// Figma frame height.
  static const double designHeight = 1199;

  // Sidebar ---------------------------------------------------------------
  static double get sidebarWidth => 280.w;
  static double get sidebarHorizontalPadding => 23.w;
  static double get sidebarVerticalPadding => 18.h;
  static double get sidebarSpacing => 18.h;

  // Top bar ---------------------------------------------------------------
  static double get topBarHeight => 83.h;
  static double get topBarHorizontalPadding => 16.w;
  static double get topBarVerticalPadding => 12.h;

  // Page ------------------------------------------------------------------
  static double get pageHorizontalPadding => 24.w;
  static double get pageTopPadding => 23.h;
  static double get pageGap => 24.h;

  // Blocks ----------------------------------------------------------------
  static double get filterFieldWidth => 269.w;
  static double get filterFieldGap => 24.w;
  static double get actionButtonWidth => 269.w;
  static double get blockRadius => 12.r;
  static double get cardRadius => 18.r;
  static double get panelPadding => 16.w;
  static double get sectionGap => 18.h;
}
