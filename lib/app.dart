import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_routes.dart';
import 'core/di/app_dependencies.dart';
import 'core/responsive/app_form_factor.dart';
import 'core/theme/app_dimens.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/model/admin_returns_repository.dart';
import 'features/admin/view/admin_gate.dart';
import 'features/auth/model/admin_auth_repository.dart';
import 'features/auth/view_model/auth_cubit.dart';
import 'features/financial_returns/model/financial_returns_repository.dart';
import 'features/financial_returns/view/financial_returns_screen.dart';
import 'features/financial_returns/view_model/financial_returns_cubit.dart';

/// Root widget: RTL Arabic shell + ScreenUtil design canvas + the app's
/// dependency graph.
class BenaaDashboardApp extends StatelessWidget {
  const BenaaDashboardApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(AppDimens.designWidth, AppDimens.designHeight),
      minTextAdapt: false,
      splitScreenMode: true,
      // Scaled canvas from the desktop breakpoint up (exactly as before), 1:1
      // below it.
      //
      // Scaling the 1440pt canvas down to a phone multiplied every font size by
      // the width ratio (16sp came out at 4.3px on a 390px screen), which made
      // the portrait UI a legible-for-nobody miniature. Under the breakpoint the
      // compact composition in `core/responsive` is laid out in real pixels
      // instead; from it up the frame keeps its tuned proportions.
      enableScaleWH: _shouldScaleCanvas,
      enableScaleText: _shouldScaleCanvas,
      builder: (BuildContext context, Widget? child) {
        return RepositoryProvider<AdminReturnsRepository>.value(
          value: dependencies.adminReturns,
          child: RepositoryProvider<AdminAuthRepository>.value(
            value: dependencies.auth,
            child: MaterialApp(
              title: 'بناء | العوائد المالية',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.dark,
              locale: const Locale('ar'),
              supportedLocales: const <Locale>[Locale('ar')],
              localizationsDelegates: const <LocalizationsDelegate<Object>>[
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              initialRoute: AppRoutes.dashboard,
              routes: <String, WidgetBuilder>{
                AppRoutes.dashboard: (_) => BlocProvider<FinancialReturnsCubit>(
                  create: (_) => FinancialReturnsCubit(
                    FinancialReturnsRepositoryImpl(
                      remote: dependencies.returns,
                      cache: dependencies.cache,
                    ),
                  )..load(),
                  child: const FinancialReturnsScreen(),
                ),
                AppRoutes.admin: (_) => BlocProvider<AuthCubit>(
                  create: (_) => AuthCubit(dependencies.auth),
                  child: const AdminGate(),
                ),
              },
            ),
          ),
        );
      },
    );
  }
}

/// ScreenUtil calls this on every `.w` / `.h` / `.sp` read, so it tracks window
/// resizes through the package's own rebuild path.
bool _shouldScaleCanvas() =>
    ScreenUtil().screenWidth >= AppBreakpoints.desktopMin;
