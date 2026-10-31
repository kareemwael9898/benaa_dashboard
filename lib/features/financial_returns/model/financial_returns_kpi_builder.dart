import '../../../core/utils/amount_format.dart';
import 'financial_return.dart';
import 'financial_return_status.dart';
import 'financial_summary.dart';

/// Builds the three KPI tiles from the rows currently on screen.
///
/// Derived, never stored: a tile can't drift away from the table beneath it,
/// and editing a row in the admin page moves the numbers immediately.
List<FinancialSummary> buildFinancialSummaries(List<FinancialReturn> rows) {
  final num total = rows.fold<num>(
    0,
    (num sum, FinancialReturn row) => sum + row.amount,
  );
  final int active = rows
      .where((FinancialReturn row) => row.status == FinancialReturnStatus.active)
      .length;

  return <FinancialSummary>[
    FinancialSummary(
      label: 'إجمالي المبلغ',
      value: '${formatAmount(total)} ريال',
    ),
    FinancialSummary(label: 'عدد العوائد', value: formatAmount(rows.length)),
    FinancialSummary(label: 'العوائد المفعّلة', value: formatAmount(active)),
  ];
}
