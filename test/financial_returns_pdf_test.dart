import 'dart:typed_data';

import 'package:benaa_dashboard/features/financial_returns/model/financial_return.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_returns_pdf_builder.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_summary.dart';
import 'package:benaa_dashboard/features/financial_returns/model/return_filter_field.dart';
import 'package:flutter_test/flutter_test.dart';

const _summary = FinancialSummary(
  label: 'إجمالي المبلغ قبل الضربية',
  value: '10000 ريال',
);

const _row = FinancialReturn(
  id: 'row-1',
  cityId: 'الدمام',
  statusLabel: 'مفعل',
  amountLabel: '____ ريال',
  reference: '#/#/#',
  phone: '+966 50 123 4567',
  alternatePhone: '+966 50 123 4567',
);

void main() {
  // rootBundle needs the test binding to load the bundled fonts.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('renders a valid PDF document', () async {
    final Uint8List bytes = await const FinancialReturnsPdfBuilder().build(
      summaries: const <FinancialSummary>[_summary, _summary, _summary],
      returns: const <FinancialReturn>[_row],
      filters: kReturnFilterFields,
      generatedAt: DateTime(2026, 10, 29, 13, 15, 57),
    );

    expect(bytes.length, greaterThan(2000), reason: 'should not be empty');
    expect(
      String.fromCharCodes(bytes.take(5)),
      '%PDF-',
      reason: 'must start with the PDF magic number',
    );
    expect(
      String.fromCharCodes(bytes),
      contains('%%EOF'),
      reason: 'document must be terminated',
    );
  });

  test('renders an empty-state report when no rows match', () async {
    final Uint8List bytes = await const FinancialReturnsPdfBuilder().build(
      summaries: const <FinancialSummary>[_summary],
      returns: const <FinancialReturn>[],
      filters: kReturnFilterFields,
    );

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(2000));
  });

  test('embeds the Arabic font subset', () async {
    final Uint8List bytes = await const FinancialReturnsPdfBuilder().build(
      summaries: const <FinancialSummary>[_summary],
      returns: const <FinancialReturn>[_row],
      filters: kReturnFilterFields,
    );

    final String raw = String.fromCharCodes(bytes);
    expect(raw, contains('/FontFile2'), reason: 'TrueType font must be embedded');
  });
}
