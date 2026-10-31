import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/responsive/app_form_factor.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../financial_returns/model/financial_return.dart';
import '../../../financial_returns/view/widgets/status_chip.dart';

/// Admin list of every return, newest first.
///
/// Same two presentations as the dashboard table: the six-column grid on
/// desktop widths and one card per row on phones.
class AdminReturnsTable extends StatelessWidget {
  const AdminReturnsTable({
    super.key,
    required this.rows,
    required this.onEdit,
    required this.onDelete,
    required this.busy,
  });

  final List<FinancialReturn> rows;
  final ValueChanged<FinancialReturn> onEdit;
  final ValueChanged<FinancialReturn> onDelete;

  /// Writes are in flight: the row actions are disabled.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    if (context.isCompactLayout) {
      return _CardList(
        rows: rows,
        busy: busy,
        onEdit: onEdit,
        onDelete: onDelete,
      );
    }

    return _Grid(
      rows: rows,
      busy: busy,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.rows,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
  });

  final List<FinancialReturn> rows;
  final bool busy;
  final ValueChanged<FinancialReturn> onEdit;
  final ValueChanged<FinancialReturn> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HeaderRow(),
          Expanded(
            child: ListView.separated(
              itemCount: rows.length,
              separatorBuilder: (_, _) => const Divider(
                height: 0.5,
                thickness: 0.5,
                color: AppColors.border,
              ),
              itemBuilder: (BuildContext context, int index) {
                final FinancialReturn row = rows[index];
                return _DataRow(
                  row: row,
                  busy: busy,
                  onEdit: () => onEdit(row),
                  onDelete: () => onDelete(row),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CardList extends StatelessWidget {
  const _CardList({
    required this.rows,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
  });

  final List<FinancialReturn> rows;
  final bool busy;
  final ValueChanged<FinancialReturn> onEdit;
  final ValueChanged<FinancialReturn> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (BuildContext context, int index) {
        final FinancialReturn row = rows[index];
        return _DataCard(
          row: row,
          busy: busy,
          onEdit: () => onEdit(row),
          onDelete: () => onDelete(row),
        );
      },
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard({
    required this.row,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
  });

  final FinancialReturn row;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              StatusChip(status: row.status, compact: true),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  row.amountLabel,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body16,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          _Line(label: 'المرجع', value: row.reference),
          _Line(label: 'الجوال', value: row.phone, ltr: true),
          _Line(label: 'الجوال البديل', value: row.alternatePhone, ltr: true),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                onPressed: busy ? null : onEdit,
                tooltip: 'تعديل',
                iconSize: 20.r,
                color: AppColors.gold,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: busy ? null : onDelete,
                tooltip: 'حذف',
                iconSize: 20.r,
                color: AppColors.red,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.ltr = false});

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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

/// Column order, right → left in RTL: status, amount, reference, phones, actions.
const List<String> _headers = <String>[
  'الحالة',
  'المبلغ',
  'المرجع',
  'الجوال',
  'الجوال البديل',
  'إجراءات',
];

const List<int> _flex = <int>[1, 1, 1, 2, 2, 1];

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      color: AppColors.tableHeader,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < _headers.length; i++)
            Expanded(
              flex: _flex[i],
              child: Center(
                child: Text(_headers[i], style: AppTextStyles.body14Bold),
              ),
            ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.row,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
  });

  final FinancialReturn row;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58.h,
      color: AppColors.surface,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: _flex[0],
            child: Center(child: StatusChip(status: row.status, compact: true)),
          ),
          Expanded(
            flex: _flex[1],
            child: Center(
              child: Text(row.amountLabel, style: AppTextStyles.body14),
            ),
          ),
          Expanded(
            flex: _flex[2],
            child: Center(
              child: Text(row.reference, style: AppTextStyles.body14),
            ),
          ),
          Expanded(
            flex: _flex[3],
            child: Center(
              child: Text(
                row.phone,
                textDirection: TextDirection.ltr,
                style: AppTextStyles.body14,
              ),
            ),
          ),
          Expanded(
            flex: _flex[4],
            child: Center(
              child: Text(
                row.alternatePhone,
                textDirection: TextDirection.ltr,
                style: AppTextStyles.body14,
              ),
            ),
          ),
          Expanded(
            flex: _flex[5],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  onPressed: busy ? null : onEdit,
                  tooltip: 'تعديل',
                  iconSize: 20.r,
                  color: AppColors.gold,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: busy ? null : onDelete,
                  tooltip: 'حذف',
                  iconSize: 20.r,
                  color: AppColors.red,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
