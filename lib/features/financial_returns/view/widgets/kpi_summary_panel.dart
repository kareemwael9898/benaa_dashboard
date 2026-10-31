import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    this.onSearchTap,
  });

  final List<FinancialSummary> summaries;
  final List<FinancialReturn> returns;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
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
          SizedBox(height: AppDimens.sectionGap),
          ReturnsSearchField(onTap: onSearchTap),
          SizedBox(height: AppDimens.sectionGap),
          ReturnsTable(returns: returns),
        ],
      ),
    );
  }
}
