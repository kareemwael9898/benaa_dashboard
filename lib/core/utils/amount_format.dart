import 'package:intl/intl.dart';

/// One shared formatter: constructing [NumberFormat] is comparatively
/// expensive and the dashboard formats amounts on every rebuild.
final NumberFormat _decimal = NumberFormat.decimalPattern('en');

/// "12,500" — Western digits with thousands separators.
///
/// The UI is Arabic but the design renders figures in Latin digits, so the
/// locale is pinned to `en` rather than following the app locale.
String formatAmount(num value) => _decimal.format(value);
