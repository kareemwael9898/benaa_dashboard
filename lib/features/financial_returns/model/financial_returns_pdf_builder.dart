import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/date_time_format.dart';
import 'financial_return.dart';
import 'financial_summary.dart';
import 'return_filter_field.dart';
import 'returns_table_columns.dart';

/// Renders the financial-returns screen as a printable A4 report.
///
/// Pure Dart (`pdf` package) — no backend, no platform channels — so it works
/// identically on web, Android and iOS. The bundled IBM Plex Sans Arabic font
/// is embedded in the document, which is what makes the Arabic shaping and the
/// RTL layout come out correctly.
///
/// The report uses a light palette on purpose: dark panels look right on screen
/// but waste ink and lose contrast on paper.
class FinancialReturnsPdfBuilder {
  const FinancialReturnsPdfBuilder();

  static const String _regularAsset =
      'assets/fonts/IBMPlexSansArabic-Regular.ttf';
  static const String _boldAsset = 'assets/fonts/IBMPlexSansArabic-Bold.ttf';

  // Palette: brand colours, tuned for white paper.
  static const PdfColor _ink = PdfColor.fromInt(0xFF141519);
  static const PdfColor _muted = PdfColor.fromInt(0xFF6F7075);
  static const PdfColor _gold = PdfColor.fromInt(0xFFE8C15B);
  static const PdfColor _goldInk = PdfColor.fromInt(0xFF8A6B1F);
  static const PdfColor _green = PdfColor.fromInt(0xFF478751);
  static const PdfColor _greenWash = PdfColor.fromInt(0xFFEAF2EC);
  static const PdfColor _border = PdfColor.fromInt(0xFFB3B5B9);
  static const PdfColor _headerBg = PdfColor.fromInt(0xFF2D3037);
  static const PdfColor _zebra = PdfColor.fromInt(0xFFF7F8FA);
  static const PdfColor _white = PdfColors.white;

  /// Parsed once per isolate and reused by later exports.
  static Future<(pw.Font, pw.Font)>? _fonts;

  Future<(pw.Font, pw.Font)> _loadFonts() {
    return _fonts ??= () async {
      final ByteData regular = await rootBundle.load(_regularAsset);
      final ByteData bold = await rootBundle.load(_boldAsset);
      return (pw.Font.ttf(regular), pw.Font.ttf(bold));
    }();
  }

  /// Builds the report and returns the PDF bytes.
  Future<Uint8List> build({
    required List<FinancialSummary> summaries,
    required List<FinancialReturn> returns,
    required List<ReturnFilterField> filters,
    DateTime? generatedAt,
  }) async {
    final (pw.Font regular, pw.Font bold) = await _loadFonts();
    final DateTime stamp = generatedAt ?? DateTime.now();

    final pw.Document document = pw.Document(
      title: 'العوائد المالية',
      author: 'بناء',
      subject: 'تقرير العوائد المالية',
      creator: 'بناء — لوحة التحكم',
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 26, 28, 24),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        header: (pw.Context context) => context.pageNumber == 1
            ? pw.SizedBox()
            : _continuationHeader(),
        footer: (pw.Context context) => _footer(context, stamp),
        build: (pw.Context context) => <pw.Widget>[
          _header(stamp),
          pw.SizedBox(height: 14),
          _filterChips(filters),
          pw.SizedBox(height: 12),
          _kpiRow(summaries),
          pw.SizedBox(height: 18),
          pw.Text('تفاصيل العوائد', style: _style(size: 11, bold: true)),
          pw.SizedBox(height: 6),
          if (returns.isEmpty) _emptyNotice() else _table(returns),
        ],
      ),
    );

    return document.save();
  }

  // ---------------------------------------------------------------------------
  // Sections
  // ---------------------------------------------------------------------------

  pw.Widget _header(DateTime stamp) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _gold, width: 2),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'العوائد المالية',
                  style: _style(size: 20, bold: true),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'تقرير مالي — لوحة تحكم بناء',
                  style: _style(size: 9, color: _muted),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('بناء', style: _style(size: 16, bold: true, color: _goldInk)),
              pw.SizedBox(height: 3),
              pw.Text(
                DateTimeFormat.arabicDate(stamp),
                style: _style(size: 8.5, color: _muted),
              ),
              pw.Text(
                DateTimeFormat.clockTime(stamp),
                textDirection: pw.TextDirection.ltr,
                style: _style(size: 8.5, color: _muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _continuationHeader() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _border, width: 0.5)),
      ),
      child: pw.Row(
        children: [
          pw.Text('العوائد المالية', style: _style(size: 10, bold: true)),
          pw.Spacer(),
          pw.Text('بناء', style: _style(size: 9, bold: true, color: _goldInk)),
        ],
      ),
    );
  }

  pw.Widget _filterChips(List<ReturnFilterField> filters) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        for (final ReturnFilterField field in filters)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: _zebra,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              '${field.label}: ${field.value}',
              style: _style(size: 8.5),
            ),
          ),
      ],
    );
  }

  pw.Widget _kpiRow(List<FinancialSummary> summaries) {
    final List<pw.Widget> children = <pw.Widget>[];
    for (int i = 0; i < summaries.length; i++) {
      if (i > 0) children.add(pw.SizedBox(width: 8));
      children.add(pw.Expanded(child: _kpiBox(summaries[i])));
    }

    return pw.Row(children: children);
  }

  pw.Widget _kpiBox(FinancialSummary summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: pw.BoxDecoration(
        color: _greenWash,
        border: pw.Border.all(color: _green, width: 0.7),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            summary.label,
            textAlign: pw.TextAlign.center,
            style: _style(size: 8.5),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            summary.value,
            textAlign: pw.TextAlign.center,
            style: _style(size: 14, bold: true),
          ),
        ],
      ),
    );
  }

  pw.Widget _table(List<FinancialReturn> returns) {
    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: 0.5),
      columnWidths: const <int, pw.TableColumnWidth>{
        0: pw.FlexColumnWidth(1),
        1: pw.FlexColumnWidth(1.2),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1.7),
        4: pw.FlexColumnWidth(1.7),
      },
      children: <pw.TableRow>[
        pw.TableRow(
          repeat: true,
          decoration: const pw.BoxDecoration(color: _headerBg),
          children: <pw.Widget>[
            for (final String header in kReturnsTableHeaders)
              _cell(
                pw.Text(
                  header,
                  textAlign: pw.TextAlign.center,
                  style: _style(size: 8.5, bold: true, color: _white),
                ),
              ),
          ],
        ),
        for (int i = 0; i < returns.length; i++)
          pw.TableRow(
            decoration: pw.BoxDecoration(color: i.isEven ? _white : _zebra),
            children: _dataCells(returns[i]),
          ),
      ],
    );
  }

  /// Cell order matches the on-screen table: status, amount, reference, phone,
  /// alternate phone.
  List<pw.Widget> _dataCells(FinancialReturn row) {
    return <pw.Widget>[
      _cell(
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: pw.BoxDecoration(
            color: _green,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            row.statusLabel,
            style: _style(size: 8, color: _white),
          ),
        ),
      ),
      _cell(pw.Text(row.amountLabel, style: _style(size: 9))),
      _cell(pw.Text(row.reference, style: _style(size: 9))),
      _cell(
        pw.Text(
          row.phone,
          textDirection: pw.TextDirection.ltr,
          style: _style(size: 9),
        ),
      ),
      _cell(
        pw.Text(
          row.alternatePhone,
          textDirection: pw.TextDirection.ltr,
          style: _style(size: 9),
        ),
      ),
    ];
  }

  pw.Widget _cell(pw.Widget child) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: child,
    );
  }

  pw.Widget _emptyNotice() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 16),
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _border, width: 0.5),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        'لا توجد عوائد مطابقة للفلاتر المحددة',
        style: _style(size: 9, color: _muted),
      ),
    );
  }

  pw.Widget _footer(pw.Context context, DateTime stamp) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _border, width: 0.5)),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            'بناء — تقرير العوائد المالية · ${DateTimeFormat.isoDate(stamp)}',
            style: _style(size: 7.5, color: _muted),
          ),
          pw.Spacer(),
          pw.Text(
            'صفحة ${context.pageNumber} من ${context.pagesCount}',
            style: _style(size: 7.5, color: _muted),
          ),
        ],
      ),
    );
  }

  pw.TextStyle _style({
    required double size,
    bool bold = false,
    PdfColor color = _ink,
  }) {
    return pw.TextStyle(
      fontSize: size,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color,
      height: 1.35,
    );
  }
}
