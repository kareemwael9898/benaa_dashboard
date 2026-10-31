import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Bold label + dark pill with a chevron on the left and the value on the
/// right, matching the "Component 3" dropdown in the frame.
class ReturnsFilterFieldView extends StatelessWidget {
  const ReturnsFilterFieldView({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onSelected,
    this.width,
  });

  final String label;
  final List<String> options;
  final String value;
  final ValueChanged<String> onSelected;

  /// Defaults to the frame's 269pt pill; stacked layouts pass [double.infinity].
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? AppDimens.filterFieldWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            textAlign: TextAlign.start,
            style: AppTextStyles.body18Bold,
          ),
          SizedBox(height: 8.h),
          PopupMenuButton<String>(
            tooltip: '',
            position: PopupMenuPosition.under,
            color: AppColors.surfaceField,
            onSelected: onSelected,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              for (final String option in options)
                PopupMenuItem<String>(
                  value: option,
                  child: Text(option, style: AppTextStyles.body18),
                ),
            ],
            child: Container(
              constraints: BoxConstraints(minHeight: 43.h),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.blockRadius),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body18,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    AppIcons.chevron,
                    size: 24.r,
                    color: AppColors.pureWhite,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
