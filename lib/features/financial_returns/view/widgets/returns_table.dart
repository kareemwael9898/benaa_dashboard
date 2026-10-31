import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/responsive/app_form_factor.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../model/financial_return.dart';
import '../../model/returns_table_columns.dart';
import 'status_chip.dart';

/// The returns table.
///
/// Three presentations of the same rows:
/// * wide — the frame's 42pt header plus 50pt rows, five columns;
/// * medium — the same grid, scrolled horizontally at a readable column width,
///   because five columns need ~820pt and the window is narrower than that;
/// * compact — one card per row, since five columns cannot be read on a phone.
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
    final AppFormFactor factor = context.formFactor;

    if (factor == AppFormFactor.compact) {
      return _CardList(
        returns: returns,
        emptyMessage: emptyMessage,
        onClearFilters: onClearFilters,
      );
    }

    final Widget grid = _Grid(
      returns: returns,
      emptyMessage: emptyMessage,
      onClearFilters: onClearFilters,
    );

    if (factor == AppFormFactor.wide) return grid;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(width: AppDimens.tableMinWidth, child: grid),
    );
  }
}

/// Header row plus data rows inside the frame's bordered block.
class _Grid extends StatelessWidget {
  const _Grid({
    required this.returns,
    required this.emptyMessage,
    required this.onClearFilters,
  });

  final List<FinancialReturn> returns;
  final String emptyMessage;
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
            _EmptyRow(message: emptyMessage, onClearFilters: onClearFilters)
          else
            for (final FinancialReturn row in returns) _DataRow(row: row),
        ],
      ),
    );
  }
}

/// One card per row: status and amount on the first line, the long fields
/// underneath, so nothing has to be squeezed into a fifth of the screen.
class _CardList extends StatelessWidget {
  const _CardList({
    required this.returns,
    required this.emptyMessage,
    required this.onClearFilters,
  });

  final List<FinancialReturn> returns;
  final String emptyMessage;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    if (returns.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.blockRadius),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
        child: _EmptyContent(
          message: emptyMessage,
          onClearFilters: onClearFilters,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final FinancialReturn row in returns) _CompactRow(row: row),
      ],
    );
  }
}

class _CompactRow extends StatelessWidget {
  const _CompactRow({required this.row});

  final FinancialReturn row;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.blockRadius),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatusChip(status: row.status, compact: true),
              SizedBox(width: 10.w),
              // The amount is the headline of the card, but it has to give way
              // to the chip on narrow phones instead of overflowing.
              Expanded(
                child: Text(
                  row.amountLabel,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body18Bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _CompactLine(label: 'المرجع', value: row.reference),
          _CompactLine(label: 'الجوال', value: row.phone, ltr: true),
          if (row.alternatePhone != row.phone)
            _CompactLine(
              label: 'الجوال البديل',
              value: row.alternatePhone,
              ltr: true,
            ),
        ],
      ),
    );
  }
}

class _CompactLine extends StatelessWidget {
  const _CompactLine({
    required this.label,
    required this.value,
    this.ltr = false,
  });

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92.w,
            child: Text(label, style: AppTextStyles.body14Muted),
          ),
          Expanded(
            child: Text(
              value,
              textDirection: ltr ? TextDirection.ltr : null,
              style: AppTextStyles.body14,
            ),
          ),
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
        child: _EmptyContent(message: message, onClearFilters: onClearFilters),
      ),
    );
  }
}

/// Shared empty-state body for the grid and the card list.
class _EmptyContent extends StatelessWidget {
  const _EmptyContent({required this.message, this.onClearFilters});

  final String message;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.body16Muted,
        ),
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
    );
  }
}
