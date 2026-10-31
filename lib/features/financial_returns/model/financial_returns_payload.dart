import 'package:flutter/foundation.dart';

import 'financial_return.dart';

/// The payload the returns screen renders.
///
/// Only rows: the KPI tiles are derived from them by
/// `buildFinancialSummaries`, so there is nothing else to carry or cache.
@immutable
class FinancialReturnsPayload {
  const FinancialReturnsPayload({required this.rows});

  final List<FinancialReturn> rows;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'returns': rows.map((FinancialReturn row) => row.toMap()).toList(),
  };

  factory FinancialReturnsPayload.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rows = map['returns'] as List<dynamic>? ?? <dynamic>[];
    return FinancialReturnsPayload(
      rows: rows
          .map(
            (dynamic row) => FinancialReturn.fromMap(row as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
