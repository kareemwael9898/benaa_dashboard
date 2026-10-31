import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/dashboard_nav_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// One sidebar row: label on the right, icon on the left, 12pt gap.
class SidebarNavTile extends StatelessWidget {
  const SidebarNavTile({super.key, required this.item, this.onTap});

  final DashboardNavItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool active = item.isActive;
    final bool destructive = item.isDestructive;

    final Color labelColor = active
        ? AppColors.gold
        : destructive
        ? AppColors.red
        : AppColors.pureWhite;
    final Color iconColor = active
        ? AppColors.goldBright
        : destructive
        ? AppColors.red
        : AppColors.pureWhite;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          constraints: BoxConstraints(minHeight: active || destructive ? 44.h : 43.h),
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 8.h,
          ),
          decoration: BoxDecoration(
            color: active ? AppColors.navActiveSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: active
                ? Border.all(color: AppColors.navActiveBorder, width: 0.5)
                : destructive
                ? Border.all(color: AppColors.red)
                : null,
            boxShadow: active
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.goldBright,
                      blurRadius: 2.r,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: (active
                          ? AppTextStyles.navLabelActive
                          : AppTextStyles.navLabel)
                      .copyWith(color: labelColor),
                ),
              ),
              SizedBox(width: 12.w),
              Icon(item.icon, size: 26.r, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
