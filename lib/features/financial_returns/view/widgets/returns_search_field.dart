import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "بحث برقم الجوال" field: a real input that keeps the frame's pill look.
///
/// Typing filters the table in memory (city filter and search are combined), so
/// the KPIs and the PDF always describe the rows that are visible.
class ReturnsSearchField extends StatefulWidget {
  const ReturnsSearchField({
    super.key,
    required this.value,
    required this.onChanged,
    this.width,
  });

  /// Current query, owned by the Cubit.
  final String value;

  final ValueChanged<String> onChanged;

  /// Defaults to the frame's 269pt field; stacked layouts pass
  /// [double.infinity].
  final double? width;

  @override
  State<ReturnsSearchField> createState() => _ReturnsSearchFieldState();
}

class _ReturnsSearchFieldState extends State<ReturnsSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(covariant ReturnsSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The query can also be cleared from outside (مسح الفلاتر); mirror it
    // without touching the cursor while the user is typing.
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? 269.w,
      constraints: BoxConstraints(minHeight: 40.h),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceField,
        borderRadius: BorderRadius.circular(AppDimens.blockRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.body16,
              cursorColor: AppColors.gold,
              decoration: InputDecoration(
                hintText: 'بحث برقم الجوال',
                hintStyle: AppTextStyles.body16Muted,
                isDense: true,
                filled: false,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          if (_controller.text.isEmpty)
            Icon(AppIcons.search, size: 24.r, color: AppColors.textMuted)
          else
            IconButton(
              onPressed: _clear,
              tooltip: 'مسح البحث',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: 24.r, height: 24.r),
              icon: Icon(Icons.close, size: 20.r, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}
