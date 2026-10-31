import 'dart:typed_data';

import 'package:benaa_dashboard/features/financial_returns/model/financial_return.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_returns_local_data_source.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_returns_payload.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_returns_pdf_builder.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_returns_remote_data_source.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_returns_repository.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_summary.dart';
import 'package:benaa_dashboard/features/financial_returns/model/return_filter_field.dart';
import 'package:benaa_dashboard/features/financial_returns/view_model/financial_returns_cubit.dart';
import 'package:benaa_dashboard/features/financial_returns/view_model/financial_returns_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory stand-in for Hive.
class _FakeCache implements FinancialReturnsCache {
  Map<String, dynamic>? payload;

  @override
  Future<void> clear() async => payload = null;

  @override
  Future<Map<String, dynamic>?> read() async => payload;

  @override
  Future<void> write(Map<String, dynamic> value) async => payload = value;
}

void main() {
  // buildReportPdf loads the bundled fonts through rootBundle.
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeCache cache;
  late FinancialReturnsCubit cubit;

  setUp(() {
    cache = _FakeCache();
    cubit = FinancialReturnsCubit(
      FinancialReturnsRepositoryImpl(
        remote: MockFinancialReturnsRemoteDataSource(latency: Duration.zero),
        cache: cache,
      ),
    );
  });

  tearDown(() => cubit.close());

  test('emits loading then loaded with the seeded payload', () async {
    final List<FinancialReturnsState> states = <FinancialReturnsState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.load();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(states.first, isA<FinancialReturnsLoading>());
    expect(states.last, isA<FinancialReturnsLoaded>());

    final loaded = states.last as FinancialReturnsLoaded;
    expect(loaded.summaries, hasLength(3));
    expect(loaded.returns, hasLength(1));
    expect(loaded.returns.single.statusLabel, 'مفعل');
    expect(cache.payload, isNotNull, reason: 'payload should be cached');
  });

  test('selecting another city filters the rows', () async {
    await cubit.load();
    expect((cubit.state as FinancialReturnsLoaded).returns, hasLength(1));

    // Move the last dropdown away from "الدمام".
    await cubit.selectFilter(fieldIndex: 2, optionIndex: 1);

    final state = cubit.state as FinancialReturnsLoaded;
    expect(state.filters.last.value, 'الرياض');
    expect(state.returns, isEmpty);
  });

  test('failure state is emitted when the source throws', () async {
    final failing = FinancialReturnsCubit(
      FinancialReturnsRepositoryImpl(
        remote: _ThrowingRemote(),
        cache: _FakeCache(),
      ),
    );
    addTearDown(failing.close);

    await failing.load();

    expect(failing.state, isA<FinancialReturnsFailure>());
  });

  test('buildReportPdf renders the data currently on screen', () async {
    await cubit.load();

    final Uint8List? bytes = await cubit.buildReportPdf();

    expect(bytes, isNotNull);
    expect(String.fromCharCodes(bytes!.take(5)), '%PDF-');
  });

  test('buildReportPdf returns null before anything is loaded', () async {
    expect(await cubit.buildReportPdf(), isNull);
  });

  test('buildReportPdf returns null when rendering fails', () async {
    final throwing = _ThrowingPdfBuilder();
    final failingCubit = FinancialReturnsCubit(
      FinancialReturnsRepositoryImpl(
        remote: MockFinancialReturnsRemoteDataSource(latency: Duration.zero),
        cache: _FakeCache(),
      ),
      pdfBuilder: throwing,
    );
    addTearDown(failingCubit.close);

    await failingCubit.load();

    expect(await failingCubit.buildReportPdf(), isNull);
  });
}

class _ThrowingPdfBuilder extends FinancialReturnsPdfBuilder {
  @override
  Future<Uint8List> build({
    required List<FinancialSummary> summaries,
    required List<FinancialReturn> returns,
    required List<ReturnFilterField> filters,
    DateTime? generatedAt,
  }) async {
    throw StateError('render failed');
  }
}

class _ThrowingRemote implements FinancialReturnsRemoteDataSource {
  @override
  Future<FinancialReturnsPayload> fetch({String? cityId}) async {
    throw Exception('boom');
  }
}
