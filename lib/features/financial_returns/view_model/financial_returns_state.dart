import '../model/financial_return.dart';
import '../model/financial_returns_kpi_builder.dart';
import '../model/financial_summary.dart';
import '../model/returns_filters.dart';

/// States of the financial-returns feature.
///
/// The filter is a single city plus an optional phone search, carried by every
/// state so the controls stay usable while data loads or fails. The three pills
/// on screen are three views of [selectedCity] — they can never disagree.
sealed class FinancialReturnsState {
  const FinancialReturnsState({
    required this.selectedCity,
    required this.query,
  });

  /// [kAllCities] or one of the cities in [FinancialReturnsLoaded.cityOptions].
  final String selectedCity;

  /// Raw text of the phone search field.
  final String query;

  bool get hasActiveFilters =>
      selectedCity != kAllCities || query.trim().isNotEmpty;
}

final class FinancialReturnsInitial extends FinancialReturnsState {
  const FinancialReturnsInitial({
    super.selectedCity = kAllCities,
    super.query = '',
  });
}

final class FinancialReturnsLoading extends FinancialReturnsState {
  const FinancialReturnsLoading({
    super.selectedCity = kAllCities,
    super.query = '',
  });
}

/// Holds every row from the source; the visible subset and the KPI tiles are
/// derived, so changing a filter is a pure re-read — no extra fetch.
final class FinancialReturnsLoaded extends FinancialReturnsState {
  const FinancialReturnsLoaded({
    required this.rows,
    super.selectedCity = kAllCities,
    super.query = '',
  });

  /// Unfiltered rows, newest first.
  final List<FinancialReturn> rows;

  List<FinancialReturn> get returns => rows
      .where(
        (FinancialReturn row) =>
            matchesCity(row, selectedCity) &&
            matchesPhoneQuery(row, query),
      )
      .toList();

  List<String> get cityOptions => cityOptionsFor(rows, selectedCity);

  List<FinancialSummary> get summaries => buildFinancialSummaries(returns);
}

final class FinancialReturnsFailure extends FinancialReturnsState {
  const FinancialReturnsFailure({
    required this.message,
    super.selectedCity = kAllCities,
    super.query = '',
  });

  final String message;
}
