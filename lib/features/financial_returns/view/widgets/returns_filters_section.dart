import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/returns_filters.dart';
import 'returns_action_button.dart';
import 'returns_filter_field.dart';

/// The "انواع الباقات" block: three city pills, then the print / PDF actions.
///
/// The frame repeats the same dropdown three times; they are all bound to
/// [selectedCity] here, so whichever pill is used, the table follows and the
/// other two update with it.
class ReturnsFiltersSection extends StatelessWidget {
  const ReturnsFiltersSection({
    super.key,
    required this.cityOptions,
    required this.selectedCity,
    required this.onCitySelected,
    required this.onPrint,
    required this.onExportPdf,
  });

  final List<String> cityOptions;
  final String selectedCity;
  final ValueChanged<String> onCitySelected;
  final VoidCallback onPrint;
  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (int i = 0; i < kFilterPillCount; i++)
              Padding(
                padding: EdgeInsetsDirectional.only(
                  end: i == kFilterPillCount - 1 ? 0 : 24.w,
                ),
                child: ReturnsFilterFieldView(
                  label: 'المدينة',
                  options: cityOptions,
                  value: selectedCity,
                  onSelected: onCitySelected,
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
