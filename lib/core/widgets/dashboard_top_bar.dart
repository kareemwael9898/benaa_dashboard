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
    this.onMenuTap,
  });

  final String title;
  final IconData icon;

  /// Optional trailing controls (e.g. the admin shortcut), drawn at the far
  /// end of the bar so the title block stays exactly where the design puts it.
  final List<Widget> actions;

  /// Present only when the sidebar lives in a drawer (compact layouts).
  final VoidCallback? onMenuTap;

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
          if (onMenuTap != null) ...<Widget>[
            IconButton(
              onPressed: onMenuTap,
              tooltip: 'القائمة',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: 32.r, height: 32.r),
              icon: Icon(Icons.menu, size: 24.r, color: AppColors.goldBright),
            ),
            SizedBox(width: 8.w),
          ],
          // The title block owns the leftover space and the trailing actions
          // keep their intrinsic width, so a phone squeezes the title (with an
          // ellipsis) instead of dropping the admin shortcut.
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.screenTitle,
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(icon, size: 28.r, color: AppColors.goldBright),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
