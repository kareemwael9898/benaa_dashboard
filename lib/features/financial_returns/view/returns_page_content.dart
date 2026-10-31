import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_dimens.dart';
import '../model/returns_filters.dart';
import '../model/returns_period.dart';
import '../view_model/financial_returns_cubit.dart';
import '../view_model/financial_returns_state.dart';
import 'widgets/kpi_summary_panel.dart';
import 'widgets/returns_filters_section.dart';

/// Page body for the loaded state: filters, then the KPI/table panel.
class ReturnsPageContent extends StatelessWidget {
  const ReturnsPageContent({super.key, required this.state});

  final FinancialReturnsLoaded state;

  static const String _reportFileName = 'benaa-financial-returns.pdf';

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
            fields: <ReturnsFilterField>[
              ReturnsFilterField(
                label: 'المدينة',
                options: state.cityOptions,
                value: state.selectedCity,
                onSelected: cubit.selectCity,
              ),
              ReturnsFilterField(
                label: 'الحالة',
                options: statusFilterOptions,
                value: state.selectedStatus?.label ?? kAllStatuses,
                onSelected: (String label) =>
                    cubit.selectStatus(statusFromFilterValue(label)),
              ),
              ReturnsFilterField(
                label: 'الفترة',
                options: periodFilterOptions,
                value: state.selectedPeriod.label,
                onSelected: (String label) =>
                    cubit.selectPeriod(periodFromLabel(label)),
              ),
            ],
            onPrint: () => _handOffReport(context, print: true),
            onExportPdf: () => _handOffReport(context, print: false),
          ),
          SizedBox(height: AppDimens.pageGap),
          KpiSummaryPanel(
            summaries: state.summaries,
            returns: state.returns,
            query: state.query,
            onQueryChanged: cubit.search,
            hasActiveFilters: state.hasActiveFilters,
            onClearFilters: cubit.clearFilters,
            hasAnyRows: state.rows.isNotEmpty,
          ),
        ],
      ),
    );
  }

  /// Builds the PDF from the data on screen, then either opens the system print
  /// dialog or hands the file to the share/download pipeline.
  Future<void> _handOffReport(
    BuildContext context, {
    required bool print,
  }) async {
    final FinancialReturnsCubit cubit = context.read<FinancialReturnsCubit>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final Uint8List? bytes = await cubit.buildReportPdf();
    if (!context.mounted) return;

    if (bytes == null) {
      messenger.showSnackBar(_notice('تعذّر إنشاء التقرير، حاول مرة أخرى.'));
      return;
    }

    try {
      if (print) {
        await Printing.layoutPdf(
          name: _reportFileName,
          onLayout: (_) async => bytes,
        );
      } else {
        await Printing.sharePdf(bytes: bytes, filename: _reportFileName);
        messenger.showSnackBar(_notice('تم تنزيل التقرير'));
      }
    } catch (_) {
      messenger.showSnackBar(_notice('تعذّر فتح التقرير على هذا الجهاز.'));
    }
  }

  SnackBar _notice(String message) => SnackBar(
    content: Text(message),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(AppDimens.pageGap),
  );
}
