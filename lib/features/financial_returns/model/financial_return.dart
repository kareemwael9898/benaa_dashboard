import 'package:flutter/foundation.dart';

import '../../../core/utils/amount_format.dart';
import 'financial_return_status.dart';

/// A single row of the financial-returns table.
///
/// Values are typed (not display strings): the KPI tiles are summed from
/// [amount], so the number has to be a number. The label getters do the
/// formatting once, for both the table and the PDF.
@immutable
class FinancialReturn {
  const FinancialReturn({
    required this.id,
    required this.cityId,
    required this.status,
    required this.amount,
    required this.reference,
    required this.phone,
    required this.alternatePhone,
    this.createdAt,
  });

  /// Firestore document id (empty for a row that hasn't been saved yet).
  final String id;

  /// Drives the city filter; must be one of the filter options.
  final String cityId;

  final FinancialReturnStatus status;

  /// Amount in riyals.
  final num amount;

  final String reference;
  final String phone;
  final String alternatePhone;

  /// Set by the server on create; used for newest-first ordering.
  final DateTime? createdAt;

  String get statusLabel => status.label;

  /// "10,000 ريال".
  String get amountLabel => '${formatAmount(amount)} ريال';

  bool get isSaved => id.isNotEmpty;

  /// JSON-safe map, used by the Hive cache. Firestore mapping lives in the
  /// data layer so this entity stays dependency-free.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'cityId': cityId,
    'status': status.name,
    'amount': amount,
    'reference': reference,
    'phone': phone,
    'alternatePhone': alternatePhone,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory FinancialReturn.fromMap(Map<String, dynamic> map) => FinancialReturn(
    id: map['id'] as String? ?? '',
    cityId: map['cityId'] as String? ?? '',
    status: FinancialReturnStatus.fromName(map['status'] as String?),
    amount: map['amount'] as num? ?? 0,
    reference: map['reference'] as String? ?? '',
    phone: map['phone'] as String? ?? '',
    alternatePhone: map['alternatePhone'] as String? ?? '',
    createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
  );
}
