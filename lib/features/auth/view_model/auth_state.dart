import '../model/admin_auth_repository.dart';

/// States of the admin sign-in flow.
sealed class AuthState {
  const AuthState();
}

/// Before Firebase reports the first auth event.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Signed in, waiting on the `admins/{uid}` lookup.
final class AuthChecking extends AuthState {
  const AuthChecking();
}

/// Credentials submitted, waiting for Firebase.
final class AuthSigningIn extends AuthState {
  const AuthSigningIn();
}

final class AuthSignedIn extends AuthState {
  const AuthSignedIn({required this.user});

  final AuthUser user;
}

/// Not signed in — optionally carrying why (bad password, not an admin…).
final class AuthSignedOut extends AuthState {
  const AuthSignedOut({this.message});

  final String? message;
}
