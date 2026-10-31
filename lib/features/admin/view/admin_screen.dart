import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/view_model/auth_cubit.dart';
import '../../financial_returns/model/financial_return.dart';
import '../view_model/admin_returns_cubit.dart';
import '../view_model/admin_returns_state.dart';
import 'widgets/admin_returns_table.dart';
import 'widgets/return_form_dialog.dart';

/// إدارة العوائد المالية — CRUD over the rows the dashboard renders.
///
/// Every write goes to Firestore; the list is refreshed by the snapshot stream,
/// so what is on this page is what the dashboard shows.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminReturnsCubit, AdminReturnsState>(
      listenWhen: (AdminReturnsState previous, AdminReturnsState current) =>
          current is AdminReturnsLoaded && current.feedback != null,
      listener: (BuildContext context, AdminReturnsState state) {
        final AdminFeedback? feedback = state is AdminReturnsLoaded
            ? state.feedback
            : null;
        if (feedback == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(feedback.message),
              backgroundColor: feedback.isError
                  ? AppColors.red
                  : AppColors.surfaceField,
            ),
          );
        context.read<AdminReturnsCubit>().consumeFeedback();
      },
      child: Scaffold(
        backgroundColor: AppColors.pureBlack,
        body: Column(
          children: <Widget>[
            _AdminHeader(email: email),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.pageHorizontalPadding,
                  vertical: AppDimens.pageTopPadding,
                ),
                child: const _AdminBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.topBarHeight,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.topBarHorizontalPadding,
        vertical: AppDimens.topBarVerticalPadding,
      ),
      color: AppColors.surface,
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'العودة إلى لوحة التحكم',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const BackButtonIcon(),
            color: AppColors.goldBright,
          ),
          SizedBox(width: 4.w),
          Text('إدارة العوائد المالية', style: AppTextStyles.screenTitle),
          SizedBox(width: 12.w),
          Icon(
            AppIcons.financialReturns,
            size: 28.r,
            color: AppColors.goldBright,
          ),
          const Spacer(),
          Text(email, textDirection: TextDirection.ltr, style: AppTextStyles.body14Muted),
          SizedBox(width: 12.w),
          TextButton.icon(
            onPressed: () => context.read<AuthCubit>().signOut(),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            icon: Icon(AppIcons.logout, size: 18.r, color: AppColors.red),
            label: Text(
              'خروج',
              style: AppTextStyles.body14.copyWith(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBody extends StatelessWidget {
  const _AdminBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminReturnsCubit, AdminReturnsState>(
      builder: (BuildContext context, AdminReturnsState state) {
        return switch (state) {
          AdminReturnsInitial() || AdminReturnsLoading() => const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
          AdminReturnsFailure(:final String message) => _AdminError(
            message: message,
          ),
          AdminReturnsLoaded(:final List<FinancialReturn> rows) => _AdminContent(
            rows: rows,
          ),
        };
      },
    );
  }
}

class _AdminContent extends StatelessWidget {
  const _AdminContent({required this.rows});

  final List<FinancialReturn> rows;

  @override
  Widget build(BuildContext context) {
    final AdminReturnsCubit cubit = context.read<AdminReturnsCubit>();
    final bool busy = cubit.isBusy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('العوائد', style: AppTextStyles.body18Bold),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceField,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '${rows.length}',
                style: AppTextStyles.body14Bold.copyWith(color: AppColors.gold),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _openForm(context, null),
              style: _primaryButtonStyle(),
              icon: Icon(Icons.add, size: 20.r),
              label: Text('إضافة صف', style: AppTextStyles.body14Bold.copyWith(color: AppColors.pureBlack)),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: rows.isEmpty
              ? _AdminEmpty(onSeed: () => cubit.seedDemoData())
              : AdminReturnsTable(
                  rows: rows,
                  busy: busy,
                  onEdit: (FinancialReturn row) => _openForm(context, row),
                  onDelete: (FinancialReturn row) => _confirmDelete(context, row),
                ),
        ),
      ],
    );
  }

  ButtonStyle _primaryButtonStyle() => FilledButton.styleFrom(
    backgroundColor: AppColors.gold,
    foregroundColor: AppColors.pureBlack,
    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
  );

  Future<void> _openForm(BuildContext context, FinancialReturn? existing) async {
    final AdminReturnsCubit cubit = context.read<AdminReturnsCubit>();

    final FinancialReturn? result = await showDialog<FinancialReturn>(
      context: context,
      builder: (_) => ReturnFormDialog(existing: existing),
    );
    if (result == null) return;

    if (existing == null) {
      await cubit.create(result);
    } else {
      await cubit.update(result);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FinancialReturn row,
  ) async {
    final AdminReturnsCubit cubit = context.read<AdminReturnsCubit>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('حذف الصف؟', style: AppTextStyles.body18Bold),
        content: Text(
          'سيُحذف الصف ${row.reference} نهائيًا من العوائد المالية.',
          style: AppTextStyles.body16,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
            child: Text(
              'إلغاء',
              style: AppTextStyles.body16.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: Text(
              'حذف',
              style: AppTextStyles.body16.copyWith(color: AppColors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await cubit.delete(row.id);
    }
  }
}

class _AdminEmpty extends StatelessWidget {
  const _AdminEmpty({required this.onSeed});

  final VoidCallback onSeed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            AppIcons.financialReturns,
            size: 48.r,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 14.h),
          Text('لا توجد عوائد مالية بعد', style: AppTextStyles.body18Bold),
          SizedBox(height: 6.h),
          Text(
            'أضف صفًا جديدًا، أو ابدأ بالبيانات التجريبية للتصميم.',
            style: AppTextStyles.body14Muted,
          ),
          SizedBox(height: 18.h),
          OutlinedButton.icon(
            onPressed: onSeed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gold,
              side: const BorderSide(color: AppColors.gold),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            icon: Icon(Icons.download_done, size: 18.r),
            label: Text(
              'استيراد بيانات التصميم',
              style: AppTextStyles.body14.copyWith(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminError extends StatelessWidget {
  const _AdminError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message, style: AppTextStyles.body16, textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () => context.read<AdminReturnsCubit>().load(),
            style: TextButton.styleFrom(foregroundColor: AppColors.green),
            child: Text('إعادة المحاولة', style: AppTextStyles.body16),
          ),
        ],
      ),
    );
  }
}
