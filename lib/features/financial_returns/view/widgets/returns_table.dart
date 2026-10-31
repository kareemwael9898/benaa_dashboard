import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../model/financial_return.dart';
import '../../model/returns_table_columns.dart';
import 'status_chip.dart';

/// The returns table: 42pt header row plus 50pt data rows.
///
/// Header labels come from [kReturnsTableHeaders] (shared with the PDF).
class ReturnsTable extends StatelessWidget {
  const ReturnsTable({
    super.key,
    required this.returns,
    this.emptyMessage = 'لا توجد بيانات',
    this.onClearFilters,
  });

  final List<FinancialReturn> returns;

  /// Shown instead of rows; the filters decide which wording is right.
  final String emptyMessage;

  /// Rendered inside the empty row when the emptiness is caused by filters.
  final VoidCallback? onClearFilters;

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
          _HeaderRow(labels: kReturnsTableHeaders),
          if (returns.isEmpty)
            _EmptyRow(
              message: emptyMessage,
              onClearFilters: onClearFilters,
            )
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
      StatusChip(status: row.status),
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


class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.message, this.onClearFilters});

  final String message;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      child: Container(
        color: AppColors.surface,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: AppTextStyles.body16Muted),
            if (onClearFilters != null) ...[
              SizedBox(height: 4.h),
              TextButton(
                onPressed: onClearFilters,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  'مسح الفلاتر',
                  style: AppTextStyles.body14.copyWith(color: AppColors.gold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
