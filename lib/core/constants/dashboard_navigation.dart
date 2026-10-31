import '../models/dashboard_nav_item.dart';
import 'app_icons.dart';

/// Sidebar navigation, in the same order as the Figma frame.
///
/// The export contains five duplicated "صلاحيات المستخدم" rows (copy-paste
/// leftovers in the source file); they are collapsed into one here.
const List<DashboardNavItem> kDashboardNavItems = <DashboardNavItem>[
  DashboardNavItem(label: 'لوحة التحكم', icon: AppIcons.dashboard),
  DashboardNavItem(label: 'إدارة المستخدمين', icon: AppIcons.users),
  DashboardNavItem(label: 'الدول', icon: AppIcons.countries),
  DashboardNavItem(label: 'المناطق', icon: AppIcons.regions),
  DashboardNavItem(label: 'المدن', icon: AppIcons.cities),
  DashboardNavItem(label: 'إضافة قسم', icon: AppIcons.addSection),
  DashboardNavItem(label: 'الإعلانات', icon: AppIcons.ads),
  DashboardNavItem(label: 'إضافة باقة', icon: AppIcons.addPackage),
  DashboardNavItem(
    label: 'العوائد المالية',
    icon: AppIcons.financialReturns,
    isActive: true,
  ),
  DashboardNavItem(
    label: 'إدارة الحسابات البنكية',
    icon: AppIcons.bankAccounts,
  ),
  DashboardNavItem(label: 'الشكاوي', icon: AppIcons.complaints),
  DashboardNavItem(label: 'صلاحيات المستخدم', icon: AppIcons.permissions),
];

/// Red outlined action pinned to the bottom of the sidebar.
const DashboardNavItem kLogoutNavItem = DashboardNavItem(
  label: 'تسجيل الخروج',
  icon: AppIcons.logout,
  isDestructive: true,
);
