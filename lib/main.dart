import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/app_dependencies.dart';
import 'features/financial_returns/model/financial_returns_local_data_source.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveFinancialReturnsCache.open();

  runApp(BenaaDashboardApp(dependencies: await _bootstrap()));
}

/// Firebase first, mock as a last resort.
///
/// A failed initialisation (offline first load, missing JS SDK) must not leave
/// the user staring at a black screen, so the app falls back to the in-memory
/// graph and says so in the console.
Future<AppDependencies> _bootstrap() async {
  if (useMockData) {
    debugPrint('[benaa] USE_MOCK is on — running on in-memory data.');
    return AppDependencies.mock();
  }

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    return AppDependencies.firebase();
  } catch (error) {
    debugPrint('[benaa] Firebase init failed ($error) — falling back to mock data.');
    return AppDependencies.mock();
  }
}
