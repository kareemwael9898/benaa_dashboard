import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/responsive/app_form_factor.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../model/financial_return.dart';
import '../../model/financial_summary.dart';
import 'kpi_card.dart';
import 'returns_search_field.dart';
import 'returns_table.dart';

/// The large panel below the filters: KPI tiles, the search field and the
/// returns table (Figma "Frame 312").
class KpiSummaryPanel extends StatelessWidget {
  const KpiSummaryPanel({
    super.key,
    required this.summaries,
    required this.returns,
    required this.query,
    required this.onQueryChanged,
    required this.hasActiveFilters,
    required this.onClearFilters,
    this.hasAnyRows = true,
  });

  final List<FinancialSummary> summaries;
  final List<FinancialReturn> returns;

  /// Current phone search, owned by the Cubit.
  final String query;
  final ValueChanged<String> onQueryChanged;

  /// Whether the emptiness (if any) is caused by the city pill or the search.
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  /// False when the collection itself is empty — the message must not blame
  /// the filters for that.
  final bool hasAnyRows;

  @override
  Widget build(BuildContext context) {
    // Stacked tiles need vertical room; on a landscape handset they would push
    // the table off-screen, so they share a row instead.
    final bool stacked =
        context.isCompactLayout && MediaQuery.sizeOf(context).width < 600;

    return Container(
      padding: EdgeInsets.all(AppDimens.panelPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.blockRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.blockRadius),
              border: Border.all(color: AppColors.green),
            ),
            child: stacked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < summaries.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == summaries.length - 1 ? 0 : 12.h,
                          ),
                          child: KpiCard(summary: summaries[i]),
                        ),
                    ],
                  )
                : IntrinsicHeight(
                    // Keeps the three tiles the same height when a label wraps
                    // on a narrower window.
                    child: Row(
                      children: [
                        for (int i = 0; i < summaries.length; i++)
                          if (i == 0)
                            Expanded(child: KpiCard(summary: summaries[i]))
                          else ...[
                            SizedBox(width: 24.w),
                            Expanded(child: KpiCard(summary: summaries[i])),
                          ],
                      ],
                    ),
                  ),
          ),
          SizedBox(height: AppDimens.sectionGap),
          ReturnsSearchField(
            value: query,
            onChanged: onQueryChanged,
            width: stacked ? double.infinity : null,
          ),
          SizedBox(height: AppDimens.sectionGap),
          ReturnsTable(
            returns: returns,
            emptyMessage: hasActiveFilters && hasAnyRows
                ? 'لا توجد نتائج مطابقة للفلاتر'
                : 'لا توجد بيانات',
            onClearFilters: hasActiveFilters && hasAnyRows
                ? onClearFilters
                : null,
          ),
        ],
      ),
    );
  }
}
