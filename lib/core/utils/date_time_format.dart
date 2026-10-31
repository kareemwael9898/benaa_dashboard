/// Date/time formatting shared by the sidebar clock and the PDF report.
///
/// Hand-rolled rather than `intl` so the exact strings match the design
/// ("الخميس 29 / 10 / 2026" and "01 : 15 : 57 pm") without a locale database.
abstract final class DateTimeFormat {
  static const List<String> _weekdays = <String>[
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static String _two(int value) => value.toString().padLeft(2, '0');

  /// "الخميس 29 / 10 / 2026".
  static String arabicDate(DateTime value) =>
      '${_weekdays[value.weekday - 1]} ${_two(value.day)} / '
      '${_two(value.month)} / ${value.year}';

  /// "01 : 15 : 57 pm".
  static String clockTime(DateTime value) {
    final int hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final String suffix = value.hour < 12 ? 'am' : 'pm';
    return '${_two(hour12)} : ${_two(value.minute)} : ${_two(value.second)} '
        '$suffix';
  }

  /// "2026-10-31" — used in downloaded file names.
  static String isoDate(DateTime value) =>
      '${value.year}-${_two(value.month)}-${_two(value.day)}';
}
