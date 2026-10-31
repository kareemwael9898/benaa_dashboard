import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/admin/model/admin_returns_repository.dart';
import '../../features/admin/model/mock_admin_returns_repository.dart';
import '../../features/auth/model/admin_auth_repository.dart';
import '../../features/auth/model/mock_admin_auth_repository.dart';
import '../../features/financial_returns/model/financial_returns_local_data_source.dart';
import '../../features/financial_returns/model/financial_returns_remote_data_source.dart';
import '../../features/financial_returns/model/firestore_financial_returns_data_source.dart';

/// Composition root: every swappable dependency in one place.
///
/// [AppDependencies.firebase] is the production graph; [AppDependencies.mock]
/// keeps the app runnable with no network (tests, demos, Linux desktop).
class AppDependencies {
  const AppDependencies({
    required this.returns,
    required this.cache,
    required this.auth,
    required this.adminReturns,
  });

  final FinancialReturnsRemoteDataSource returns;
  final FinancialReturnsCache cache;
  final AdminAuthRepository auth;
  final AdminReturnsRepository adminReturns;

  factory AppDependencies.firebase() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    return AppDependencies(
      returns: FirestoreFinancialReturnsRemoteDataSource(firestore),
      cache: HiveFinancialReturnsCache(),
      auth: FirebaseAdminAuthRepository(firestore: firestore),
      adminReturns: FirestoreAdminReturnsRepository(firestore),
    );
  }

  factory AppDependencies.mock() => AppDependencies(
    returns: MockFinancialReturnsRemoteDataSource(
      latency: Duration.zero,
    ),
    cache: InMemoryFinancialReturnsCache(),
    auth: MockAdminAuthRepository(),
    adminReturns: MockAdminReturnsRepository(),
  );
}
