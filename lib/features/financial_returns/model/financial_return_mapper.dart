import 'package:cloud_firestore/cloud_firestore.dart';

import 'financial_return.dart';

/// Firestore ⇄ entity mapping for the `returns` collection.
///
/// Kept out of [FinancialReturn] so the entity stays free of plugin imports and
/// remains trivially testable.
class FinancialReturnMapper {
  const FinancialReturnMapper();

  static const String collection = 'returns';

  FinancialReturn fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = Map<String, dynamic>.of(
      doc.data() ?? const <String, dynamic>{},
    );
    data['id'] = doc.id;

    // Timestamps are stored as Firestore timestamps, but the entity (and the
    // Hive cache) speak ISO-8601 strings.
    final Object? createdAt = data['createdAt'];
    if (createdAt is Timestamp) {
      data['createdAt'] = createdAt.toDate().toIso8601String();
    }

    return FinancialReturn.fromMap(data);
  }

  /// Fields written on create — `createdAt` is stamped by the server so
  /// ordering never depends on the device clock.
  Map<String, Object?> toCreateMap(FinancialReturn row) =>
      <String, Object?>{..._writableFields(row), 'createdAt': FieldValue.serverTimestamp()};

  Map<String, Object?> toUpdateMap(FinancialReturn row) => _writableFields(row);

  /// Newest first; a document whose `createdAt` is still pending (written with
  /// `serverTimestamp` and not yet acknowledged) counts as newest.
  static int newestFirst(FinancialReturn a, FinancialReturn b) {
    final DateTime? left = a.createdAt;
    final DateTime? right = b.createdAt;
    if (left == null && right == null) return a.id.compareTo(b.id);
    if (left == null) return -1;
    if (right == null) return 1;
    return right.compareTo(left);
  }

  Map<String, Object?> _writableFields(FinancialReturn row) => <String, Object?>{
    'cityId': row.cityId,
    'status': row.status.name,
    'amount': row.amount,
    'reference': row.reference,
    'phone': row.phone,
    'alternatePhone': row.alternatePhone,
  };
}
