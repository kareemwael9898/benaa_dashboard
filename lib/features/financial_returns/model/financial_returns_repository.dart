import 'dart:async';

import 'financial_returns_local_data_source.dart';
import 'financial_returns_payload.dart';
import 'financial_returns_remote_data_source.dart';

/// Reads financial returns for the dashboard.
abstract interface class FinancialReturnsRepository {
  /// Snapshot stream: a cached frame first (if any), then live updates.
  Stream<FinancialReturnsPayload> watchReturns();
}

/// Cache-first, then live.
///
/// The Hive snapshot paints the table immediately on a cold start; the remote
/// stream takes over as soon as it emits and overwrites the cache. The cache is
/// therefore never authoritative for longer than the time Firestore needs to
/// answer — an admin edit can't get stuck behind a stale TTL.
///
/// Built with [Stream.multi] rather than an `async*` generator on purpose:
/// cancelling a generator that is parked in `await for` can leave the inner
/// subscription alive (and the cancel future pending), which would leak a
/// listener every time the screen is disposed or reloaded.
class FinancialReturnsRepositoryImpl implements FinancialReturnsRepository {
  FinancialReturnsRepositoryImpl({
    required FinancialReturnsRemoteDataSource remote,
    required FinancialReturnsCache cache,
  }) : _remote = remote,
       _cache = cache;

  final FinancialReturnsRemoteDataSource _remote;
  final FinancialReturnsCache _cache;

  @override
  Stream<FinancialReturnsPayload> watchReturns() {
    return Stream<FinancialReturnsPayload>.multi(
      (MultiStreamController<FinancialReturnsPayload> controller) {
        bool cancelled = false;
        StreamSubscription<FinancialReturnsPayload>? live;

        controller.onCancel = () {
          cancelled = true;
          return live?.cancel();
        };

        unawaited(_paintCacheThenGoLive(controller, () => cancelled, (sub) {
          live = sub;
        }));
      },
    );
  }

  Future<void> _paintCacheThenGoLive(
    MultiStreamController<FinancialReturnsPayload> controller,
    bool Function() isCancelled,
    void Function(StreamSubscription<FinancialReturnsPayload>) attach,
  ) async {
    Map<String, dynamic>? cached;
    try {
      cached = await _cache.read();
    } catch (_) {
      cached = null;
    }
    if (isCancelled()) return;

    if (cached != null) {
      try {
        controller.add(FinancialReturnsPayload.fromMap(cached));
      } catch (_) {
        await _cache.clear();
      }
    }
    if (isCancelled()) return;

    attach(
      _remote.watch().listen(
        (FinancialReturnsPayload payload) {
          // Fire-and-forget: a slow disk must not delay a fresh snapshot.
          unawaited(_cache.write(payload.toMap()));
          controller.add(payload);
        },
        onError: controller.addError,
        onDone: controller.close,
      ),
    );
  }
}
