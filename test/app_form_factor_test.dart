import 'package:benaa_dashboard/core/responsive/app_form_factor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formFactorOf', () {
    test('phones and narrow windows are compact', () {
      for (final double width in <double>[320, 390, 430, 599, 768, 844, 899]) {
        expect(formFactorOf(width), AppFormFactor.compact, reason: '$width');
      }
    });

    test('tablets and up use the frame', () {
      for (final double width in <double>[900, 1024, 1180, 1440, 1920]) {
        expect(formFactorOf(width), AppFormFactor.desktop, reason: '$width');
      }
    });

    test('the boundary belongs to the frame', () {
      expect(formFactorOf(AppBreakpoints.desktopMin - 0.1), AppFormFactor.compact);
      expect(formFactorOf(AppBreakpoints.desktopMin), AppFormFactor.desktop);
    });
  });
}
