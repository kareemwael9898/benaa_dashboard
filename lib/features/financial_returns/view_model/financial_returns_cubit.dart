import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/financial_returns_payload.dart';
import '../model/financial_returns_repository.dart';
import '../model/return_filter_field.dart';
import 'financial_returns_state.dart';

/// Business logic for the financial-returns screen.
class FinancialReturnsCubit extends Cubit<FinancialReturnsState> {
  FinancialReturnsCubit(this._repository) : super(const FinancialReturnsInitial());

  final FinancialReturnsRepository _repository;

  /// Loads (or reloads) the payload for the current filters.
  Future<void> load() => _fetch(state.filters, showSpinner: true);

  /// Updates one dropdown selection and re-queries.
  ///
  /// When data is already on screen the spinner is skipped, so the KPI panel
  /// doesn't flash on every filter change.
  Future<void> selectFilter({
    required int fieldIndex,
    required int optionIndex,
  }) async {
    final List<ReturnFilterField> current = state.filters;
    if (fieldIndex < 0 || fieldIndex >= current.length) return;
    if (current[fieldIndex].selectedIndex == optionIndex) return;

    final List<ReturnFilterField> updated = List<ReturnFilterField>.of(current);
    updated[fieldIndex] = updated[fieldIndex].withIndex(optionIndex);

    await _fetch(updated, showSpinner: state is! FinancialReturnsLoaded);
  }

  /// Placeholder for the print action in the design.
  // TODO(backend): call the report/printing endpoint.
  Future<void> printReport() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  /// Placeholder for the PDF export action in the design.
  // TODO(backend): request the PDF export and hand the file to the platform.
  Future<void> exportPdf() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Future<void> _fetch(
    List<ReturnFilterField> filters, {
    required bool showSpinner,
  }) async {
    if (showSpinner) {
      emit(FinancialReturnsLoading(filters: filters));
    }

    try {
      final FinancialReturnsPayload payload = await _repository.fetchReturns(
        cityId: _selectedCity(filters),
      );

      emit(
        FinancialReturnsLoaded(
          filters: filters,
          summaries: payload.summaries,
          returns: payload.returns,
        ),
      );
    } catch (_) {
      emit(
        FinancialReturnsFailure(
          filters: filters,
          message: 'تعذّر تحميل العوائد المالية، حاول مرة أخرى.',
        ),
      );
    }
  }

  /// City filter drives the query (last dropdown in the design).
  String? _selectedCity(List<ReturnFilterField> filters) {
    if (filters.isEmpty) return null;
    return filters.last.value;
  }
}
