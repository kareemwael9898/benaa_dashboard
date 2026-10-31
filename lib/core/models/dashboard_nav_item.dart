import 'package:flutter/widgets.dart';

/// One row of the dashboard sidebar.
@immutable
class DashboardNavItem {
  const DashboardNavItem({
    required this.label,
    required this.icon,
    this.isActive = false,
    this.isDestructive = false,
  });

  /// Arabic label shown next to the icon.
  final String label;

  final IconData icon;

  /// Highlighted with the gold "active" treatment.
  final bool isActive;

  /// Rendered as an outlined, red action (logout).
  final bool isDestructive;
}
