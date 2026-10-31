import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/return_filter_field.dart';
import 'returns_action_button.dart';
import 'returns_filter_field.dart';

/// The "انواع الباقات" block: three dropdowns, then the print / PDF actions.
class ReturnsFiltersSection extends StatelessWidget {
  const ReturnsFiltersSection({
    super.key,
    required this.filters,
    required this.onFilterSelected,
    required this.onPrint,
    required this.onExportPdf,
  });

  final List<ReturnFilterField> filters;

  /// `(fieldIndex, optionIndex)`.
  final void Function(int fieldIndex, int optionIndex) onFilterSelected;

  final VoidCallback onPrint;
  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (int i = 0; i < filters.length; i++)
              Padding(
                padding: EdgeInsetsDirectional.only(
                  end: i == filters.length - 1 ? 0 : 24.w,
                ),
                child: ReturnsFilterFieldView(
                  field: filters[i],
                  onSelected: (int optionIndex) =>
                      onFilterSelected(i, optionIndex),
                ),
              ),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            ReturnsActionButton(
              label: 'طباعة',
              icon: AppIcons.print,
              background: AppColors.green,
              onPressed: onPrint,
            ),
            SizedBox(width: 24.w),
            ReturnsActionButton(
              label: 'تنزيل PDF',
              icon: AppIcons.download,
              background: AppColors.red,
              onPressed: onExportPdf,
            ),
          ],
        ),
      ],
    );
  }
}
