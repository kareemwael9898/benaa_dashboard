import '../model/financial_return.dart';
import '../model/financial_summary.dart';
import '../model/return_filter_field.dart';

/// States of the financial-returns feature.
///
/// Every state carries the filter row so the dropdowns stay interactive while
/// data loads or fails — the design always shows them.
sealed class FinancialReturnsState {
  const FinancialReturnsState({required this.filters});

  final List<ReturnFilterField> filters;
}

final class FinancialReturnsInitial extends FinancialReturnsState {
  const FinancialReturnsInitial() : super(filters: kReturnFilterFields);
}

final class FinancialReturnsLoading extends FinancialReturnsState {
  const FinancialReturnsLoading({required super.filters});
}

final class FinancialReturnsLoaded extends FinancialReturnsState {
  const FinancialReturnsLoaded({
    required super.filters,
    required this.summaries,
    required this.returns,
  });

  final List<FinancialSummary> summaries;
  final List<FinancialReturn> returns;
}

final class FinancialReturnsFailure extends FinancialReturnsState {
  const FinancialReturnsFailure({
    required super.filters,
    required this.message,
  });

  final String message;
}
