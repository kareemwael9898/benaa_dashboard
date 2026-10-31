/// Date window applied to the rows by the "الفترة" filter pill.
///
/// Windows are calendar based, not rolling days, so "this month" means the
/// calendar month and "three months" means this month plus the two before it —
/// what a reader expects on the 1st, when a rolling window would look wrong.
enum ReturnsPeriod {
  all('الكل'),
  thisMonth('هذا الشهر'),
  lastThreeMonths('آخر ٣ أشهر'),
  thisYear('هذا العام');

  const ReturnsPeriod(this.label);

  /// Arabic copy shown in the pill and in the PDF chip.
  final String label;
}

/// The pill's options, in enum order.
final List<String> periodFilterOptions = <String>[
  for (final ReturnsPeriod period in ReturnsPeriod.values) period.label,
];

/// The period behind a pill value; an unknown label falls back to
/// [ReturnsPeriod.all] so a stale option can never hide every row.
ReturnsPeriod periodFromLabel(String label) {
  for (final ReturnsPeriod period in ReturnsPeriod.values) {
    if (period.label == label) return period;
  }
  return ReturnsPeriod.all;
}

/// Whether a row created at [createdAt] falls inside [period].
///
/// [createdAt] arrives as UTC (a Firestore timestamp) while [now] is local, so
/// both are compared in local time — otherwise a row created at 22:00 on the
/// last day of a month would land in the next one. A row with no date cannot be
/// placed in a window, so it only shows under [ReturnsPeriod.all].
bool matchesPeriod(DateTime? createdAt, ReturnsPeriod period, DateTime now) {
  if (period == ReturnsPeriod.all) return true;
  if (createdAt == null) return false;

  final DateTime row = createdAt.toLocal();
  final DateTime reference = now.toLocal();

  switch (period) {
    case ReturnsPeriod.all:
      return true;
    case ReturnsPeriod.thisMonth:
      return row.year == reference.year && row.month == reference.month;
    case ReturnsPeriod.lastThreeMonths:
      // Dart normalises an out-of-range month, so this is correct in January.
      final DateTime start = DateTime(reference.year, reference.month - 2, 1);
      return !row.isBefore(start);
    case ReturnsPeriod.thisYear:
      return row.year == reference.year;
  }
}
