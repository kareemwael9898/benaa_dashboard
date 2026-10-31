import 'dart:async';
import 'dart:typed_data';

import 'package:benaa_dashboard/features/financial_returns/model/financial_return.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_return_status.dart';
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

FinancialReturnsCubit _cubitWith({
  FinancialReturnsRemoteDataSource? remote,
  FinancialReturnsCache? cache,
  FinancialReturnsPdfBuilder pdfBuilder = const FinancialReturnsPdfBuilder(),
}) {
  return FinancialReturnsCubit(
    FinancialReturnsRepositoryImpl(
      remote: remote ?? MockFinancialReturnsRemoteDataSource(latency: Duration.zero),
      cache: cache ?? _FakeCache(),
    ),
    pdfBuilder: pdfBuilder,
  );
}

void main() {
  // buildReportPdf loads the bundled fonts through rootBundle.
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeCache cache;
  late FinancialReturnsCubit cubit;

  setUp(() {
    cache = _FakeCache();
    cubit = _cubitWith(cache: cache);
  });

  tearDown(() => cubit.close());

  test('emits loading then loaded with the seeded rows', () async {
    final List<FinancialReturnsState> states = <FinancialReturnsState>[];
    final StreamSubscription<FinancialReturnsState> subscription = cubit.stream
        .listen(states.add);

    cubit.load();
    await pumpEventQueue();
    await subscription.cancel();

    expect(states.first, isA<FinancialReturnsLoading>());
    expect(states.last, isA<FinancialReturnsLoaded>());

    final FinancialReturnsLoaded loaded = states.last as FinancialReturnsLoaded;
    // Three demo rows, two of them in the default city (الدمام).
    expect(loaded.rows, hasLength(3));
    expect(loaded.returns, hasLength(2));
    expect(loaded.summaries, hasLength(3));
    expect(cache.payload, isNotNull, reason: 'payload should be cached');
  });

  test('selecting another city re-filters without refetching', () async {
    cubit.load();
    await pumpEventQueue();
    expect((cubit.state as FinancialReturnsLoaded).returns, hasLength(2));

    // Third dropdown, second option ("الرياض").
    cubit.selectFilter(fieldIndex: 2, optionIndex: 1);

    final FinancialReturnsLoaded state =
        cubit.state as FinancialReturnsLoaded;
    expect(state.filters.last.value, 'الرياض');
    expect(state.rows, hasLength(3), reason: 'source rows stay untouched');
    expect(state.returns, hasLength(1));
    expect(state.summaries.first.value, '4,200 ريال');
  });

  test('cached payload paints before the live stream arrives', () async {
    cache.payload = FinancialReturnsPayload(
      rows: const <FinancialReturn>[
        FinancialReturn(
          id: 'cached-1',
          cityId: 'الدمام',
          status: FinancialReturnStatus.active,
          amount: 999,
          reference: 'CACHED',
          phone: '+966 50 000 0000',
          alternatePhone: '+966 50 000 0000',
        ),
      ],
    ).toMap();

    final List<FinancialReturnsState> states = <FinancialReturnsState>[];
    final StreamSubscription<FinancialReturnsState> subscription = cubit.stream
        .listen(states.add);

    cubit.load();
    await pumpEventQueue();
    await subscription.cancel();

    final List<FinancialReturnsLoaded> loadedStates = states
        .whereType<FinancialReturnsLoaded>()
        .toList();
    expect(loadedStates, hasLength(2), reason: 'cache frame, then live frame');
    expect(loadedStates.first.rows.single.reference, 'CACHED');
    expect(loadedStates.last.rows, hasLength(3));
  });

  test('failure state is emitted when the source throws', () async {
    final FinancialReturnsCubit failing = _cubitWith(remote: _ThrowingRemote());
    addTearDown(failing.close);

    failing.load();
    await pumpEventQueue();

    expect(failing.state, isA<FinancialReturnsFailure>());
  });

  test('buildReportPdf renders the data currently on screen', () async {
    cubit.load();
    await pumpEventQueue();

    final Uint8List? bytes = await cubit.buildReportPdf();

    expect(bytes, isNotNull);
    expect(String.fromCharCodes(bytes!.take(5)), '%PDF-');
  });

  test('buildReportPdf returns null before anything is loaded', () async {
    expect(await cubit.buildReportPdf(), isNull);
  });

  test('buildReportPdf returns null when rendering fails', () async {
    final FinancialReturnsCubit failing = _cubitWith(
      pdfBuilder: _ThrowingPdfBuilder(),
    );
    addTearDown(failing.close);

    failing.load();
    await pumpEventQueue();

    expect(await failing.buildReportPdf(), isNull);
  });
}

class _ThrowingRemote implements FinancialReturnsRemoteDataSource {
  @override
  Stream<FinancialReturnsPayload> watch() =>
      Stream<FinancialReturnsPayload>.error(Exception('boom'));
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
