import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../model/financial_summary.dart';

/// One KPI tile: bold label above a 24pt value, both centred.
class KpiCard extends StatelessWidget {
  const KpiCard({super.key, required this.summary});

  final FinancialSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.kpiSurface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(color: AppColors.green),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            summary.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.body18Bold,
          ),
          SizedBox(height: 8.h),
          Text(
            summary.value,
            textAlign: TextAlign.center,
            style: AppTextStyles.header3,
          ),
        ],
      ),
    );
  }
}
