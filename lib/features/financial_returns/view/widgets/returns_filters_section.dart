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
/// Presentation follows the room available:
/// * narrow phones (under 600) stack the pills and the actions full width;
/// * wider phones and landscape handsets (600-899) put three pills and two
///   actions across, sized to share the row — stacked there would fill a whole
///   landscape screen with dropdowns;
/// * [AppBreakpoints.desktopMin] and up is the frame, wrapped if a run has to
///   break.
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
    final double width = MediaQuery.sizeOf(context).width;
    // Stack only where a landscape-height screen has room for it.
    final bool stacked = context.isCompactLayout && width < 600;
    final bool spread = context.isCompactLayout && !stacked;

    final List<Widget> pills = <Widget>[
      for (int i = 0; i < kFilterPillCount; i++)
        ReturnsFilterFieldView(
          label: 'المدينة',
          options: cityOptions,
          value: selectedCity,
          onSelected: onCitySelected,
          width: stacked || spread ? double.infinity : null,
        ),
    ];

    final List<Widget> actions = <Widget>[
      ReturnsActionButton(
        label: 'طباعة',
        icon: AppIcons.print,
        background: AppColors.green,
        onPressed: onPrint,
        width: stacked || spread ? double.infinity : null,
      ),
      ReturnsActionButton(
        label: 'تنزيل PDF',
        icon: AppIcons.download,
        background: AppColors.red,
        onPressed: onExportPdf,
        width: stacked || spread ? double.infinity : null,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stacked)
          _Stacked(children: pills)
        else if (spread)
          _Spread(gap: 12.w, children: pills)
        else
          Wrap(spacing: 24.w, runSpacing: 16.h, children: pills),
        SizedBox(height: stacked ? 24.h : 16.h),
        if (stacked)
          _Stacked(children: actions)
        else if (spread)
          _Spread(gap: 12.w, children: actions)
        else
          Wrap(spacing: 24.w, runSpacing: 12.h, children: actions),
      ],
    );
  }
}

/// Same widgets sharing one row, each sized to an equal fraction of it.
class _Spread extends StatelessWidget {
  const _Spread({required this.children, required this.gap});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: gap),
          Expanded(child: children[i]),
        ],
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
