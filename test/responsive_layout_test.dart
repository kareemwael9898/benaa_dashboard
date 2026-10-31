import 'package:benaa_dashboard/core/responsive/app_form_factor.dart';
import 'package:benaa_dashboard/core/theme/app_theme.dart';
import 'package:benaa_dashboard/core/widgets/dashboard_shell.dart';
import 'package:benaa_dashboard/features/admin/view/widgets/admin_returns_table.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_return.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_return_status.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_returns_kpi_builder.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_summary.dart';
import 'package:benaa_dashboard/features/financial_returns/model/returns_filters.dart';
import 'package:benaa_dashboard/features/financial_returns/model/returns_period.dart';
import 'package:benaa_dashboard/features/financial_returns/model/returns_table_columns.dart';
import 'package:benaa_dashboard/features/financial_returns/view/widgets/kpi_card.dart';
import 'package:benaa_dashboard/features/financial_returns/view/widgets/kpi_summary_panel.dart';
import 'package:benaa_dashboard/features/financial_returns/view/widgets/returns_filter_field.dart';
import 'package:benaa_dashboard/features/financial_returns/view/widgets/returns_filters_section.dart';
import 'package:benaa_dashboard/features/financial_returns/view/widgets/returns_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phone = Size(390, 844);
const Size _tablet = Size(1024, 768);
const Size _landscapePhone = Size(844, 390);
const Size _desktop = Size(1440, 1199);

const List<FinancialReturn> _rows = <FinancialReturn>[
  FinancialReturn(
    id: 'a',
    cityId: 'الدمام',
    status: FinancialReturnStatus.active,
    amount: 10000,
    reference: 'RET-1001',
    phone: '+966 50 123 4567',
    alternatePhone: '+966 50 123 4567',
  ),
  FinancialReturn(
    id: 'b',
    cityId: 'الرياض',
    status: FinancialReturnStatus.pending,
    amount: 4200,
    reference: 'RET-1003',
    phone: '+966 53 907 2214',
    alternatePhone: '+966 53 907 2214',
  ),
];

/// Pumps [child] at [size] with ScreenUtil set up exactly like the app: 1:1
/// below the desktop breakpoint, scaled by `width / 1440` from it up.
///
/// [scrollable] wraps the child in the vertical scroll view the real pages use;
/// screens that own a `ListView` (the shell, the admin list) pass `false` so
/// their viewport keeps a bounded height.
Future<void> _pumpAt(
  WidgetTester tester,
  Size size,
  Widget child, {
  bool scrollable = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: ScreenUtilInit(
        designSize: const Size(1440, 1199),
        splitScreenMode: true,
        enableScaleWH: () => size.width >= AppBreakpoints.desktopMin,
        enableScaleText: () => size.width >= AppBreakpoints.desktopMin,
        builder: (BuildContext context, Widget? _) => MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('ar'),
          supportedLocales: const <Locale>[Locale('ar')],
          localizationsDelegates: const <LocalizationsDelegate<Object>>[
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: scrollable
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  )
                : Padding(padding: const EdgeInsets.all(24), child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Each column is labelled with its own field, once — five identical headers
/// (the design placeholder) would fail here.
void _expectDistinctHeaders() {
  expect(kReturnsTableHeaders.toSet(), hasLength(5), reason: 'no repeats');
  for (final String header in kReturnsTableHeaders) {
    expect(find.text(header), findsOneWidget, reason: header);
  }
}

Widget _filters() => ReturnsFiltersSection(
  fields: <ReturnsFilterField>[
    ReturnsFilterField(
      label: 'المدينة',
      options: const <String>[kAllCities, 'الدمام', 'الرياض'],
      value: kAllCities,
      onSelected: (_) {},
    ),
    ReturnsFilterField(
      label: 'الحالة',
      options: statusFilterOptions,
      value: kAllStatuses,
      onSelected: (_) {},
    ),
    ReturnsFilterField(
      label: 'الفترة',
      options: periodFilterOptions,
      value: ReturnsPeriod.all.label,
      onSelected: (_) {},
    ),
  ],
  onPrint: () {},
  onExportPdf: () {},
);

Widget _panel() {
  final List<FinancialSummary> summaries = buildFinancialSummaries(_rows);
  return KpiSummaryPanel(
    summaries: summaries,
    returns: _rows,
    query: '',
    onQueryChanged: (_) {},
    hasActiveFilters: false,
    onClearFilters: () {},
  );
}

void main() {
  group('filters', () {
    testWidgets('stack full width on a phone', (WidgetTester tester) async {
      await _pumpAt(tester, _phone, _filters());

      final Size pill = tester.getSize(
        find.byType(ReturnsFilterFieldView).first,
      );
      expect(pill.width, closeTo(_phone.width - 48, 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('keep the frame row on a tablet, scaled', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _tablet, _filters());

      final Size pill = tester.getSize(
        find.byType(ReturnsFilterFieldView).first,
      );
      // 900+ gets the frame back, scaled by width / 1440 like it always was.
      expect(pill.width, closeTo(269 * _tablet.width / 1440, 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('share one row on a landscape phone', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _landscapePhone, _filters());

      final Set<double> tops = <double>{
        for (final Element element
            in find.byType(ReturnsFilterFieldView).evaluate())
          tester.getTopLeft(find.byWidget(element.widget)).dy,
      };
      expect(tops, hasLength(1), reason: 'stacking fills a landscape screen');
      // Two 12pt gaps shared between three equal pills.
      final double expected =
          (_landscapePhone.width - 48 - 24) / kFilterPillCount;
      expect(
        tester.getSize(find.byType(ReturnsFilterFieldView).first).width,
        closeTo(expected, 1),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('keep the frame row on a desktop', (WidgetTester tester) async {
      await _pumpAt(tester, _desktop, _filters());

      final List<Offset> tops = <Offset>[
        for (final Element element
            in find.byType(ReturnsFilterFieldView).evaluate())
          tester.getTopLeft(find.byWidget(element.widget)),
      ];
      expect(tops, hasLength(3));
      expect(tops.map((Offset o) => o.dy).toSet(), hasLength(1));
    });

    testWidgets('each pill filters something different', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _desktop, _filters());

      // The frame draws one dropdown three times; these are the three fields.
      expect(find.text('المدينة'), findsOneWidget);
      expect(find.text('الحالة'), findsOneWidget);
      expect(find.text('الفترة'), findsOneWidget);
      expect(find.byType(ReturnsFilterFieldView), findsNWidgets(3));
    });
  });

  group('returns table', () {
    testWidgets('becomes cards on a phone', (WidgetTester tester) async {
      await _pumpAt(tester, _phone, const ReturnsTable(returns: _rows));

      // Column headers only exist in the grid; the card shows field labels
      // (المرجع, الجوال, الجوال البديل) instead.
      for (final String header in <String>['الحالة', 'المبلغ']) {
        expect(find.text(header), findsNothing, reason: header);
      }
      expect(find.text('المرجع'), findsNWidgets(_rows.length));
      expect(find.text('RET-1001'), findsOneWidget);
      expect(find.text('+966 50 123 4567'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps five columns on a desktop', (WidgetTester tester) async {
      await _pumpAt(tester, _desktop, const ReturnsTable(returns: _rows));

      _expectDistinctHeaders();
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the grid on a tablet', (WidgetTester tester) async {
      await _pumpAt(tester, _tablet, const ReturnsTable(returns: _rows));

      _expectDistinctHeaders();
      final Finder scroller = find.byWidgetPredicate(
        (Widget widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.horizontal,
      );
      expect(scroller, findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('KPI panel', () {
    testWidgets('stacks its tiles on a phone', (WidgetTester tester) async {
      await _pumpAt(tester, _phone, _panel());

      final double first = tester.getTopLeft(find.byType(KpiCard).first).dy;
      final double second = tester.getTopLeft(find.byType(KpiCard).at(1)).dy;
      expect(second, greaterThan(first));
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps them side by side on a landscape phone', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _landscapePhone, _panel());

      final double first = tester.getTopLeft(find.byType(KpiCard).first).dy;
      final double second = tester.getTopLeft(find.byType(KpiCard).at(1)).dy;
      expect(second, equals(first));
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps them side by side on a desktop', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _desktop, _panel());

      final double first = tester.getTopLeft(find.byType(KpiCard).first).dy;
      final double second = tester.getTopLeft(find.byType(KpiCard).at(1)).dy;
      expect(second, equals(first));
      expect(tester.takeException(), isNull);
    });
  });

  group('shell', () {
    testWidgets('moves the sidebar into a drawer on a phone', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _phone,
        const DashboardShell(
          title: 'العوائد المالية',
          icon: Icons.emoji_events_outlined,
          child: SizedBox.shrink(),
        ),
        scrollable: false,
      );

      // The drawer is built lazily, so only the trigger exists up front.
      final Finder menu = find.byIcon(Icons.menu);
      expect(menu, findsOneWidget);

      await tester.tap(menu);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Drawer), findsOneWidget);
      // The navigation lives inside the drawer at this width.
      expect(find.text('لوحة التحكم'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the sidebar at the breakpoint', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _tablet,
        const DashboardShell(
          title: 'العوائد المالية',
          icon: Icons.emoji_events_outlined,
          child: SizedBox.shrink(),
        ),
        scrollable: false,
      );

      expect(find.byIcon(Icons.menu), findsNothing);
      expect(find.text('لوحة التحكم'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the permanent sidebar on a desktop', (
      WidgetTester tester,
    ) async {
      await _pumpAt(
        tester,
        _desktop,
        const DashboardShell(
          title: 'العوائد المالية',
          icon: Icons.emoji_events_outlined,
          child: SizedBox.shrink(),
        ),
        scrollable: false,
      );

      expect(find.byType(Drawer), findsNothing);
      expect(find.byIcon(Icons.menu), findsNothing);
      expect(find.text('لوحة التحكم'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('admin table', () {
    testWidgets('becomes cards on a phone', (WidgetTester tester) async {
      await _pumpAt(
        tester,
        _phone,
        AdminReturnsTable(
          rows: _rows,
          busy: false,
          onEdit: (_) {},
          onDelete: (_) {},
        ),
        scrollable: false,
      );

      expect(find.text('إجراءات'), findsNothing);
      expect(find.text('RET-1001'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps its columns on a desktop', (WidgetTester tester) async {
      await _pumpAt(
        tester,
        _desktop,
        AdminReturnsTable(
          rows: _rows,
          busy: false,
          onEdit: (_) {},
          onDelete: (_) {},
        ),
        scrollable: false,
      );

      expect(find.text('إجراءات'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
