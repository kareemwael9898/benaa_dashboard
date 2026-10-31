import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_dimens.dart';
import '../view_model/financial_returns_cubit.dart';
import '../view_model/financial_returns_state.dart';
import 'widgets/kpi_summary_panel.dart';
import 'widgets/returns_filters_section.dart';

/// Page body for the loaded state: filters, then the KPI/table panel.
class ReturnsPageContent extends StatelessWidget {
  const ReturnsPageContent({super.key, required this.state});

  final FinancialReturnsLoaded state;

  @override
  Widget build(BuildContext context) {
    final FinancialReturnsCubit cubit = context.read<FinancialReturnsCubit>();

    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(
        AppDimens.pageHorizontalPadding,
        AppDimens.pageTopPadding,
        AppDimens.pageHorizontalPadding,
        AppDimens.pageGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReturnsFiltersSection(
            filters: state.filters,
            onFilterSelected: (int fieldIndex, int optionIndex) {
              cubit.selectFilter(
                fieldIndex: fieldIndex,
                optionIndex: optionIndex,
              );
            },
            onPrint: () => _runAction(
              context,
              cubit.printReport,
              'تم إرسال أمر الطباعة',
            ),
            onExportPdf: () => _runAction(
              context,
              cubit.exportPdf,
              'تم تنزيل ملف PDF',
            ),
          ),
          SizedBox(height: AppDimens.pageGap),
          KpiSummaryPanel(
            summaries: state.summaries,
            returns: state.returns,
          ),
        ],
      ),
    );
  }

  /// Awaits a cubit action then confirms it with a snack bar.
  Future<void> _runAction(
    BuildContext context,
    Future<void> Function() action,
    String confirmation,
  ) async {
    await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(confirmation),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppDimens.pageGap),
      ),
    );
  }
}
