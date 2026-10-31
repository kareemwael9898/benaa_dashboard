import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/admin_auth_repository.dart';
import 'auth_state.dart';

/// Drives the admin sign-in flow.
///
/// Firebase's `authStateChanges` is the source of truth: [signIn] only submits
/// credentials, and the subscription decides whether the account may enter
/// (exists in `admins/{uid}`) or gets signed straight back out.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial()) {
    _subscription = _repository.authStateChanges().listen(
      _handleUser,
      onError: (Object _) => _fail('تعذّر التحقّق من حالة الدخول.'),
    );
  }

  final AdminAuthRepository _repository;
  StreamSubscription<AuthUser?>? _subscription;

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthSigningIn());
    try {
      await _repository.signIn(email: email, password: password);
      // The auth stream takes over from here.
    } on AdminAuthException catch (error) {
      emit(AuthSignedOut(message: error.message));
    } catch (_) {
      _fail('تعذّر تسجيل الدخول، حاول مرة أخرى.');
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    emit(const AuthSignedOut());
  }

  Future<void> _handleUser(AuthUser? user) async {
    if (isClosed) return;

    if (user == null) {
      emit(const AuthSignedOut());
      return;
    }

    emit(const AuthChecking());
    try {
      final bool isAdmin = await _repository.isAdmin(user.uid);
      if (isClosed) return;

      if (!isAdmin) {
        await _repository.signOut();
        emit(
          const AuthSignedOut(
            message: 'هذا الحساب لا يملك صلاحية إدارة العوائد.',
          ),
        );
        return;
      }

      emit(AuthSignedIn(user: user));
    } catch (_) {
      _fail('تعذّر التحقّق من صلاحيات الحساب.');
    }
  }

  void _fail(String message) {
    if (isClosed) return;
    emit(AuthSignedOut(message: message));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
