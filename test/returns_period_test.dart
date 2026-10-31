import 'package:benaa_dashboard/features/financial_returns/model/returns_period.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixed "now" so every expectation is a calendar fact, not a race with the
/// machine clock.
final DateTime _now = DateTime(2026, 10, 31, 13, 30);

DateTime _on(int year, int month, int day) => DateTime(year, month, day, 9);

void main() {
  group('matchesPeriod', () {
    test('الكل matches everything, including rows with no date', () {
      expect(matchesPeriod(_on(2020, 1, 1), ReturnsPeriod.all, _now), isTrue);
      expect(matchesPeriod(null, ReturnsPeriod.all, _now), isTrue);
    });

    test('a row with no date is only visible under الكل', () {
      for (final ReturnsPeriod period in <ReturnsPeriod>[
        ReturnsPeriod.thisMonth,
        ReturnsPeriod.lastThreeMonths,
        ReturnsPeriod.thisYear,
      ]) {
        expect(matchesPeriod(null, period, _now), isFalse, reason: period.name);
      }
    });

    test('هذا الشهر keeps the current calendar month only', () {
      expect(
        matchesPeriod(_on(2026, 10, 1), ReturnsPeriod.thisMonth, _now),
        isTrue,
      );
      expect(
        matchesPeriod(_on(2026, 10, 31), ReturnsPeriod.thisMonth, _now),
        isTrue,
      );
      expect(
        matchesPeriod(_on(2026, 9, 30), ReturnsPeriod.thisMonth, _now),
        isFalse,
      );
      expect(
        matchesPeriod(_on(2025, 10, 15), ReturnsPeriod.thisMonth, _now),
        isFalse,
        reason: 'same month, wrong year',
      );
    });

    test('آخر ٣ أشهر is this month plus the two before it', () {
      expect(
        matchesPeriod(_on(2026, 8, 1), ReturnsPeriod.lastThreeMonths, _now),
        isTrue,
      );
      expect(
        matchesPeriod(
          _on(2026, 8, 1).subtract(const Duration(days: 1)),
          ReturnsPeriod.lastThreeMonths,
          _now,
        ),
        isFalse,
        reason: 'July is the fourth month back',
      );
      expect(
        matchesPeriod(_on(2026, 10, 20), ReturnsPeriod.lastThreeMonths, _now),
        isTrue,
      );
    });

    test('آخر ٣ أشهر crosses the new year', () {
      final DateTime january = DateTime(2027, 1, 10);
      expect(
        matchesPeriod(
          _on(2026, 12, 20),
          ReturnsPeriod.lastThreeMonths,
          january,
        ),
        isTrue,
      );
      expect(
        matchesPeriod(
          _on(2026, 10, 31),
          ReturnsPeriod.lastThreeMonths,
          january,
        ),
        isFalse,
        reason: 'November 2026 is the third month back from January',
      );
    });

    test('هذا العام keeps the calendar year', () {
      expect(
        matchesPeriod(_on(2026, 1, 1), ReturnsPeriod.thisYear, _now),
        isTrue,
      );
      expect(
        matchesPeriod(_on(2025, 12, 31), ReturnsPeriod.thisYear, _now),
        isFalse,
      );
    });

    test('a UTC timestamp is placed by its local calendar day', () {
      // The row is stored as UTC but the reader thinks in local days, so the
      // filter must convert before comparing.
      final DateTime local = DateTime(2026, 10, 1, 1);
      expect(
        matchesPeriod(local.toUtc(), ReturnsPeriod.thisMonth, _now),
        isTrue,
        reason: 'toUtc() then toLocal() must round-trip to October',
      );
    });
  });

  group('periodFromLabel', () {
    test('round-trips every option', () {
      for (final ReturnsPeriod period in ReturnsPeriod.values) {
        expect(periodFromLabel(period.label), period);
      }
    });

    test('an unknown label falls back to الكل instead of hiding rows', () {
      expect(periodFromLabel('الأسبوع الماضي'), ReturnsPeriod.all);
    });

    test('options follow the enum order', () {
      expect(periodFilterOptions, <String>[
        'الكل',
        'هذا الشهر',
        'آخر ٣ أشهر',
        'هذا العام',
      ]);
    });
  });
}
