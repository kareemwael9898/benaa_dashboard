import 'financial_return.dart';
import 'financial_return_status.dart';

/// Value of the "all cities" option — the default selection.
const String kAllCities = 'الكل';

/// Bucket for rows whose `cityId` is empty or blank.
const String kUncategorisedCity = 'غير محدد';

/// The frame repeats one dropdown three times. Each repetition is a real filter
/// here: city, status and period, combined with AND.
const int kFilterPillCount = 3;

/// Value of the "all statuses" option — the default selection.
const String kAllStatuses = 'الكل';

/// Cities offered when creating a row, and pre-seeded in the dropdowns.
///
/// The dashboard adds any city that only exists in the data on top of this list,
/// so a row written from the console or the REST API is still reachable.
const List<String> kKnownCities = <String>[
  'الدمام',
  'الرياض',
  'جدة',
  'مكة المكرمة',
];

/// Normalised city of a row: blank values fall into [kUncategorisedCity]
/// instead of becoming an unreachable empty option.
String cityOf(FinancialReturn row) {
  final String city = row.cityId.trim();
  return city.isEmpty ? kUncategorisedCity : city;
}

/// Options for the city pills: `الكل`, the known cities, then any city that only
/// exists in the data, then the uncategorised bucket.
///
/// [selectedCity] is always kept in the list, so a pill can never flip to a
/// blank label when its last row disappears.
List<String> cityOptionsFor(List<FinancialReturn> rows, String selectedCity) {
  final List<String> options = <String>[kAllCities];

  void add(String city) {
    if (city.isNotEmpty && !options.contains(city)) options.add(city);
  }

  for (final String city in kKnownCities) {
    add(city);
  }

  final Set<String> present = rows.map(cityOf).toSet();
  final List<String> extra = present
      .where(
        (String city) => city != kUncategorisedCity && !kKnownCities.contains(city),
      )
      .toList()
    ..sort();
  for (final String city in extra) {
    add(city);
  }
  if (present.contains(kUncategorisedCity)) add(kUncategorisedCity);

  add(selectedCity);
  return options;
}

bool matchesCity(FinancialReturn row, String selectedCity) =>
    selectedCity == kAllCities || cityOf(row) == selectedCity;

/// The status pill's options: `الكل` plus every status, in enum order.
final List<String> statusFilterOptions = <String>[
  kAllStatuses,
  for (final FinancialReturnStatus status in FinancialReturnStatus.values)
    status.label,
];

/// The status behind a pill value; `الكل` (or an unknown label) means "no
/// status filter".
FinancialReturnStatus? statusFromFilterValue(String value) {
  for (final FinancialReturnStatus status in FinancialReturnStatus.values) {
    if (status.label == value) return status;
  }
  return null;
}

bool matchesStatus(FinancialReturn row, FinancialReturnStatus? status) =>
    status == null || row.status == status;

const String _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
const String _extendedArabicIndicDigits = '۰۱۲۳۴۵۶۷۸۹';

/// Phone digits only, country code and trunk zero removed.
///
/// `+966 50 123 4567`, `00966501234567`, `0501234567` and `٥٠١٢٣٤٥٦٧` all
/// normalise to `501234567`, so a user can type the number the way they think of
/// it and still match the stored row.
String normalizePhone(String value) {
  final StringBuffer buffer = StringBuffer();

  for (final int rune in value.runes) {
    if (rune >= 0x30 && rune <= 0x39) {
      buffer.writeCharCode(rune);
      continue;
    }
    final String char = String.fromCharCode(rune);
    final int arabicIndic = _arabicIndicDigits.indexOf(char);
    if (arabicIndic != -1) {
      buffer.write(arabicIndic);
      continue;
    }
    final int extended = _extendedArabicIndicDigits.indexOf(char);
    if (extended != -1) buffer.write(extended);
  }

  String digits = buffer.toString();
  if (digits.startsWith('00')) digits = digits.substring(2);
  if (digits.startsWith('966')) digits = digits.substring(3);
  if (digits.startsWith('0')) digits = digits.substring(1);
  return digits;
}

/// Substring match on the primary and alternate phone numbers.
///
/// Numeric input is compared on [normalizePhone] (so `0501…` finds
/// `+966 50 1…`); anything else falls back to a plain substring match, which
/// keeps a stray letter from silently matching every row.
bool matchesPhoneQuery(FinancialReturn row, String query) {
  final String trimmed = query.trim();
  if (trimmed.isEmpty) return true;

  final String needle = normalizePhone(trimmed);
  if (needle.isEmpty) {
    return row.phone.contains(trimmed) ||
        row.alternatePhone.contains(trimmed);
  }

  return normalizePhone(row.phone).contains(needle) ||
      normalizePhone(row.alternatePhone).contains(needle);
}
