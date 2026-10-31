import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_text_styles.dart';

/// Live date + time block in the sidebar.
///
/// This is purely local, high-frequency UI state, so it uses a
/// [ValueNotifier] instead of a Cubit (see the feature skill: simple/local
/// state never needs a Cubit).
class LiveClock extends StatefulWidget {
  const LiveClock({super.key, this.initialTime});

  /// Injectable for deterministic widget tests.
  final DateTime? initialTime;

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late final ValueNotifier<DateTime> _now;
  Timer? _ticker;

  static const List<String> _weekdays = <String>[
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  @override
  void initState() {
    super.initState();
    _now = ValueNotifier<DateTime>(widget.initialTime ?? DateTime.now());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _now.value = DateTime.now();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _now.dispose();
    super.dispose();
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  String _formatDate(DateTime value) =>
      '${_weekdays[value.weekday - 1]} ${_two(value.day)} / '
      '${_two(value.month)} / ${value.year}';

  String _formatTime(DateTime value) {
    final int hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final String suffix = value.hour < 12 ? 'am' : 'pm';
    return '${_two(hour12)} : ${_two(value.minute)} : ${_two(value.second)} '
        '$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<DateTime>(
          valueListenable: _now,
          builder: (context, value, _) => Text(
            _formatDate(value),
            textAlign: TextAlign.center,
            style: AppTextStyles.body18Bold,
          ),
        ),
        SizedBox(height: 4.h),
        ValueListenableBuilder<DateTime>(
          valueListenable: _now,
          builder: (context, value, _) => Text(
            _formatTime(value),
            // The clock is a Latin/numeric string: keeping it LTR stops bidi
            // from moving the "pm" suffix and reversing the segments.
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: AppTextStyles.body18Bold,
          ),
        ),
      ],
    );
  }
}
