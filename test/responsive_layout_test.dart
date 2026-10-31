import 'package:benaa_dashboard/core/theme/app_theme.dart';
import 'package:benaa_dashboard/core/widgets/dashboard_shell.dart';
import 'package:benaa_dashboard/features/admin/view/widgets/admin_returns_table.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_return.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_return_status.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_returns_kpi_builder.dart';
import 'package:benaa_dashboard/features/financial_returns/model/financial_summary.dart';
import 'package:benaa_dashboard/features/financial_returns/model/returns_filters.dart';
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
/// below 1440, scaled above it.
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
        enableScaleWH: () => false,
        enableScaleText: () => false,
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

Widget _filters() => ReturnsFiltersSection(
  cityOptions: const <String>[kAllCities, 'الدمام', 'الرياض'],
  selectedCity: kAllCities,
  onCitySelected: (_) {},
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

    testWidgets('wrap instead of shrinking on a tablet', (
      WidgetTester tester,
    ) async {
      await _pumpAt(tester, _tablet, _filters());

      final Size pill = tester.getSize(
        find.byType(ReturnsFilterFieldView).first,
      );
      expect(pill.width, closeTo(269, 1), reason: 'frame width, not stretched');
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
  });

  group('returns table', () {
    testWidgets('becomes cards on a phone', (WidgetTester tester) async {
      await _pumpAt(tester, _phone, const ReturnsTable(returns: _rows));

      // Column headers only exist in the grid.
      expect(find.text('رقم الجوال'), findsNothing);
      expect(find.text('RET-1001'), findsOneWidget);
      expect(find.text('+966 50 123 4567'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps five columns on a desktop', (WidgetTester tester) async {
      await _pumpAt(tester, _desktop, const ReturnsTable(returns: _rows));

      expect(find.text('رقم الجوال'), findsNWidgets(5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrolls sideways on a tablet', (WidgetTester tester) async {
      await _pumpAt(tester, _tablet, const ReturnsTable(returns: _rows));

      expect(find.text('رقم الجوال'), findsNWidgets(5));
      final Finder scroller = find.byWidgetPredicate(
        (Widget widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.horizontal,
      );
      expect(scroller, findsOneWidget);
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
