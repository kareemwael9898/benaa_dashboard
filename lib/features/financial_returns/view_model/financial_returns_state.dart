import '../model/financial_return.dart';
import '../model/financial_return_status.dart';
import '../model/financial_returns_kpi_builder.dart';
import '../model/financial_summary.dart';
import '../model/returns_filters.dart';
import '../model/returns_period.dart';

/// States of the financial-returns feature.
///
/// The filter row is a city, a status, a period and an optional phone search.
/// All four travel with every state, so the controls stay usable while data
/// loads or fails — and a reconnect can never drop the user's selection.
sealed class FinancialReturnsState {
  const FinancialReturnsState({
    required this.selectedCity,
    required this.query,
    this.selectedStatus,
    this.selectedPeriod = ReturnsPeriod.all,
  });

  /// [kAllCities] or one of the cities in [FinancialReturnsLoaded.cityOptions].
  final String selectedCity;

  /// Raw text of the phone search field.
  final String query;

  /// `null` means every status.
  final FinancialReturnStatus? selectedStatus;

  /// Date window applied to `createdAt`; [ReturnsPeriod.all] by default.
  final ReturnsPeriod selectedPeriod;

  /// True when anything would narrow the list, so the table can offer
  /// "مسح الفلاتر" and word its empty state correctly.
  bool get hasActiveFilters =>
      selectedCity != kAllCities ||
      query.trim().isNotEmpty ||
      selectedStatus != null ||
      selectedPeriod != ReturnsPeriod.all;
}

final class FinancialReturnsInitial extends FinancialReturnsState {
  const FinancialReturnsInitial({
    super.selectedCity = kAllCities,
    super.query = '',
    super.selectedStatus,
    super.selectedPeriod,
  });
}

final class FinancialReturnsLoading extends FinancialReturnsState {
  const FinancialReturnsLoading({
    super.selectedCity = kAllCities,
    super.query = '',
    super.selectedStatus,
    super.selectedPeriod,
  });
}

/// Holds every row from the source; the visible subset and the KPI tiles are
/// derived, so changing a filter is a pure re-read — no extra fetch.
final class FinancialReturnsLoaded extends FinancialReturnsState {
  const FinancialReturnsLoaded({
    required this.rows,
    super.selectedCity = kAllCities,
    super.query = '',
    super.selectedStatus,
    super.selectedPeriod,
  });

  /// Unfiltered rows, newest first.
  final List<FinancialReturn> rows;

  /// Rows surviving every filter. The period is measured against the current
  /// time, so "هذا الشهر" keeps meaning this month for as long as the screen is
  /// open.
  List<FinancialReturn> get returns => rows
      .where(
        (FinancialReturn row) =>
            matchesCity(row, selectedCity) &&
            matchesStatus(row, selectedStatus) &&
            matchesPeriod(row.createdAt, selectedPeriod, DateTime.now()) &&
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
    super.selectedStatus,
    super.selectedPeriod,
  });

  final String message;
}
