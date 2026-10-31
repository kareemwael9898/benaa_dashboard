import 'financial_return.dart';
import 'financial_returns_payload.dart';
import 'financial_summary.dart';

/// Remote source for the returns screen.
///
/// Shaped like a serverless query (`fetch(cityId)`) so a Firebase/Supabase
/// implementation can replace [MockFinancialReturnsRemoteDataSource] without
/// touching the cubit or the view.
abstract interface class FinancialReturnsRemoteDataSource {
  Future<FinancialReturnsPayload> fetch({String? cityId});
}

/// In-memory stand-in for the real endpoint.
///
/// Values are the placeholders that appear in the Figma frame.
class MockFinancialReturnsRemoteDataSource
    implements FinancialReturnsRemoteDataSource {
  MockFinancialReturnsRemoteDataSource({this.latency = const Duration(milliseconds: 350)});

  /// Simulated network latency (set to [Duration.zero] in tests).
  final Duration latency;

  static const FinancialSummary _kpi = FinancialSummary(
    label: 'إجمالي المبلغ قبل الضربية',
    value: '10000 ريال',
  );

  static const List<FinancialReturn> _rows = <FinancialReturn>[
    FinancialReturn(
      id: 'row-1',
      cityId: 'الدمام',
      statusLabel: 'مفعل',
      amountLabel: '____ ريال',
      reference: '#/#/#',
      phone: '+966 50 123 4567',
      alternatePhone: '+966 50 123 4567',
    ),
  ];

  @override
  Future<FinancialReturnsPayload> fetch({String? cityId}) async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }

    final List<FinancialReturn> filtered = cityId == null || cityId.isEmpty
        ? _rows
        : _rows.where((FinancialReturn row) => row.cityId == cityId).toList();

    return FinancialReturnsPayload(
      summaries: const <FinancialSummary>[_kpi, _kpi, _kpi],
      returns: filtered,
    );
  }
}
