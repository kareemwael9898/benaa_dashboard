import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/dashboard_shell.dart';
import '../view_model/financial_returns_cubit.dart';
import '../view_model/financial_returns_state.dart';
import 'returns_page_content.dart';

/// العوائد المالية — financial returns dashboard screen.
class FinancialReturnsScreen extends StatelessWidget {
  const FinancialReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'العوائد المالية',
      icon: AppIcons.financialReturns,
      actions: <Widget>[
        TextButton.icon(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.admin),
          style: TextButton.styleFrom(foregroundColor: AppColors.gold),
          icon: Icon(Icons.settings_suggest_outlined, size: 18.r),
          label: Text('إدارة', style: AppTextStyles.body14),
        ),
      ],
      child: BlocBuilder<FinancialReturnsCubit, FinancialReturnsState>(
        builder: (BuildContext context, FinancialReturnsState state) {
          return switch (state) {
            FinancialReturnsInitial() => const _LoadingView(),
            FinancialReturnsLoading() => const _LoadingView(),
            FinancialReturnsFailure(:final String message) => _FailureView(
              message: message,
            ),
            FinancialReturnsLoaded() => ReturnsPageContent(state: state),
          };
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: AppTextStyles.body18),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.read<FinancialReturnsCubit>().load(),
            style: TextButton.styleFrom(foregroundColor: AppColors.green),
            child: Text('إعادة المحاولة', style: AppTextStyles.body16),
          ),
        ],
      ),
    );
  }
}
