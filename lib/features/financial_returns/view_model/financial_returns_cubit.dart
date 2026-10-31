import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/financial_returns_payload.dart';
import '../model/financial_returns_pdf_builder.dart';
import '../model/financial_returns_repository.dart';
import '../model/return_filter_field.dart';
import 'financial_returns_state.dart';

/// Business logic for the financial-returns screen.
class FinancialReturnsCubit extends Cubit<FinancialReturnsState> {
  FinancialReturnsCubit(
    this._repository, {
    FinancialReturnsPdfBuilder pdfBuilder = const FinancialReturnsPdfBuilder(),
  }) : _pdfBuilder = pdfBuilder,
       super(const FinancialReturnsInitial());

  final FinancialReturnsRepository _repository;
  final FinancialReturnsPdfBuilder _pdfBuilder;

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

  /// Renders the currently displayed data as a PDF.
  ///
  /// Returns `null` when there is nothing loaded yet or generation fails; the
  /// view turns that into a message. Handing the bytes to the OS (share sheet,
  /// print dialog, browser download) is a view concern, so it stays out of the
  /// Cubit.
  Future<Uint8List?> buildReportPdf() async {
    final FinancialReturnsState current = state;
    if (current is! FinancialReturnsLoaded) return null;

    try {
      return await _pdfBuilder.build(
        summaries: current.summaries,
        returns: current.returns,
        filters: current.filters,
      );
    } catch (_) {
      return null;
    }
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
