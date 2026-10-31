import 'package:benaa_dashboard/core/responsive/app_form_factor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formFactorOf', () {
    test('phones and small windows are compact', () {
      for (final double width in <double>[320, 390, 430, 599, 768, 899]) {
        expect(formFactorOf(width), AppFormFactor.compact, reason: '$width');
      }
    });

    test('tablets and narrow desktop windows are medium', () {
      for (final double width in <double>[900, 1024, 1100, 1199]) {
        expect(formFactorOf(width), AppFormFactor.medium, reason: '$width');
      }
    });

    test('the design width and above are wide', () {
      for (final double width in <double>[1200, 1280, 1440, 1920]) {
        expect(formFactorOf(width), AppFormFactor.wide, reason: '$width');
      }
    });

    test('the boundary values belong to the wider tier', () {
      expect(
        formFactorOf(AppBreakpoints.mediumMin - 0.1),
        AppFormFactor.compact,
      );
      expect(formFactorOf(AppBreakpoints.mediumMin), AppFormFactor.medium);
      expect(formFactorOf(AppBreakpoints.wideMin - 0.1), AppFormFactor.medium);
      expect(formFactorOf(AppBreakpoints.wideMin), AppFormFactor.wide);
    });
  });
}
