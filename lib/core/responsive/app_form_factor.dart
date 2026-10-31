import 'package:flutter/widgets.dart';

/// Layout tiers for the dashboard.
///
/// Below [AppBreakpoints.desktopMin] the UI is laid out at 1:1 (see `app.dart`):
/// a design pixel is a logical pixel, so fixed widths have to fit the real
/// window and the composition changes. From [AppBreakpoints.desktopMin] up the
/// Figma frame is used as designed and ScreenUtil scales the whole canvas by
/// `width / 1440`, which is what it always did.
enum AppFormFactor { compact, desktop }

abstract final class AppBreakpoints {
  /// Under this width the sidebar moves into a drawer, the filters and KPI
  /// tiles stack and every table row becomes a card: phones, split-screen
  /// windows and very narrow browser windows.
  ///
  /// From here up the frame is drawn as designed — proportional scaling keeps
  /// the 269pt pills, the 280pt sidebar and the five-column grid fitting.
  static const double desktopMin = 900;
}

AppFormFactor formFactorOf(double width) => width < AppBreakpoints.desktopMin
    ? AppFormFactor.compact
    : AppFormFactor.desktop;

extension AppFormFactorContext on BuildContext {
  AppFormFactor get formFactor => formFactorOf(MediaQuery.sizeOf(this).width);

  bool get isCompactLayout => formFactor == AppFormFactor.compact;

  bool get isDesktopLayout => formFactor == AppFormFactor.desktop;
}
