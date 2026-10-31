import 'dart:async';

import '../../financial_returns/model/demo_returns.dart';
import '../../financial_returns/model/financial_return.dart';
import '../model/admin_returns_repository.dart';

/// In-memory admin repository for `--dart-define=USE_MOCK=true`, tests and the
/// Linux desktop build. Behaves like the Firestore one: mutations re-emit the
/// full list through the same stream the UI listens to.
class MockAdminReturnsRepository implements AdminReturnsRepository {
  MockAdminReturnsRepository({List<FinancialReturn>? rows}) {
    final List<FinancialReturn> seed = rows ?? kDemoFinancialReturns;
    for (final FinancialReturn row in seed) {
      _rows.add(
        FinancialReturn(
          id: row.id.isEmpty ? _nextId() : row.id,
          cityId: row.cityId,
          status: row.status,
          amount: row.amount,
          reference: row.reference,
          phone: row.phone,
          alternatePhone: row.alternatePhone,
          createdAt: row.createdAt ?? DateTime.now(),
        ),
      );
    }
  }

  final List<FinancialReturn> _rows = <FinancialReturn>[];
  final StreamController<List<FinancialReturn>> _changes =
      StreamController<List<FinancialReturn>>.broadcast();
  int _sequence = 0;

  String _nextId() => 'mock-${++_sequence}';

  @override
  Stream<List<FinancialReturn>> watchAll() async* {
    yield _snapshot();
    yield* _changes.stream;
  }

  @override
  Future<void> create(FinancialReturn row) async {
    _rows.insert(
      0,
      FinancialReturn(
        id: _nextId(),
        cityId: row.cityId,
        status: row.status,
        amount: row.amount,
        reference: row.reference,
        phone: row.phone,
        alternatePhone: row.alternatePhone,
        createdAt: DateTime.now(),
      ),
    );
    _emit();
  }

  @override
  Future<void> update(FinancialReturn row) async {
    final int index = _rows.indexWhere((FinancialReturn r) => r.id == row.id);
    if (index == -1) {
      throw const AdminDataException('هذا الصف لم يعد موجودًا.');
    }
    _rows[index] = row;
    _emit();
  }

  @override
  Future<void> delete(String id) async {
    _rows.removeWhere((FinancialReturn row) => row.id == id);
    _emit();
  }

  @override
  Future<int> seedDemoData() async {
    for (final FinancialReturn row in kDemoFinancialReturns) {
      await create(row);
    }
    return kDemoFinancialReturns.length;
  }

  List<FinancialReturn> _snapshot() => List<FinancialReturn>.unmodifiable(_rows);

  void _emit() {
    if (!_changes.isClosed) _changes.add(_snapshot());
  }
}
