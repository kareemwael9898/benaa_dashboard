import 'dart:async';

import '../model/admin_auth_repository.dart';

/// Offline stand-in for `--dart-define=USE_MOCK=true`, tests and Linux desktop.
///
/// Accepts any non-empty email/password and treats the session as an admin —
/// no credentials are stored anywhere.
class MockAdminAuthRepository implements AdminAuthRepository {
  AuthUser? _current;
  final StreamController<AuthUser?> _changes =
      StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _current;
    yield* _changes.stream;
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const AdminAuthException('أدخل البريد الإلكتروني وكلمة المرور.');
    }
    _current = AuthUser(uid: 'mock-admin', email: email.trim());
    _changes.add(_current);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _changes.add(null);
  }

  @override
  Future<bool> isAdmin(String uid) async => true;
}
