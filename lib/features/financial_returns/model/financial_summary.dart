import 'package:flutter/foundation.dart';

/// One KPI tile above the returns table.
@immutable
class FinancialSummary {
  const FinancialSummary({required this.label, required this.value});

  /// e.g. "إجمالي المبلغ قبل الضربية".
  final String label;

  /// Formatted value, e.g. "10000 ريال".
  final String value;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'label': label,
    'value': value,
  };

  factory FinancialSummary.fromMap(Map<String, dynamic> map) =>
      FinancialSummary(
        label: map['label'] as String? ?? '',
        value: map['value'] as String? ?? '',
      );
}
