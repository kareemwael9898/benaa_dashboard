import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Signed-in identity the UI cares about.
class AuthUser {
  const AuthUser({required this.uid, required this.email});

  final String uid;
  final String email;
}

/// Auth failure carrying Arabic copy that is already safe to display.
class AdminAuthException implements Exception {
  const AdminAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Admin authentication + authorisation.
abstract interface class AdminAuthRepository {
  /// Emits the current identity and every change (sign-in, sign-out, token
  /// refresh) for the lifetime of the app.
  Stream<AuthUser?> authStateChanges();

  /// Throws [AdminAuthException] with user-facing copy on failure.
  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  /// True when `admins/{uid}` exists — the same condition the Firestore rules
  /// enforce server-side.
  Future<bool> isAdmin(String uid);
}

class FirebaseAdminAuthRepository implements AdminAuthRepository {
  FirebaseAdminAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(
      (User? user) => user == null
          ? null
          : AuthUser(uid: user.uid, email: user.email ?? ''),
    );
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AdminAuthException(_messageFor(error.code));
    } catch (_) {
      throw const AdminAuthException('تعذّر تسجيل الدخول، حاول مرة أخرى.');
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<bool> isAdmin(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
        .collection('admins')
        .doc(uid)
        .get();
    return doc.exists;
  }

  /// Firebase error codes → Arabic copy. Anything unmapped stays generic
  /// rather than leaking an English SDK message into the UI.
  static String _messageFor(String code) => switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' ||
    'invalid-email' => 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
    'user-disabled' => 'هذا الحساب معطّل.',
    'too-many-requests' =>
      'محاولات دخول كثيرة. انتظر قليلًا ثم حاول مرة أخرى.',
    'network-request-failed' => 'تعذّر الاتصال بالشبكة، تحقّق من اتصالك.',
    _ => 'تعذّر تسجيل الدخول، حاول مرة أخرى.',
  };
}
