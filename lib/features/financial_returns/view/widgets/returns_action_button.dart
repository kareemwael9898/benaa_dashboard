import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Filled action pill (طباعة / تنزيل PDF) — icon on the right, label on the
/// left, both centred.
class ReturnsActionButton extends StatelessWidget {
  const ReturnsActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.background,
    required this.onPressed,
    this.width,
  });

  final String label;
  final IconData icon;
  final Color background;
  final VoidCallback onPressed;

  /// Defaults to the frame's 269pt button; stacked layouts pass
  /// [double.infinity].
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? AppDimens.actionButtonWidth,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppDimens.blockRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimens.blockRadius),
          child: Container(
            constraints: BoxConstraints(minHeight: 40.h),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24.r, color: AppColors.pureWhite),
                SizedBox(width: 8.w),
                Text(label, style: AppTextStyles.body16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
