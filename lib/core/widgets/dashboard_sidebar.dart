import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/dashboard_navigation.dart';
import '../models/dashboard_nav_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'brand/brand_wordmark.dart';
import 'live_clock.dart';
import 'sidebar_nav_tile.dart';

/// Right-hand dashboard sidebar: logo, live clock, scrollable navigation and
/// the logout action pinned to the bottom.
class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    super.key,
    this.items = kDashboardNavItems,
    this.onItemSelected,
    this.onLogout,
    this.width,
  });

  final List<DashboardNavItem> items;
  final ValueChanged<DashboardNavItem>? onItemSelected;
  final VoidCallback? onLogout;

  /// Defaults to the frame's 280pt column; the drawer fills its own width.
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? AppDimens.sidebarWidth,
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.sidebarHorizontalPadding,
        vertical: AppDimens.sidebarVerticalPadding,
      ),
      child: Column(
        children: [
          const BrandWordmark(),
          SizedBox(height: 4.h),
          const LiveClock(),
          SizedBox(height: AppDimens.sidebarSpacing),
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final DashboardNavItem item in items)
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: SidebarNavTile(
                          item: item,
                          onTap: () => onItemSelected?.call(item),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppDimens.sidebarSpacing),
          SidebarNavTile(item: kLogoutNavItem, onTap: onLogout),
        ],
      ),
    );
  }
}
