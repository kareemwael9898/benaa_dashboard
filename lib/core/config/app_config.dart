import 'package:flutter/foundation.dart';

/// Whether Firebase should be skipped entirely.
///
/// `--dart-define=USE_MOCK=true` forces it; Linux desktop falls back
/// automatically because `cloud_firestore` has no Linux implementation.
bool get useMockData {
  const bool forced = bool.fromEnvironment('USE_MOCK');
  if (forced) return true;
  return !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
}
