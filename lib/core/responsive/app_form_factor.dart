import 'package:flutter/widgets.dart';

/// Layout tiers for the dashboard.
///
/// Below [AppBreakpoints.wideMin] sizing is 1:1 (see `app.dart`): a design pixel
/// is a logical pixel, so fixed widths have to fit the real window and the
/// composition has to change. From [AppBreakpoints.wideMin] up the Figma frame
/// is reproduced unchanged, and from 1440 up it scales as a whole.
enum AppFormFactor { compact, medium, wide }

abstract final class AppBreakpoints {
  /// Under this width the shell becomes a drawer and every dense row becomes a
  /// card: phones, split-screen windows and small laptop windows.
  static const double mediumMin = 900;

  /// From here the frame fits at 1:1 — three 269pt pills need 855pt, plus the
  /// 280pt sidebar and the 48pt page padding.
  static const double wideMin = 1200;
}

AppFormFactor formFactorOf(double width) {
  if (width < AppBreakpoints.mediumMin) return AppFormFactor.compact;
  if (width < AppBreakpoints.wideMin) return AppFormFactor.medium;
  return AppFormFactor.wide;
}

extension AppFormFactorContext on BuildContext {
  AppFormFactor get formFactor => formFactorOf(MediaQuery.sizeOf(this).width);

  bool get isCompactLayout => formFactor == AppFormFactor.compact;

  bool get isWideLayout => formFactor == AppFormFactor.wide;
}
