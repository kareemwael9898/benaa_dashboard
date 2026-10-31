import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../model/financial_return_status.dart';

/// Chip colour per status — the only place the mapping lives.
Color statusColor(FinancialReturnStatus status) => switch (status) {
  FinancialReturnStatus.active => AppColors.green,
  FinancialReturnStatus.pending => AppColors.gold,
  FinancialReturnStatus.suspended => AppColors.red,
};

/// Rounded status pill used by the dashboard table and the admin list.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.compact = false});

  final FinancialReturnStatus status;

  /// Smaller padding for the denser admin table.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14.w : 28.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: statusColor(status),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status.label,
        textAlign: TextAlign.center,
        style: compact ? AppTextStyles.body14 : AppTextStyles.body16,
      ),
    );
  }
}
