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
│   └── widgets/                 shell, sidebar, top bar, clock, brand
└── features/financial_returns/
    ├── model/                   entities, filter fields, repository, sources
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
`ReturnsTable._headerLabels`, `MockFinancialReturnsRemoteDataSource._rows`),
so replacing the real content is a one-line edit.

## Notes on fidelity

- Icons from the file's third-party sets (famicons, solar, humbleicons,
  healthicons, iconmind, ant-design) are mapped to Material equivalents in
  `core/constants/app_icons.dart`; swap in `flutter_svg` assets when exported.
- Text direction follows the design: values inside the table that are
  Latin/numeric (phone numbers) and the sidebar clock are forced LTR so bidi
  doesn't reorder them.
- The sidebar in the frame is 826pt tall (the page is 1199); it is stretched to
  full height here, and its navigation list scrolls.
