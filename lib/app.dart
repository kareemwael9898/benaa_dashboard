import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/theme/app_dimens.dart';
import 'core/theme/app_theme.dart';
import 'features/financial_returns/model/financial_returns_local_data_source.dart';
import 'features/financial_returns/model/financial_returns_remote_data_source.dart';
import 'features/financial_returns/model/financial_returns_repository.dart';
import 'features/financial_returns/view/financial_returns_screen.dart';
import 'features/financial_returns/view_model/financial_returns_cubit.dart';

/// Root widget: RTL Arabic shell + ScreenUtil design canvas + the feature's
/// Cubit at the top of the tree.
class BenaaDashboardApp extends StatelessWidget {
  const BenaaDashboardApp({super.key, this.cache});

  /// Injectable local cache (used by tests to avoid Hive).
  final FinancialReturnsCache? cache;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(AppDimens.designWidth, AppDimens.designHeight),
      minTextAdapt: false,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
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
          home: BlocProvider<FinancialReturnsCubit>(
            create: (_) => FinancialReturnsCubit(
              FinancialReturnsRepositoryImpl(
                remote: MockFinancialReturnsRemoteDataSource(),
                cache: cache ?? HiveFinancialReturnsCache(),
              ),
            )..load(),
            child: const FinancialReturnsScreen(),
          ),
        );
      },
    );
  }
}
