import 'package:benaa_dashboard/features/financial_returns/model/financial_return.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_return_status.dart';
import 'package:benaa_dashboard/features/financial_returns/model/returns_filters.dart';
import 'package:flutter_test/flutter_test.dart';

FinancialReturn _row({
  String cityId = 'الدمام',
  String phone = '+966 50 123 4567',
  String alternatePhone = '+966 50 765 4321',
}) {
  return FinancialReturn(
    id: 'r',
    cityId: cityId,
    status: FinancialReturnStatus.active,
    amount: 1,
    reference: 'REF',
    phone: phone,
    alternatePhone: alternatePhone,
  );
}

void main() {
  group('normalizePhone', () {
    test('strips spaces, punctuation, country code and trunk zero', () {
      for (final String raw in <String>[
        '+966 50 123 4567',
        '00966501234567',
        '0501234567',
        '501234567',
        '(05) 0123-4567',
      ]) {
        expect(normalizePhone(raw), '501234567', reason: raw);
      }
    });

    test('handles Arabic-Indic digits', () {
      expect(normalizePhone('٠٥٠١٢٣٤٥٦٧'), '501234567');
      expect(normalizePhone('۰۵۰۱۲۳۴۵۶۷'), '501234567');
    });

    test('returns an empty string when there are no digits', () {
      expect(normalizePhone('لا شيء'), '');
    });
  });

  group('matchesPhoneQuery', () {
    final FinancialReturn row = _row();

    test('an empty or blank query matches everything', () {
      expect(matchesPhoneQuery(row, ''), isTrue);
      expect(matchesPhoneQuery(row, '   '), isTrue);
    });

    test('matches any spelling of the same number', () {
      for (final String query in <String>[
        '0501234567',
        '501234567',
        '+966 50 123 4567',
        '٠٥٠١٢٣٤٥٦٧',
        '0123',
      ]) {
        expect(matchesPhoneQuery(row, query), isTrue, reason: query);
      }
    });

    test('matches the alternate phone too', () {
      expect(matchesPhoneQuery(row, '0507654321'), isTrue);
    });

    test('does not match an unrelated number', () {
      expect(matchesPhoneQuery(row, '0599999999'), isFalse);
    });
  });

  group('cityOf', () {
    test('blank city becomes the uncategorised bucket', () {
      expect(cityOf(_row(cityId: '')), kUncategorisedCity);
      expect(cityOf(_row(cityId: '   ')), kUncategorisedCity);
    });

    test('known city passes through', () {
      expect(cityOf(_row(cityId: 'جدة')), 'جدة');
    });
  });

  group('matchesCity', () {
    test('الكل accepts every row', () {
      expect(matchesCity(_row(cityId: 'جدة'), kAllCities), isTrue);
    });

    test('a city only matches itself', () {
      expect(matchesCity(_row(cityId: 'جدة'), 'جدة'), isTrue);
      expect(matchesCity(_row(cityId: 'جدة'), 'الدمام'), isFalse);
    });

    test('the uncategorised bucket is selectable', () {
      expect(matchesCity(_row(cityId: ''), kUncategorisedCity), isTrue);
    });
  });

  group('cityOptionsFor', () {
    test('الكل comes first, then the known cities', () {
      final List<String> options = cityOptionsFor(
        <FinancialReturn>[_row()],
        kAllCities,
      );

      expect(options.first, kAllCities);
      expect(options.take(1 + kKnownCities.length), <String>[
        kAllCities,
        ...kKnownCities,
      ]);
    });

    test('cities that only exist in the data are appended and sorted', () {
      final List<String> options = cityOptionsFor(
        <FinancialReturn>[
          _row(cityId: 'الخبر'),
          _row(cityId: 'أبها'),
        ],
        kAllCities,
      );

      expect(options, containsAll(<String>['الخبر', 'أبها']));
      final int firstExtra = 1 + kKnownCities.length;
      expect(options.sublist(firstExtra), <String>['أبها', 'الخبر']);
    });

    test('the uncategorised bucket appears only when a row needs it', () {
      expect(
        cityOptionsFor(<FinancialReturn>[_row()], kAllCities),
        isNot(contains(kUncategorisedCity)),
      );
      expect(
        cityOptionsFor(<FinancialReturn>[_row(cityId: '')], kAllCities),
        contains(kUncategorisedCity),
      );
    });

    test('the current selection is never dropped from the list', () {
      final List<String> options = cityOptionsFor(
        <FinancialReturn>[_row(cityId: 'جدة')],
        'مدينة محذوفة',
      );

      expect(options, contains('مدينة محذوفة'));
    });

    test('no duplicates when a known city is also in the data', () {
      final List<String> options = cityOptionsFor(
        <FinancialReturn>[_row(cityId: 'جدة'), _row(cityId: 'جدة')],
        kAllCities,
      );

      expect(options.where((String c) => c == 'جدة'), hasLength(1));
    });
  });
}
