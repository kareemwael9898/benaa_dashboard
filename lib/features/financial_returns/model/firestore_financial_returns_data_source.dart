import 'package:cloud_firestore/cloud_firestore.dart';

import 'financial_return.dart';
import 'financial_return_mapper.dart';
import 'financial_returns_payload.dart';
import 'financial_returns_remote_data_source.dart';

/// Realtime Firestore source for the dashboard.
///
/// Sorting is done in Dart rather than with `orderBy('createdAt')`: a document
/// written with `FieldValue.serverTimestamp()` has a pending (null) timestamp
/// in the local snapshot, and an ordered query would hide it until the write
/// round-trips. Client-side sorting keeps a new row visible immediately and
/// needs no composite index.
class FirestoreFinancialReturnsRemoteDataSource
    implements FinancialReturnsRemoteDataSource {
  FirestoreFinancialReturnsRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  static const FinancialReturnMapper _mapper = FinancialReturnMapper();

  @override
  Stream<FinancialReturnsPayload> watch() {
    return _firestore
        .collection(FinancialReturnMapper.collection)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          final List<FinancialReturn> rows = snapshot.docs
              .map(_mapper.fromDoc)
              .toList()
            ..sort(FinancialReturnMapper.newestFirst);
          return FinancialReturnsPayload(rows: rows);
        });
  }
}
