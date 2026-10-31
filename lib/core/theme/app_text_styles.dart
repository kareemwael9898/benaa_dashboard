import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

/// Font families bundled under `assets/fonts/`.
abstract final class AppFonts {
  /// IBM Plex Sans Arabic — every body / label style in the design.
  static const String body = 'IBM Plex Sans Arabic';

  /// Cairo — the "بناء" wordmark only.
  static const String display = 'Cairo';
}

/// Type scale from the Figma export.
///
/// Every size goes through ScreenUtil (`.sp`) and every style carries the
/// design's 1.5 line-height, so text stays proportional at any window size.
abstract final class AppTextStyles {
  static TextStyle _base({
    required double fontSize,
    required FontWeight weight,
    Color color = AppColors.pureWhite,
    double height = 1.5,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: AppFonts.body,
      fontSize: fontSize.sp,
      height: height,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// Body/Regular — 16 / 24.
  static TextStyle get body16 => _base(fontSize: 16, weight: FontWeight.w400);

  /// Body/Regular — 16 / 24, muted (placeholder text).
  static TextStyle get body16Muted =>
      _base(fontSize: 16, weight: FontWeight.w400, color: AppColors.textMuted);

  /// Body/Regular — 18 / 27.
  static TextStyle get body18 => _base(fontSize: 18, weight: FontWeight.w400);

  /// Body/Bold — 18 / 27.
  static TextStyle get body18Bold =>
      _base(fontSize: 18, weight: FontWeight.w700);

  /// Header/3 — 24 / 36.
  static TextStyle get header3 => _base(
    fontSize: 24,
    weight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Screen title in the top bar (bold, gold).
  static TextStyle get screenTitle => _base(
    fontSize: 18,
    weight: FontWeight.w700,
    color: AppColors.gold,
  );

  /// Sidebar row label.
  static TextStyle get navLabel => _base(fontSize: 18, weight: FontWeight.w400);

  /// Sidebar row label, active tab (bold, gold).
  static TextStyle get navLabelActive => _base(
    fontSize: 18,
    weight: FontWeight.w700,
    color: AppColors.gold,
  );

  /// "بناء" wordmark — Cairo ExtraBold 58 / 87, tracking -1.45.
  ///
  /// Cairo ships as a variable font, so the weight is applied through
  /// `fontVariations` rather than a separate asset.
  static TextStyle get wordmark => TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 58.sp,
    // 1.35 keeps Cairo's ascenders inside the line box; the design's 1.5
    // line-height is applied to the 51pt text frame, not the glyphs.
    height: 1.35,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.45.sp,
    color: AppColors.gold,
    fontVariations: const [FontVariation('wght', 800)],
  );
}
