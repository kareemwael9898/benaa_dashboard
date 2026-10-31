import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../financial_returns/model/financial_return.dart';
import '../model/admin_returns_repository.dart';
import 'admin_returns_state.dart';

/// CRUD + live list for the admin page.
///
/// Writes are awaited (so the user learns immediately when Firestore rejects
/// them) and the list itself is refreshed by the snapshot stream — never
/// patched locally, which is what keeps the table honest.
class AdminReturnsCubit extends Cubit<AdminReturnsState> {
  AdminReturnsCubit(this._repository) : super(const AdminReturnsInitial());

  final AdminReturnsRepository _repository;
  StreamSubscription<List<FinancialReturn>>? _subscription;
  int _pendingWrites = 0;

  void load() {
    unawaited(_subscription?.cancel());
    emit(const AdminReturnsLoading());

    _subscription = _repository.watchAll().listen(
      (List<FinancialReturn> rows) {
        if (isClosed) return;
        emit(AdminReturnsLoaded(rows: rows));
      },
      onError: (Object _) {
        if (isClosed) return;
        emit(
          const AdminReturnsFailure(
            message: 'تعذّر تحميل العوائد. تحقّق من اتصالك ثم أعد المحاولة.',
          ),
        );
      },
    );
  }

  Future<void> create(FinancialReturn row) => _write(
    () => _repository.create(row),
    success: 'تمت إضافة الصف.',
  );

  Future<void> update(FinancialReturn row) => _write(
    () => _repository.update(row),
    success: 'تم تحديث الصف.',
  );

  Future<void> delete(String id) => _write(
    () => _repository.delete(id),
    success: 'تم حذف الصف.',
  );

  Future<void> seedDemoData() => _write(
    () async {
      final int count = await _repository.seedDemoData();
      if (count == 0) {
        throw const AdminDataException('لا توجد بيانات تجريبية لإضافتها.');
      }
    },
    success: 'تمت إضافة البيانات التجريبية.',
  );

  /// True while a write is in flight — drives the button spinners.
  bool get isBusy => _pendingWrites > 0;

  void consumeFeedback() {
    final AdminReturnsState current = state;
    if (current is AdminReturnsLoaded && current.feedback != null) {
      emit(current.withFeedback(null));
    }
  }

  Future<void> _write(
    Future<void> Function() action, {
    required String success,
  }) async {
    _pendingWrites++;
    try {
      await action();
      _emitFeedback(AdminFeedback(success));
    } on AdminDataException catch (error) {
      _emitFeedback(AdminFeedback(error.message, isError: true));
    } catch (_) {
      _emitFeedback(
        const AdminFeedback('تعذّر حفظ التغييرات، حاول مرة أخرى.', isError: true),
      );
    } finally {
      _pendingWrites--;
    }
  }

  void _emitFeedback(AdminFeedback feedback) {
    final AdminReturnsState current = state;
    if (isClosed) return;
    if (current is AdminReturnsLoaded) {
      emit(current.withFeedback(feedback));
    }
    // While loading/failed there is no list to attach a message to; the failure
    // view already explains what is wrong.
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
