import 'package:flutter/foundation.dart';

/// One dropdown of the "انواع الباقات" filter row.
@immutable
class ReturnFilterField {
  const ReturnFilterField({
    required this.label,
    required this.options,
    required this.selectedIndex,
  });

  /// Bold label above the pill.
  final String label;

  /// Selectable values.
  final List<String> options;

  /// Index into [options] of the current selection.
  final int selectedIndex;

  String get value => options[selectedIndex];

  ReturnFilterField withIndex(int index) => ReturnFilterField(
    label: label,
    options: options,
    selectedIndex: index.clamp(0, options.length - 1),
  );
}

/// Seed for the filter row.
///
/// NOTE: the Figma frame repeats the same dropdown three times (label
/// "الدولة", value "الدمام") — a copy-paste placeholder in the source file.
/// It is mirrored 1:1 here; change these three entries to the real
/// country / region / city filters when the copy is finalised.
const List<ReturnFilterField> kReturnFilterFields = <ReturnFilterField>[
  ReturnFilterField(
    label: 'الدولة',
    options: <String>['الدمام', 'الرياض', 'جدة', 'مكة المكرمة'],
    selectedIndex: 0,
  ),
  ReturnFilterField(
    label: 'الدولة',
    options: <String>['الدمام', 'الرياض', 'جدة', 'مكة المكرمة'],
    selectedIndex: 0,
  ),
  ReturnFilterField(
    label: 'الدولة',
    options: <String>['الدمام', 'الرياض', 'جدة', 'مكة المكرمة'],
    selectedIndex: 0,
  ),
];
