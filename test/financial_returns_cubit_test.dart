import 'dart:async';
import 'dart:typed_data';

import 'package:benaa_dashboard/features/financial_returns/model/financial_return.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_return_status.dart';
import 'package:benaa_dashboard/features/financial_returns/model/demo_returns.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_returns_local_data_source.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_returns_payload.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_returns_pdf_builder.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_returns_remote_data_source.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_returns_repository.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_summary.dart';
import 'package:benaa_dashboard/features/financial_returns/model/returns_filters.dart';
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
    // The default selection is "الكل", so every seeded row is visible.
    expect(loaded.rows, hasLength(3));
    expect(loaded.selectedCity, kAllCities);
    expect(loaded.returns, hasLength(3));
    expect(loaded.summaries, hasLength(3));
    expect(cache.payload, isNotNull, reason: 'payload should be cached');
  });

  test('selecting a city re-filters without refetching', () async {
    cubit.load();
    await pumpEventQueue();
    expect((cubit.state as FinancialReturnsLoaded).returns, hasLength(3));

    cubit.selectCity('الرياض');

    final FinancialReturnsLoaded state =
        cubit.state as FinancialReturnsLoaded;
    expect(state.selectedCity, 'الرياض');
    expect(state.rows, hasLength(3), reason: 'source rows stay untouched');
    expect(state.returns, hasLength(1));
    expect(state.summaries.first.value, '4,200 ريال');
  });

  test('الكل restores every row regardless of city', () async {
    cubit.load();
    await pumpEventQueue();
    cubit.selectCity('الرياض');
    expect((cubit.state as FinancialReturnsLoaded).returns, hasLength(1));

    cubit.selectCity(kAllCities);

    final FinancialReturnsLoaded state =
        cubit.state as FinancialReturnsLoaded;
    expect(state.returns, hasLength(3));
    expect(state.summaries.first.value, '21,700 ريال');
  });

  test('a live frame keeps the selected city and the query', () async {
    final _StreamingRemote remote = _StreamingRemote();
    final FinancialReturnsCubit live = _cubitWith(remote: remote);
    addTearDown(live.close);

    live.load();
    await pumpEventQueue();
    remote.emit(kDemoFinancialReturns);
    await pumpEventQueue();

    live.selectCity('الرياض');
    live.search(remote.rows.last.phone);

    // An admin edit lands while the user is filtered.
    remote.emit(kDemoFinancialReturns);
    await pumpEventQueue();

    final FinancialReturnsLoaded state = live.state as FinancialReturnsLoaded;
    expect(state.selectedCity, 'الرياض');
    expect(state.query, remote.rows.last.phone);
    expect(state.rows, hasLength(3), reason: 'rows refresh, filter does not');
  });

  test('search matches the same row across phone spellings', () async {
    cubit.load();
    await pumpEventQueue();

    for (final String query in <String>[
      '0501234567',
      '501234567',
      '+966 50 123 4567',
      '٥٠١٢٣٤٥٦٧',
    ]) {
      cubit.search(query);
      final FinancialReturnsLoaded state =
          cubit.state as FinancialReturnsLoaded;
      expect(
        state.returns.single.reference,
        '#/#/#',
        reason: '"$query" should match the +966 50 123 4567 row',
      );
    }
  });

  test('search and city combine with AND', () async {
    cubit.load();
    await pumpEventQueue();

    // The Riyadh row's phone, while filtered to الدمام.
    cubit.selectCity('الدمام');
    cubit.search('0539072214');

    final FinancialReturnsLoaded state = cubit.state as FinancialReturnsLoaded;
    expect(state.returns, isEmpty);
    expect(state.hasActiveFilters, isTrue);
  });

  test('clearFilters resets the city and the query', () async {
    cubit.load();
    await pumpEventQueue();
    cubit.selectCity('الرياض');
    cubit.search('0539');

    cubit.clearFilters();

    final FinancialReturnsLoaded state = cubit.state as FinancialReturnsLoaded;
    expect(state.selectedCity, kAllCities);
    expect(state.query, isEmpty);
    expect(state.returns, hasLength(3));
  });

  test('city options stay reachable for cities that only exist in the data',
      () async {
    final _StreamingRemote remote = _StreamingRemote();
    final FinancialReturnsCubit live = _cubitWith(remote: remote);
    addTearDown(live.close);

    live.load();
    await pumpEventQueue();
    remote.emit(<FinancialReturn>[
      ...kDemoFinancialReturns,
      const FinancialReturn(
        id: 'extra',
        cityId: 'الخبر',
        status: FinancialReturnStatus.active,
        amount: 100,
        reference: 'RET-9',
        phone: '+966 50 000 0001',
        alternatePhone: '+966 50 000 0001',
      ),
    ]);
    await pumpEventQueue();

    final FinancialReturnsLoaded state = live.state as FinancialReturnsLoaded;
    expect(state.cityOptions, contains('الخبر'));

    live.selectCity('الخبر');
    expect(
      (live.state as FinancialReturnsLoaded).returns.single.reference,
      'RET-9',
    );
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
    required String selectedCity,
    required String query,
    DateTime? generatedAt,
  }) async {
    throw StateError('render failed');
  }
}

/// Remote whose frames are pushed by the test.
class _StreamingRemote implements FinancialReturnsRemoteDataSource {
  final StreamController<FinancialReturnsPayload> _controller =
      StreamController<FinancialReturnsPayload>.broadcast();

  List<FinancialReturn> rows = kDemoFinancialReturns;

  void emit(List<FinancialReturn> payloadRows) {
    rows = payloadRows;
    _controller.add(FinancialReturnsPayload(rows: payloadRows));
  }

  @override
  Stream<FinancialReturnsPayload> watch() => _controller.stream;
}
