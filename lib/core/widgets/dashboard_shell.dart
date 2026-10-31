import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'dashboard_sidebar.dart';
import 'dashboard_top_bar.dart';

/// App shell: sidebar on the right (RTL), content column on the left.
class DashboardShell extends StatelessWidget {
  const DashboardShell({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.actions = const <Widget>[],
  });

  final String title;
  final IconData icon;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureBlack,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DashboardSidebar(),
          Expanded(
            child: Column(
              children: [
                DashboardTopBar(title: title, icon: icon, actions: actions),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
