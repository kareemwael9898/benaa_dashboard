# بناء — لوحة التحكم · العوائد المالية

Flutter port of Figma frame `2003:3140` (file `EAJcWejfkDCTeIqAvhdHG1`) — the
RTL Arabic "financial returns" dashboard screen.

## Run

```bash
flutter pub get
flutter run -d chrome --web-browser-flag="--window-size=1440,1199"
```

The design canvas is 1440 × 1199 (`ScreenUtilInit` in `lib/app.dart`), so the
web build is the closest pixel match. Android/iOS targets are generated too.

```bash
flutter analyze
flutter test
```

> **Pinned dependency:** `image` is held below 4.11.0. `pdf` 3.12 caps its
> `archive` constraint at `<4.1.0`, and `image` 4.11 is the first release that
> calls `ZLibDecoder.decodeLazy` (added in archive 4.1.0) — the two together
> fail to compile. Drop the pin once `pdf` widens its range.

## Architecture

Feature-first MVVM with Cubit:

```
lib/
├── app.dart                     MaterialApp + RTL locale + Cubit wiring
├── main.dart                    Hive init, then runApp
├── core/
│   ├── constants/               icon mapping, sidebar navigation
│   ├── models/                  DashboardNavItem
│   ├── theme/                   colors, type scale, dimens, ThemeData
│   ├── utils/                   date/time formatting (clock + PDF)
│   └── widgets/                 shell, sidebar, top bar, clock, brand
└── features/financial_returns/
    ├── model/                   entities, filter fields, repository, sources,
    │                            PDF builder
    ├── view/                    screen + widgets
    └── view_model/              Cubit + sealed states
```

Rules followed:

- **Cubit** for feature state (`Initial → Loading → Loaded | Failure`), all
  sealed; no `setState` anywhere.
- **`ValueNotifier`** for the sidebar clock — local, high-frequency UI state
  doesn't need a Cubit.
- **ScreenUtil** for every dimension and font size (`.w`, `.h`, `.r`, `.sp`).
- **Hive** for caching (no `shared_preferences`).
- Repository is cache-first; city filtering happens in memory.

## Data flow

`ReturnsPageContent` → `FinancialReturnsCubit.selectFilter()` →
`FinancialReturnsRepositoryImpl.fetchReturns(cityId:)` → Hive cache or
`MockFinancialReturnsRemoteDataSource` → `FinancialReturnsLoaded` → `BlocBuilder`.

Swap `MockFinancialReturnsRemoteDataSource` for a Firebase/Supabase
implementation of `FinancialReturnsRemoteDataSource` — nothing else changes.

## PDF export / print

`تنزيل PDF` and `طباعة` render the data **currently on screen** into a real A4
PDF, entirely client-side (`pdf` + `printing`) — no backend endpoint, so the
report can never disagree with the table.

- `FinancialReturnsPdfBuilder` (in `model/`) builds the document: header with
  build timestamp, active filter chips, the KPI tiles, and a paginated table
  whose header row repeats on every page. Arabic shaping, RTL and the embedded
  font subset all come from the bundled IBM Plex Sans Arabic files.
- `FinancialReturnsCubit.buildReportPdf()` feeds it `FinancialReturnsLoaded`
  and returns `Uint8List?` — `null` when nothing is loaded or rendering fails.
- The view owns the OS hand-off: `Printing.sharePdf` (web: a
  `benaa-financial-returns.pdf` download; mobile: the share sheet) and
  `Printing.layoutPdf` (system print dialog). Errors become a snack bar instead
  of a false success message.
- The report uses a light palette on purpose — dark panels waste ink and lose
  contrast on paper.

Empty results still export: the report shows the empty-state notice instead of
the table.

## Error states

- **Loading**: green spinner skeleton while the first fetch runs; filter changes
  keep the current data on screen to avoid a flash.
- **Failure**: message + `إعادة المحاولة` retry button.
- **Report generation**: `تعذّر إنشاء التقرير` when the PDF can't be built, and
  `تعذّر فتح التقرير على هذا الجهاز` when the platform can't hand off the file.

## Tests

```bash
flutter test
```

- `financial_returns_cubit_test.dart` — load, filter, failure, plus PDF
  generation from the loaded state and its two `null` paths.
- `financial_returns_pdf_test.dart` — the bytes are a terminated PDF with an
  embedded font, and the empty-state report still renders.

## Known placeholders (from the Figma file, mirrored as-is)

| Where | What the file contains |
|---|---|
| Filter row | Three identical dropdowns: label `الدولة`, value `الدمام` |
| Table header | All five columns read `رقم الجوال` |
| Table row | `____ ريال`, `#/#/#`, phone repeated twice |
| KPI tiles | Three identical tiles (`10,000 ريال`) |
| Sidebar | `صلاحيات المستخدم` repeated 5× — collapsed to one |
| Logo | Mark is drawn as three gold bars; the Figma paths were not exported |
| Brand font | Cairo ExtraBold is a variable font, weight applied via `fontVariations` |

Each of these lives in a single, commented constant (`kReturnFilterFields`,
`kReturnsTableHeaders`, `MockFinancialReturnsRemoteDataSource._rows`), so
replacing the real content is a one-line edit — the table and the PDF share the
same header constant, so they can't drift apart.

## Notes on fidelity

- Icons from the file's third-party sets (famicons, solar, humbleicons,
  healthicons, iconmind, ant-design) are mapped to Material equivalents in
  `core/constants/app_icons.dart`; swap in `flutter_svg` assets when exported.
- Text direction follows the design: values inside the table that are
  Latin/numeric (phone numbers) and the sidebar clock are forced LTR so bidi
  doesn't reorder them.
- The sidebar in the frame is 826pt tall (the page is 1199); it is stretched to
  full height here, and its navigation list scrolls.
