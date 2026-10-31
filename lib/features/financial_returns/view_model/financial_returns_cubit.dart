import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/financial_return_status.dart';
import '../model/financial_returns_payload.dart';
import '../model/financial_returns_pdf_builder.dart';
import '../model/financial_returns_repository.dart';
import '../model/returns_filters.dart';
import '../model/returns_period.dart';
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
        selectedStatus: state.selectedStatus,
        selectedPeriod: state.selectedPeriod,
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
            selectedStatus: state.selectedStatus,
            selectedPeriod: state.selectedPeriod,
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
            selectedStatus: state.selectedStatus,
            selectedPeriod: state.selectedPeriod,
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

  /// Applies the status pill; `null` means every status.
  void selectStatus(FinancialReturnStatus? status) {
    if (status == state.selectedStatus) return;
    emit(_withFilters(selectedStatus: status, statusChanged: true));
  }

  /// Applies the period pill.
  void selectPeriod(ReturnsPeriod period) {
    if (period == state.selectedPeriod) return;
    emit(_withFilters(selectedPeriod: period));
  }

  /// Applies the phone search (already debounced by the field if needed).
  void search(String value) {
    if (value == state.query) return;
    emit(_withFilters(query: value));
  }

  void clearFilters() => emit(
    _withFilters(
      selectedCity: kAllCities,
      query: '',
      selectedStatus: null,
      statusChanged: true,
      selectedPeriod: ReturnsPeriod.all,
    ),
  );

  /// Returns a copy of the current state with the given filters applied.
  ///
  /// [statusChanged] exists because `null` is a real value for the status
  /// (meaning "all"), so `selectedStatus ?? state.selectedStatus` would make it
  /// impossible to clear.
  FinancialReturnsState _withFilters({
    String? selectedCity,
    String? query,
    FinancialReturnStatus? selectedStatus,
    bool statusChanged = false,
    ReturnsPeriod? selectedPeriod,
  }) {
    final String city = selectedCity ?? state.selectedCity;
    final String text = query ?? state.query;
    final FinancialReturnStatus? status = statusChanged
        ? selectedStatus
        : state.selectedStatus;
    final ReturnsPeriod period = selectedPeriod ?? state.selectedPeriod;

    return switch (state) {
      FinancialReturnsLoaded loaded => FinancialReturnsLoaded(
        rows: loaded.rows,
        selectedCity: city,
        query: text,
        selectedStatus: status,
        selectedPeriod: period,
      ),
      FinancialReturnsLoading() => FinancialReturnsLoading(
        selectedCity: city,
        query: text,
        selectedStatus: status,
        selectedPeriod: period,
      ),
      FinancialReturnsFailure failure => FinancialReturnsFailure(
        message: failure.message,
        selectedCity: city,
        query: text,
        selectedStatus: status,
        selectedPeriod: period,
      ),
      FinancialReturnsInitial() => FinancialReturnsInitial(
        selectedCity: city,
        query: text,
        selectedStatus: status,
        selectedPeriod: period,
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
        selectedStatus: current.selectedStatus?.label ?? kAllStatuses,
        selectedPeriod: current.selectedPeriod.label,
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
