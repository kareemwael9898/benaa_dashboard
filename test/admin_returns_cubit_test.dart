import 'package:benaa_dashboard/features/admin/model/admin_returns_repository.dart';
import 'package:benaa_dashboard/features/admin/model/mock_admin_returns_repository.dart';
import 'package:benaa_dashboard/features/admin/view_model/admin_returns_cubit.dart';
import 'package:benaa_dashboard/features/admin/view_model/admin_returns_state.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_return.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_return_status.dart';
import 'package:flutter_test/flutter_test.dart';

FinancialReturn _newRow({num amount = 5000}) => FinancialReturn(
  id: '',
  cityId: 'الدمام',
  status: FinancialReturnStatus.pending,
  amount: amount,
  reference: 'RET-NEW',
  phone: '+966 55 000 0000',
  alternatePhone: '+966 55 000 0000',
);

void main() {
  late AdminReturnsCubit cubit;

  setUp(() {
    cubit = AdminReturnsCubit(MockAdminReturnsRepository());
  });

  tearDown(() => cubit.close());

  test('loads every row', () async {
    cubit.load();
    await pumpEventQueue();

    final AdminReturnsLoaded state = cubit.state as AdminReturnsLoaded;
    expect(state.rows, hasLength(3));
    expect(state.feedback, isNull);
  });

  test('create adds a row and reports success', () async {
    cubit.load();
    await pumpEventQueue();

    await cubit.create(_newRow());
    await pumpEventQueue();

    final AdminReturnsLoaded state = cubit.state as AdminReturnsLoaded;
    expect(state.rows, hasLength(4));
    expect(state.rows.first.reference, 'RET-NEW');
    expect(state.feedback?.isError, isFalse);
    expect(state.feedback?.message, 'تمت إضافة الصف.');
  });

  test('delete removes the row and reports success', () async {
    cubit.load();
    await pumpEventQueue();
    final String id = (cubit.state as AdminReturnsLoaded).rows.first.id;

    await cubit.delete(id);
    await pumpEventQueue();

    final AdminReturnsLoaded state = cubit.state as AdminReturnsLoaded;
    expect(state.rows, hasLength(2));
    expect(state.rows.any((FinancialReturn r) => r.id == id), isFalse);
    expect(state.feedback?.message, 'تم حذف الصف.');
  });

  test('consumeFeedback clears the message', () async {
    cubit.load();
    await pumpEventQueue();
    await cubit.create(_newRow());
    await pumpEventQueue();

    cubit.consumeFeedback();

    expect((cubit.state as AdminReturnsLoaded).feedback, isNull);
  });

  test('failed write surfaces an error message instead of a fake success', () async {
    final AdminReturnsCubit failing = AdminReturnsCubit(_ReadOnlyRepository());
    addTearDown(failing.close);

    failing.load();
    await pumpEventQueue();

    await failing.create(_newRow());

    final AdminReturnsLoaded state = failing.state as AdminReturnsLoaded;
    expect(state.rows, hasLength(3), reason: 'nothing was written');
    expect(state.feedback?.isError, isTrue);
    expect(state.feedback?.message, 'لا تملك صلاحية تعديل البيانات.');
  });

  test('a failing stream becomes a failure state', () async {
    final AdminReturnsCubit failing = AdminReturnsCubit(_OfflineRepository());
    addTearDown(failing.close);

    failing.load();
    await pumpEventQueue();

    expect(failing.state, isA<AdminReturnsFailure>());
  });
}

/// Reads fine, every write is denied — the shape of a signed-out client.
class _ReadOnlyRepository extends MockAdminReturnsRepository {
  @override
  Future<void> create(FinancialReturn row) async {
    throw const AdminDataException('لا تملك صلاحية تعديل البيانات.');
  }
}

class _OfflineRepository extends MockAdminReturnsRepository {
  @override
  Stream<List<FinancialReturn>> watchAll() =>
      Stream<List<FinancialReturn>>.error(Exception('offline'));
}
