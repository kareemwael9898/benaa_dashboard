import 'financial_return.dart';
import 'financial_return_status.dart';

/// Rows written by the "إضافة بيانات تجريبية" button in the admin page and
/// served by the mock source.
///
/// The first entry mirrors the Figma frame exactly (`#/#/#`, repeated phone).
/// The other two are the smallest addition that makes the city filter and the
/// KPI sums demonstrable instead of trivially "1 row".
const List<FinancialReturn> kDemoFinancialReturns = <FinancialReturn>[
  FinancialReturn(
    id: '',
    cityId: 'الدمام',
    status: FinancialReturnStatus.active,
    amount: 10000,
    reference: '#/#/#',
    phone: '+966 50 123 4567',
    alternatePhone: '+966 50 123 4567',
  ),
  FinancialReturn(
    id: '',
    cityId: 'الدمام',
    status: FinancialReturnStatus.pending,
    amount: 7500,
    reference: 'RET-1002',
    phone: '+966 55 441 8890',
    alternatePhone: '+966 55 441 8890',
  ),
  FinancialReturn(
    id: '',
    cityId: 'الرياض',
    status: FinancialReturnStatus.active,
    amount: 4200,
    reference: 'RET-1003',
    phone: '+966 53 907 2214',
    alternatePhone: '+966 53 907 2214',
  ),
];
