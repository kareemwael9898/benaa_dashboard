import 'package:flutter/material.dart';

/// Icon mapping for the screen.
///
/// The Figma file uses several third-party icon sets (`famicons`,
/// `material-symbols`, `solar`, `humbleicons`, `healthicons`, `iconmind`,
/// `ant-design`). They are mapped to the closest Material symbol here so the
/// mapping lives in one place — swap any line for an `SvgPicture`/custom asset
/// when the real icon set lands.
abstract final class AppIcons {
  // Sidebar ---------------------------------------------------------------
  static const IconData dashboard = Icons.home_outlined;
  static const IconData users = Icons.people_outline;
  static const IconData countries = Icons.public;
  static const IconData regions = Icons.place_outlined;
  static const IconData cities = Icons.location_city_outlined;
  static const IconData addSection = Icons.widgets_outlined;
  static const IconData ads = Icons.emoji_events_outlined;
  static const IconData addPackage = Icons.inventory_2_outlined;
  static const IconData financialReturns = Icons.emoji_events_outlined;
  static const IconData bankAccounts = Icons.account_balance_outlined;
  static const IconData complaints = Icons.forum_outlined;
  static const IconData permissions = Icons.shield_outlined;
  static const IconData logout = Icons.logout;

  // Actions ---------------------------------------------------------------
  static const IconData print = Icons.print_outlined;
  static const IconData download = Icons.download_rounded;
  static const IconData search = Icons.search;
  static const IconData chevron = Icons.keyboard_arrow_down;
}
