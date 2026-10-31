import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Cache contract for the returns payload.
///
/// Kept as an interface so the repository can be tested without Hive.
abstract interface class FinancialReturnsCache {
  /// Cached payload, or `null` when missing, expired or corrupt.
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, dynamic> payload);

  Future<void> clear();
}

/// Hive-backed implementation — the only local-storage dependency in the
/// project (no `shared_preferences`).
class HiveFinancialReturnsCache implements FinancialReturnsCache {
  static const String boxName = 'financial_returns_cache';
  static const String _payloadKey = 'payload';

  /// Cache lifetime; after this the repository goes back to the remote source.
  static const Duration ttl = Duration(minutes: 5);

  /// Opens Hive and the cache box. Call once before `runApp`.
  static Future<void> open() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(boxName);
  }

  Box<String> get _box => Hive.box<String>(boxName);

  @override
  Future<Map<String, dynamic>?> read() async {
    final String? raw = _box.get(_payloadKey);
    if (raw == null) return null;

    try {
      final Map<String, dynamic> envelope =
          jsonDecode(raw) as Map<String, dynamic>;
      final DateTime? cachedAt = DateTime.tryParse(
        envelope['cachedAt'] as String? ?? '',
      );
      if (cachedAt == null || DateTime.now().difference(cachedAt) > ttl) {
        return null;
      }
      return envelope['payload'] as Map<String, dynamic>?;
    } on FormatException {
      await _box.delete(_payloadKey);
      return null;
    }
  }

  @override
  Future<void> write(Map<String, dynamic> payload) async {
    await _box.put(
      _payloadKey,
      jsonEncode(<String, dynamic>{
        'cachedAt': DateTime.now().toIso8601String(),
        'payload': payload,
      }),
    );
  }

  @override
  Future<void> clear() async {
    await _box.delete(_payloadKey);
  }
}

/// Non-persistent cache: the mock graph and tests run without Hive.
class InMemoryFinancialReturnsCache implements FinancialReturnsCache {
  Map<String, dynamic>? _payload;

  @override
  Future<Map<String, dynamic>?> read() async => _payload;

  @override
  Future<void> write(Map<String, dynamic> payload) async => _payload = payload;

  @override
  Future<void> clear() async => _payload = null;
}
