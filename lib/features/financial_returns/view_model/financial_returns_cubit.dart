import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/financial_returns_payload.dart';
import '../model/financial_returns_pdf_builder.dart';
import '../model/financial_returns_repository.dart';
import '../model/returns_filters.dart';
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
  ///
  /// The current filter travels through [FinancialReturnsLoading] into the next
  /// [FinancialReturnsLoaded], so a reconnect never drops the user's selection.
  void load() {
    unawaited(_subscription?.cancel());
    emit(
      FinancialReturnsLoading(
        selectedCity: state.selectedCity,
        query: state.query,
      ),
    );

    _subscription = _repository.watchReturns().listen(
      (FinancialReturnsPayload payload) {
        if (isClosed) return;
        emit(
          FinancialReturnsLoaded(
            rows: payload.rows,
            selectedCity: state.selectedCity,
            query: state.query,
          ),
        );
      },
      onError: (Object _) {
        if (isClosed) return;
        emit(
          FinancialReturnsFailure(
            message: 'تعذّر تحميل العوائد المالية، حاول مرة أخرى.',
            selectedCity: state.selectedCity,
            query: state.query,
          ),
        );
      },
    );
  }

  /// Applies a city to the whole filter row.
  ///
  /// The subscription is untouched: every row is already in memory, so this is
  /// a local re-filter rather than a network round-trip.
  void selectCity(String city) {
    if (city == state.selectedCity) return;
    emit(_withFilters(selectedCity: city));
  }

  /// Applies the phone search (already debounced by the field if needed).
  void search(String value) {
    if (value == state.query) return;
    emit(_withFilters(query: value));
  }

  void clearFilters() => emit(_withFilters(selectedCity: kAllCities, query: ''));

  FinancialReturnsState _withFilters({
    String? selectedCity,
    String? query,
  }) {
    final String city = selectedCity ?? state.selectedCity;
    final String text = query ?? state.query;

    return switch (state) {
      FinancialReturnsLoaded loaded => FinancialReturnsLoaded(
        rows: loaded.rows,
        selectedCity: city,
        query: text,
      ),
      FinancialReturnsLoading() => FinancialReturnsLoading(
        selectedCity: city,
        query: text,
      ),
      FinancialReturnsFailure failure => FinancialReturnsFailure(
        message: failure.message,
        selectedCity: city,
        query: text,
      ),
      FinancialReturnsInitial() => FinancialReturnsInitial(
        selectedCity: city,
        query: text,
      ),
    };
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
        selectedCity: current.selectedCity,
        query: current.query,
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
