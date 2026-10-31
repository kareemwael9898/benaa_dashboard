import '../model/financial_return.dart';
import '../model/financial_returns_kpi_builder.dart';
import '../model/financial_summary.dart';
import '../model/return_filter_field.dart';

/// States of the financial-returns feature.
///
/// Every state carries the filter row so the dropdowns stay interactive while
/// data loads or fails — the design always shows them.
sealed class FinancialReturnsState {
  const FinancialReturnsState({required this.filters});

  final List<ReturnFilterField> filters;

  /// The last dropdown is the city filter (the design repeats the same field
  /// three times); it is the only one the query honours.
  String? get selectedCity => filters.isEmpty ? null : filters.last.value;

  /// Applies [selectedCity] to [rows].
  List<FinancialReturn> filterRows(List<FinancialReturn> rows) {
    final String? city = selectedCity;
    if (city == null || city.isEmpty) return rows;
    return rows
        .where((FinancialReturn row) => row.cityId == city)
        .toList();
  }
}

final class FinancialReturnsInitial extends FinancialReturnsState {
  const FinancialReturnsInitial({
    super.filters = kReturnFilterFields,
  });
}

final class FinancialReturnsLoading extends FinancialReturnsState {
  const FinancialReturnsLoading({required super.filters});
}

/// Holds every row from the source; the visible subset and the KPI tiles are
/// derived, so changing a filter is a pure re-read — no extra fetch.
final class FinancialReturnsLoaded extends FinancialReturnsState {
  const FinancialReturnsLoaded({
    required super.filters,
    required this.rows,
  });

  /// Unfiltered rows, newest first.
  final List<FinancialReturn> rows;

  List<FinancialReturn> get returns => filterRows(rows);

  List<FinancialSummary> get summaries => buildFinancialSummaries(returns);
}

final class FinancialReturnsFailure extends FinancialReturnsState {
  const FinancialReturnsFailure({
    required super.filters,
    required this.message,
  });

  final String message;
}
