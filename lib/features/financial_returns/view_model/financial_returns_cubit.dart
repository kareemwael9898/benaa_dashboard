import 'dart:async';
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

  StreamSubscription<FinancialReturnsPayload>? _subscription;

  /// Subscribes to the source. Called once on screen mount and again on retry.
  void load() {
    unawaited(_subscription?.cancel());
    emit(FinancialReturnsLoading(filters: state.filters));

    _subscription = _repository.watchReturns().listen(
      (FinancialReturnsPayload payload) {
        if (isClosed) return;
        emit(
          FinancialReturnsLoaded(filters: state.filters, rows: payload.rows),
        );
      },
      onError: (Object _) {
        if (isClosed) return;
        emit(
          FinancialReturnsFailure(
            filters: state.filters,
            message: 'تعذّر تحميل العوائد المالية، حاول مرة أخرى.',
          ),
        );
      },
    );
  }

  /// Updates one dropdown selection.
  ///
  /// The subscription is untouched: every row is already in memory, so this is
  /// a local re-filter rather than a network round-trip.
  void selectFilter({required int fieldIndex, required int optionIndex}) {
    final List<ReturnFilterField> current = state.filters;
    if (fieldIndex < 0 || fieldIndex >= current.length) return;
    if (current[fieldIndex].selectedIndex == optionIndex) return;

    final List<ReturnFilterField> updated = List<ReturnFilterField>.of(current);
    updated[fieldIndex] = updated[fieldIndex].withIndex(optionIndex);

    emit(switch (state) {
      FinancialReturnsLoaded loaded => FinancialReturnsLoaded(
        filters: updated,
        rows: loaded.rows,
      ),
      FinancialReturnsLoading() => FinancialReturnsLoading(filters: updated),
      FinancialReturnsFailure failure => FinancialReturnsFailure(
        filters: updated,
        message: failure.message,
      ),
      FinancialReturnsInitial() => FinancialReturnsInitial(filters: updated),
    });
  }

  /// Renders the currently displayed rows as a PDF.
  ///
  /// Returns `null` when there is nothing loaded or generation fails; handing
  /// the bytes to the OS is a view concern, so it stays out of the Cubit.
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

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
