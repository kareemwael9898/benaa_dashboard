import 'package:benaa_dashboard/features/financial_returns/model/financial_return.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_return_status.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_returns_kpi_builder.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_summary.dart';
import 'package:flutter_test/flutter_test.dart';

FinancialReturn _row({
  required num amount,
  FinancialReturnStatus status = FinancialReturnStatus.active,
}) {
  return FinancialReturn(
    id: 'x',
    cityId: 'الدمام',
    status: status,
    amount: amount,
    reference: 'r',
    phone: 'p',
    alternatePhone: 'p',
  );
}

void main() {
  test('sums amounts and counts active rows', () {
    final List<FinancialSummary> summaries = buildFinancialSummaries(
      <FinancialReturn>[
        _row(amount: 10000),
        _row(amount: 7500, status: FinancialReturnStatus.pending),
        _row(amount: 4200),
      ],
    );

    expect(summaries.map((FinancialSummary s) => s.label), <String>[
      'إجمالي المبلغ',
      'عدد العوائد',
      'العوائد المفعّلة',
    ]);
    expect(summaries[0].value, '21,700 ريال');
    expect(summaries[1].value, '3');
    expect(summaries[2].value, '2');
  });

  test('handles an empty list without crashing', () {
    final List<FinancialSummary> summaries = buildFinancialSummaries(
      const <FinancialReturn>[],
    );

    expect(summaries[0].value, '0 ريال');
    expect(summaries[1].value, '0');
    expect(summaries[2].value, '0');
  });

  test('parses amounts as num, not just int', () {
    final List<FinancialSummary> summaries = buildFinancialSummaries(
      <FinancialReturn>[_row(amount: 1234.5), _row(amount: 0.5)],
    );

    expect(summaries[0].value, '1,235 ريال');
  });
}
