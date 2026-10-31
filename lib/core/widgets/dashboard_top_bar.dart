import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Content top bar: screen title plus its icon, right aligned.
class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    super.key,
    required this.title,
    required this.icon,
    this.actions = const <Widget>[],
  });

  final String title;
  final IconData icon;

  /// Optional trailing controls (e.g. the admin shortcut), drawn at the far
  /// end of the bar so the title block stays exactly where the design puts it.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.topBarHeight,
      width: double.infinity,
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.topBarHorizontalPadding,
        vertical: AppDimens.topBarVerticalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.screenTitle),
          SizedBox(width: 16.w),
          Icon(icon, size: 28.r, color: AppColors.goldBright),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}
