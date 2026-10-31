import 'package:flutter/foundation.dart';

/// A single row of the financial-returns table.
///
/// The Figma frame only defines placeholder cell content ("____ ريال",
/// "#/#/#", a repeated phone number), so the fields are kept as display
/// strings. Swap them for typed values (`num amount`, `DateTime createdAt`, …)
/// once the real payload is known.
@immutable
class FinancialReturn {
  const FinancialReturn({
    required this.id,
    required this.cityId,
    required this.statusLabel,
    required this.amountLabel,
    required this.reference,
    required this.phone,
    required this.alternatePhone,
  });

  final String id;

  /// Used by the city filter.
  final String cityId;

  /// "مفعل" — rendered inside the green chip.
  final String statusLabel;

  /// "____ ريال".
  final String amountLabel;

  /// "#/#/#".
  final String reference;

  /// "+966 50 123 4567".
  final String phone;

  /// Second phone column in the design (same placeholder value).
  final String alternatePhone;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'cityId': cityId,
    'statusLabel': statusLabel,
    'amountLabel': amountLabel,
    'reference': reference,
    'phone': phone,
    'alternatePhone': alternatePhone,
  };

  factory FinancialReturn.fromMap(Map<String, dynamic> map) => FinancialReturn(
    id: map['id'] as String? ?? '',
    cityId: map['cityId'] as String? ?? '',
    statusLabel: map['statusLabel'] as String? ?? '',
    amountLabel: map['amountLabel'] as String? ?? '',
    reference: map['reference'] as String? ?? '',
    phone: map['phone'] as String? ?? '',
    alternatePhone: map['alternatePhone'] as String? ?? '',
  );
}
