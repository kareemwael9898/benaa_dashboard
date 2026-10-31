import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/responsive/app_form_factor.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/returns_filters.dart';
import 'returns_action_button.dart';
import 'returns_filter_field.dart';

/// The "انواع الباقات" block: three city pills, then the print / PDF actions.
///
/// The frame repeats the same dropdown three times; they are all bound to
/// [selectedCity] here, so whichever pill is used, the table follows and the
/// other two update with it.
///
/// On phones the pills and the actions stack full width; from [AppBreakpoints]
/// upwards they wrap onto as many runs as the window allows, which is exactly
/// the frame's single row once there is room for it.
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
    final bool stacked = context.isCompactLayout;

    final List<Widget> pills = <Widget>[
      for (int i = 0; i < kFilterPillCount; i++)
        ReturnsFilterFieldView(
          label: 'المدينة',
          options: cityOptions,
          value: selectedCity,
          onSelected: onCitySelected,
          width: stacked ? double.infinity : null,
        ),
    ];

    final List<Widget> actions = <Widget>[
      ReturnsActionButton(
        label: 'طباعة',
        icon: AppIcons.print,
        background: AppColors.green,
        onPressed: onPrint,
        width: stacked ? double.infinity : null,
      ),
      ReturnsActionButton(
        label: 'تنزيل PDF',
        icon: AppIcons.download,
        background: AppColors.red,
        onPressed: onExportPdf,
        width: stacked ? double.infinity : null,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stacked)
          _Stacked(children: pills)
        else
          Wrap(spacing: 24.w, runSpacing: 16.h, children: pills),
        SizedBox(height: 24.h),
        if (stacked)
          _Stacked(children: actions)
        else
          Wrap(spacing: 24.w, runSpacing: 12.h, children: actions),
      ],
    );
  }
}

class _Stacked extends StatelessWidget {
  const _Stacked({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < children.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == children.length - 1 ? 0 : 12.h,
            ),
            child: children[i],
          ),
      ],
    );
  }
}
