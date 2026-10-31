import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../model/return_filter_field.dart';

/// Bold label + dark pill with a chevron on the left and the value on the
/// right, matching the "Component 3" dropdown in the frame.
class ReturnsFilterFieldView extends StatelessWidget {
  const ReturnsFilterFieldView({
    super.key,
    required this.field,
    required this.onSelected,
  });

  final ReturnFilterField field;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimens.filterFieldWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            field.label,
            textAlign: TextAlign.start,
            style: AppTextStyles.body18Bold,
          ),
          SizedBox(height: 8.h),
          PopupMenuButton<int>(
            tooltip: '',
            position: PopupMenuPosition.under,
            color: AppColors.surfaceField,
            onSelected: onSelected,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              for (int i = 0; i < field.options.length; i++)
                PopupMenuItem<int>(
                  value: i,
                  child: Text(
                    field.options[i],
                    style: AppTextStyles.body18,
                  ),
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
                      field.value,
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
