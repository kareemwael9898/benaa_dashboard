import 'package:flutter/material.dart';

import 'app.dart';
import 'features/financial_returns/model/financial_returns_local_data_source.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveFinancialReturnsCache.open();
  runApp(const BenaaDashboardApp());
}
