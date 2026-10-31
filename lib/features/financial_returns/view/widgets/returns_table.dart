import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../model/financial_return.dart';

/// The returns table: 42pt header row plus 50pt data rows.
///
/// NOTE: all five header cells read "رقم الجوال" in the Figma file — they are
/// placeholders in the source. They are mirrored as-is; edit [_headerLabels]
/// once the real column names land.
class ReturnsTable extends StatelessWidget {
  const ReturnsTable({super.key, required this.returns});

  final List<FinancialReturn> returns;

  static const List<String> _headerLabels = <String>[
    'رقم الجوال',
    'رقم الجوال',
    'رقم الجوال',
    'رقم الجوال',
    'رقم الجوال',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.blockRadius),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderRow(labels: _headerLabels),
          if (returns.isEmpty)
            const _EmptyRow()
          else
            for (final FinancialReturn row in returns) _DataRow(row: row),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    // Reversed: in RTL the last child is drawn leftmost, which reproduces the
    // column order of the frame.
    final List<String> ordered = labels.reversed.toList();

    return SizedBox(
      height: 42.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < ordered.length; i++)
            _TableCell(
              background: AppColors.tableHeader,
              showDivider: i != ordered.length - 1,
              child: Text(
                ordered[i],
                textAlign: TextAlign.center,
                style: AppTextStyles.body16,
              ),
            ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.row});

  final FinancialReturn row;

  @override
  Widget build(BuildContext context) {
    // Design order is: status, amount, reference, phone, alternate phone.
    final List<Widget> cells = <Widget>[
      _StatusChip(label: row.statusLabel),
      Text(row.amountLabel, style: AppTextStyles.body16),
      Text(row.reference, style: AppTextStyles.body16),
      // Phone numbers are Latin/numeric: LTR keeps the groups in reading
      // order instead of letting bidi flip them.
      Text(
        row.phone,
        textDirection: TextDirection.ltr,
        style: AppTextStyles.body16,
      ),
      Text(
        row.alternatePhone,
        textDirection: TextDirection.ltr,
        style: AppTextStyles.body16,
      ),
    ].reversed.toList();

    return SizedBox(
      height: 50.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < cells.length; i++)
            _TableCell(
              background: AppColors.surface,
              showDivider: i != cells.length - 1,
              child: cells[i],
            ),
        ],
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.child,
    required this.background,
    required this.showDivider,
  });

  final Widget child;
  final Color background;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          border: showDivider
              ? const BorderDirectional(
                  end: BorderSide(color: AppColors.border, width: 0.5),
                )
              : null,
        ),
        child: child,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(label, style: AppTextStyles.body16),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: Container(
        color: AppColors.surface,
        alignment: Alignment.center,
        child: Text('لا توجد بيانات', style: AppTextStyles.body16Muted),
      ),
    );
  }
}
