import 'package:flutter/material.dart';

import '../responsive/app_form_factor.dart';
import '../theme/app_colors.dart';
import 'dashboard_sidebar.dart';
import 'dashboard_top_bar.dart';

/// App shell: sidebar on the right (RTL), content column on the left.
///
/// Under [AppBreakpoints.mediumMin] the sidebar moves into a drawer and the
/// content takes the full width — a permanent 280pt sidebar would eat most of a
/// phone screen.
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
    if (context.isCompactLayout) {
      return Scaffold(
        backgroundColor: AppColors.pureBlack,
        drawer: const Drawer(
          backgroundColor: AppColors.surface,
          child: SafeArea(child: DashboardSidebar(width: double.infinity)),
        ),
        body: Builder(
          builder: (BuildContext context) => Column(
            children: <Widget>[
              DashboardTopBar(
                title: title,
                icon: icon,
                actions: actions,
                onMenuTap: () => Scaffold.of(context).openDrawer(),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

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
