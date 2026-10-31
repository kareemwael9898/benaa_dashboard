import 'package:cloud_firestore/cloud_firestore.dart';

import '../../financial_returns/model/demo_returns.dart';
import '../../financial_returns/model/financial_return.dart';
import '../../financial_returns/model/financial_return_mapper.dart';

/// Write-side repository for the admin page.
///
/// Separate from the dashboard's read-only `FinancialReturnsRepository` so the
/// public screen cannot accidentally gain write capability.
abstract interface class AdminReturnsRepository {
  /// Every row, newest first.
  Stream<List<FinancialReturn>> watchAll();

  Future<void> create(FinancialReturn row);

  Future<void> update(FinancialReturn row);

  Future<void> delete(String id);

  /// Writes [kDemoFinancialReturns]; returns how many documents were added.
  Future<int> seedDemoData();
}

/// Failures already translated into Arabic copy for the UI.
class AdminDataException implements Exception {
  const AdminDataException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FirestoreAdminReturnsRepository implements AdminReturnsRepository {
  FirestoreAdminReturnsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const FinancialReturnMapper _mapper = FinancialReturnMapper();

  CollectionReference<Map<String, dynamic>> get _returns =>
      _firestore.collection(FinancialReturnMapper.collection);

  @override
  Stream<List<FinancialReturn>> watchAll() {
    return _returns.snapshots().map((QuerySnapshot<Map<String, dynamic>> s) {
      return s.docs.map(_mapper.fromDoc).toList()
        ..sort(FinancialReturnMapper.newestFirst);
    });
  }

  @override
  Future<void> create(FinancialReturn row) {
    return _guard(() => _returns.add(_mapper.toCreateMap(row)));
  }

  @override
  Future<void> update(FinancialReturn row) {
    if (!row.isSaved) {
      throw const AdminDataException('لا يمكن تعديل صف لم يُحفظ بعد.');
    }
    return _guard(
      () => _returns.doc(row.id).update(_mapper.toUpdateMap(row)),
    );
  }

  @override
  Future<void> delete(String id) {
    return _guard(() => _returns.doc(id).delete());
  }

  @override
  Future<int> seedDemoData() async {
    final WriteBatch batch = _firestore.batch();
    for (final FinancialReturn row in kDemoFinancialReturns) {
      batch.set(_returns.doc(), _mapper.toCreateMap(row));
    }
    await _guard(() => batch.commit());
    return kDemoFinancialReturns.length;
  }

  /// Firestore errors are English and SDK-flavoured; the UI gets Arabic.
  Future<void> _guard(Future<Object?> Function() action) async {
    try {
      await action();
    } on FirebaseException catch (error) {
      throw AdminDataException(switch (error.code) {
        'permission-denied' => 'لا تملك صلاحية تعديل البيانات.',
        'unavailable' =>
          'تعذّر الوصول إلى الخادم، تحقّق من اتصالك ثم حاول مرة أخرى.',
        'not-found' => 'هذا الصف لم يعد موجودًا.',
        _ => 'تعذّر حفظ التغييرات، حاول مرة أخرى.',
      });
    }
  }
}
