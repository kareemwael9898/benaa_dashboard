import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/view/login_page.dart';
import '../../auth/view_model/auth_cubit.dart';
import '../../auth/view_model/auth_state.dart';
import '../view_model/admin_returns_cubit.dart';
import '../model/admin_returns_repository.dart';
import 'admin_screen.dart';

/// Route guard: shows the login form until an account that exists in
/// `admins/{uid}` is signed in.
///
/// The same condition is enforced again by the Firestore rules — this is the
/// honest-UI half, not the security half.
class AdminGate extends StatelessWidget {
  const AdminGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (BuildContext context, AuthState state) {
        return switch (state) {
          AuthSignedIn(:final user) => BlocProvider<AdminReturnsCubit>(
            create: (BuildContext context) =>
                AdminReturnsCubit(context.read<AdminReturnsRepository>())
                  ..load(),
            child: AdminScreen(email: user.email),
          ),
          AuthInitial() || AuthChecking() => const _Splash(),
          AuthSignedOut() || AuthSigningIn() => const LoginPage(),
        };
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}
