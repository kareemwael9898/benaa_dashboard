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
class FinancialReturnsRepositoryImpl implements FinancialReturnsRepository {
  FinancialReturnsRepositoryImpl({
    required FinancialReturnsRemoteDataSource remote,
    required FinancialReturnsCache cache,
  }) : _remote = remote,
       _cache = cache;

  final FinancialReturnsRemoteDataSource _remote;
  final FinancialReturnsCache _cache;

  @override
  Stream<FinancialReturnsPayload> watchReturns() async* {
    final Map<String, dynamic>? cached = await _cache.read();
    if (cached != null) {
      try {
        yield FinancialReturnsPayload.fromMap(cached);
      } catch (_) {
        await _cache.clear();
      }
    }

    await for (final FinancialReturnsPayload payload in _remote.watch()) {
      // Fire-and-forget: a slow disk must not delay a fresh snapshot.
      unawaited(_cache.write(payload.toMap()));
      yield payload;
    }
  }
}
