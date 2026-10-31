import 'financial_return.dart';
import 'financial_returns_local_data_source.dart';
import 'financial_returns_payload.dart';
import 'financial_returns_remote_data_source.dart';

/// Reads financial returns for the dashboard.
abstract interface class FinancialReturnsRepository {
  /// Returns the payload, optionally filtered to one city.
  Future<FinancialReturnsPayload> fetchReturns({String? cityId});
}

/// Cache-first repository.
///
/// The unfiltered payload is cached in Hive; city filtering happens in memory
/// so switching a filter never costs a second network round-trip.
class FinancialReturnsRepositoryImpl implements FinancialReturnsRepository {
  FinancialReturnsRepositoryImpl({
    required FinancialReturnsRemoteDataSource remote,
    required FinancialReturnsCache cache,
  }) : _remote = remote,
       _cache = cache;

  final FinancialReturnsRemoteDataSource _remote;
  final FinancialReturnsCache _cache;

  @override
  Future<FinancialReturnsPayload> fetchReturns({String? cityId}) async {
    final FinancialReturnsPayload payload = await _load();

    if (cityId == null || cityId.isEmpty) {
      return payload;
    }

    return FinancialReturnsPayload(
      summaries: payload.summaries,
      returns: payload.returns
          .where((FinancialReturn row) => row.cityId == cityId)
          .toList(),
    );
  }

  Future<FinancialReturnsPayload> _load() async {
    final Map<String, dynamic>? cached = await _cache.read();
    if (cached != null) {
      try {
        return FinancialReturnsPayload.fromMap(cached);
      } catch (_) {
        await _cache.clear();
      }
    }

    final FinancialReturnsPayload payload = await _remote.fetch();
    await _cache.write(payload.toMap());
    return payload;
  }
}
