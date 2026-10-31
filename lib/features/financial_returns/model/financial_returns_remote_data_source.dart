import 'demo_returns.dart';
import 'financial_return.dart';
import 'financial_returns_payload.dart';

/// Read side of the returns data, shaped like a realtime query.
///
/// A [Stream] rather than a `Future` because the dashboard mirrors Firestore:
/// an edit in the admin page must repaint the table without a manual refresh.
abstract interface class FinancialReturnsRemoteDataSource {
  Stream<FinancialReturnsPayload> watch();
}

/// In-memory stand-in used by tests and by `--dart-define=USE_MOCK=true`.
///
/// Also the fallback on Linux desktop, where `cloud_firestore` has no
/// implementation.
class MockFinancialReturnsRemoteDataSource
    implements FinancialReturnsRemoteDataSource {
  MockFinancialReturnsRemoteDataSource({
    this.latency = const Duration(milliseconds: 350),
    List<FinancialReturn>? rows,
  }) : _rows = rows ?? kDemoFinancialReturns;

  /// Simulated network latency (set to [Duration.zero] in tests).
  final Duration latency;

  final List<FinancialReturn> _rows;

  @override
  Stream<FinancialReturnsPayload> watch() async* {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
    yield FinancialReturnsPayload(rows: _rows);
  }
}
