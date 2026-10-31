import 'package:flutter/foundation.dart';

import 'financial_return.dart';
import 'financial_summary.dart';

/// The payload the returns screen renders.
@immutable
class FinancialReturnsPayload {
  const FinancialReturnsPayload({
    required this.summaries,
    required this.returns,
  });

  final List<FinancialSummary> summaries;
  final List<FinancialReturn> returns;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'summaries': summaries.map((FinancialSummary s) => s.toMap()).toList(),
    'returns': returns.map((FinancialReturn r) => r.toMap()).toList(),
  };

  factory FinancialReturnsPayload.fromMap(Map<String, dynamic> map) {
    final List<dynamic> summaries =
        map['summaries'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> returns = map['returns'] as List<dynamic>? ?? <dynamic>[];
    return FinancialReturnsPayload(
      summaries: summaries
          .map((dynamic e) => FinancialSummary.fromMap(e as Map<String, dynamic>))
          .toList(),
      returns: returns
          .map((dynamic e) => FinancialReturn.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
