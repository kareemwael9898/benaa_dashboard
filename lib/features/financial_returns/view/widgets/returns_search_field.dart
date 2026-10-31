import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "بحث برقم الجوال" field: muted placeholder on the right, icon on the left.
class ReturnsSearchField extends StatelessWidget {
  const ReturnsSearchField({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.blockRadius),
        child: Container(
          width: 269.w,
          constraints: BoxConstraints(minHeight: 40.h),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceField,
            borderRadius: BorderRadius.circular(AppDimens.blockRadius),
          ),
          child: Row(
            children: [
              Text(
                'بحث برقم الجوال',
                style: AppTextStyles.body16Muted,
              ),
              SizedBox(width: 8.w),
              Icon(AppIcons.search, size: 24.r, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
