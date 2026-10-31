/// Lifecycle of one financial return.
///
/// Stored in Firestore as the enum `name` (`active`), so renaming a value is a
/// data migration — append new values instead, and keep [fromName]'s fallback.
enum FinancialReturnStatus {
  active('مفعل'),
  pending('قيد المراجعة'),
  suspended('موقوف');

  const FinancialReturnStatus(this.label);

  /// Arabic copy rendered inside the chip.
  final String label;

  /// Unknown/missing values fall back to [active] so a bad document can never
  /// crash the dashboard — the table always renders something.
  static FinancialReturnStatus fromName(String? name) {
    for (final FinancialReturnStatus value in values) {
      if (value.name == name) return value;
    }
    return active;
  }
}
