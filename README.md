# بناء — لوحة التحكم · العوائد المالية

Flutter port of Figma frame `2003:3140` (file `EAJcWejfkDCTeIqAvhdHG1`) — the
RTL Arabic "financial returns" dashboard screen — plus the admin page that owns
its data. Everything is live: a row added in the admin page appears on the
dashboard (and in its KPI tiles) without a refresh.

## Run

```bash
flutter pub get
flutter run -d chrome --web-browser-flag="--window-size=1440,1199"
```

The design canvas is 1440 × 1199 (`ScreenUtilInit` in `lib/app.dart`), so the
web build is the closest pixel match. Android/iOS targets are generated too.

The Firebase config is committed (`lib/firebase_options.dart`), so the app runs
against the real backend out of the box:

- project `benaa-dashboard`, Firestore in `me-central2`
- `returns` — public read, admin-only write
- `admins/{uid}` — the admin allow-list; not writable from the client

Without a backend (offline, or on Linux desktop where `cloud_firestore` has no
implementation), run on the bundled demo data:

```bash
flutter run -d chrome --dart-define=USE_MOCK=true
```

Mock mode accepts any non-empty email/password on the admin page and keeps its
rows in memory.

```bash
flutter analyze
flutter test
```

> **Pinned dependency:** `image` is held below 4.11.0. `pdf` 3.12 caps its
> `archive` constraint at `<4.1.0`, and `image` 4.11 is the first release that
> calls `ZLibDecoder.decodeLazy` (added in archive 4.1.0) — the two together
> fail to compile. Drop the pin once `pdf` widens its range.

## Admin page

`/#/admin` (also reachable from `إدارة` in the dashboard's top bar).

Sign-in is Firebase Auth email/password; the account must **also** exist as a
document in `admins/{uid}`. Both halves are enforced:

- the UI checks `admins/{uid}` after sign-in and signs the session straight back
  out with `هذا الحساب لا يملك صلاحية إدارة العوائد` when it is missing;
- `firestore.rules` re-checks the same document on every write, so a client that
  skips the UI still cannot write.

Creating an admin (one-off, from the console — a client can't grant itself):

1. Firebase console → Authentication → add the user (email/password).
2. Copy the user's UID, then Firestore → `admins` → new document with that UID
   as the id (fields `email`, `createdAt` are informational).

> On the Spark plan `identityPlatform:initializeAuth` fails with
> `BILLING_NOT_ENABLED`; email/password must be enabled once from the console
> (Authentication → Get started).

The page manages the `returns` collection only — every row is
`cityId`, `status` (`active` | `pending` | `suspended`), `amount` (number),
`reference`, `phone`, `alternatePhone`, `createdAt` (server timestamp):

- **إضافة صف** / **تعديل** — validated form (amount ≥ 0, reference, phone);
  the city list is the same constant the dashboard filters on, so a row can
  never fall outside the filter.
- **حذف** — confirmation dialog, then a hard delete.
- **استيراد بيانات التصميم** — writes the three demo rows (the first mirrors
  the Figma row exactly) when the collection is empty.
- Errors from Firestore (`permission-denied`, `unavailable`…) are translated to
  Arabic snack bars instead of a false success message.

## Architecture

Feature-first MVVM with Cubit:

```
lib/
├── app.dart                     MaterialApp + RTL locale + routes + Cubit wiring
├── main.dart                    Hive init → Firebase → runApp
├── core/
│   ├── config/                  USE_MOCK / Linux detection
│   ├── constants/               icons, sidebar navigation, routes
│   ├── di/                      AppDependencies (firebase + mock graphs)
│   ├── models/                  DashboardNavItem
│   ├── responsive/              form-factor tiers (compact/medium/wide)
│   ├── theme/                   colors, type scale, dimens, ThemeData
│   ├── utils/                   amount, date/time formatting (clock + PDF)
│   └── widgets/                 shell, sidebar, top bar, clock, brand
└── features/
    ├── financial_returns/
    │   ├── model/               entity + status enum, filter fields, KPI
    │   │                        builder, repository, Hive cache, Firestore
    │   │                        source, PDF builder
    │   ├── view/                screen + widgets
    │   └── view_model/          Cubit + sealed states
    ├── auth/
    │   ├── model/               admin auth repository (Firebase + mock)
    │   ├── view/                login form
    │   └── view_model/          AuthCubit + sealed states
    └── admin/
        ├── model/               admin repository (Firestore + mock)
        ├── view/                gate, screen, table, row form
        └── view_model/          AdminReturnsCubit + sealed states
```

Rules followed:

- **Cubit** for feature state, all sealed (`Initial → Loading → Loaded |
  Failure`); no `setState` anywhere. Dialog forms own only their text
  controllers.
- **`ValueNotifier`** for the sidebar clock — local, high-frequency UI state
  doesn't need a Cubit.
- **ScreenUtil** for every dimension and font size (`.w`, `.h`, `.r`, `.sp`),
  with scaling enabled from the 900pt desktop breakpoint up — see
  [Responsive behaviour](#responsive-behaviour).
- **Hive** for the cached first frame (no `shared_preferences`).
- Read and write paths are separate repositories: the dashboard's is read-only,
  so the public screen can't accidentally gain write capability.

## Responsive behaviour

The frame is 1440×1199 and ScreenUtil scales it by `width / 1440`, as always —
but only from **900pt** up (`enableScaleWH` / `enableScaleText` in `app.dart`).
Below 900 scaling is off, so a design pixel *is* a logical pixel: 16sp stays
16px instead of becoming 4.3px on a 390px phone. `core/responsive/app_form_factor.dart`
picks the composition:

| Tier | Width | Shell | Filters | KPIs | Tables | Sizing |
|---|---|---|---|---|---|---|
| `desktop` | ≥ 900 | permanent 280pt sidebar | three pills in one row | three tiles across | the frame's grid | scaled by `w / 1440` |
| `compact` | < 900 | drawer + hamburger | full width below 600, three across from 600 up | stacked below 600, across from 600 up | one card per row | 1:1 |

Why 900: from there the frame still fits when scaled (at 900 that is ×0.625, so
the three pills take 552pt of the 572pt content column), and the proportional
look of landscape tablets and small laptop windows is exactly what it was
before the compact port. Below 900 a five-column grid and a 280pt sidebar
cannot be read at all, so the sidebar moves into a drawer and every row becomes
a card with the status and amount on top and the long fields underneath.

Inside `compact` the filters and the KPI tiles only stack below 600pt: on a
landscape handset (844×390) a stacked column of three dropdowns would fill the
whole first screen, so from 600 up the three pills share one row (~110pt for
the block instead of ~420pt) and the tiles stay side by side. The admin page
and the row form follow the same tiers (stacked fields, full-width dialog).

`test/responsive_layout_test.dart` pumps the shell, filters, KPI panel and both
tables at 390×844, 1024×768 and 1440×1199 and asserts the switch, so a new
fixed width in the desktop composition fails a test instead of silently
overflowing on a phone.

## Data flow

```
Firestore `returns` ──▶ FirestoreFinancialReturnsRemoteDataSource.watch()
                     ──▶ FinancialReturnsRepositoryImpl.watchReturns()
                          (Hive snapshot first, then live frames)
                     ──▶ FinancialReturnsCubit ──▶ FinancialReturnsLoaded
```

`FinancialReturnsLoaded` holds *every* row plus the filter row (`selectedCity`,
`selectedStatus`, `selectedPeriod` and the phone `query`); the visible subset and
the KPI tiles are getters on the state. Changing a filter therefore re-filters
in memory — no refetch, no loading flash, and the tiles always describe exactly
the rows on screen:

| Tile | Value |
|---|---|
| `إجمالي المبلغ` | sum of `amount` over the filtered rows |
| `عدد العوائد` | how many rows are filtered in |
| `العوائد المفعّلة` | how many of those are `active` |

Amounts are stored as numbers and formatted once (`formatAmount`), so a tile can
never drift from the table beneath it.

## Filters and search

The frame repeats the same dropdown three times. Each repetition is a real
filter here, labelled as such, and the four filters combine with **AND** — a row
must survive all of them to reach the table, the KPI tiles and the PDF.

| Pill | Options | Field |
|---|---|---|
| `المدينة` | `الكل` (default), the known cities, any city that only exists in the data, plus `غير محدد` for rows with a blank `cityId` | `cityId` |
| `الحالة` | `الكل` (default), `مفعل`, `قيد المراجعة`, `موقوف` | `status` |
| `الفترة` | `الكل` (default), `هذا الشهر`, `آخر ٣ أشهر`, `هذا العام` | `createdAt` |
| `بحث برقم الجوال` | free text | `phone` / `alternatePhone` |

- `هذا الشهر` is the current calendar month; `آخر ٣ أشهر` is this month plus the
  two before it; `هذا العام` is the current year. The windows are calendar
  based, not rolling days, so they still read correctly on the 1st of a month.
  A row with no `createdAt` can't be placed in a window, so it only shows under
  `الكل` (it is still listed — and sorted as newest — everywhere else).
- The period is evaluated whenever the list is read, so a screen left open past
  midnight keeps describing the right window.
- City options keep the selected value even when its last row disappears, so a
  pill never flips to a blank label.
- `بحث برقم الجوال` is a real field: it matches the primary and alternate phone
  numbers after normalising (digits only, `+966`/`00`/trunk `0` stripped,
  Arabic-Indic digits folded), so `0501234567`, `+966 50 123 4567` and
  `٥٠١٢٣٤٥٦٧` all find the same row.
- An unknown option label falls back to "no filter" instead of hiding every
  row, so stale state can never blank the screen.
- When the filters exclude everything, the table says
  `لا توجد نتائج مطابقة للفلاتر` and offers `مسح الفلاتر`, which resets all four
  at once (a truly empty collection still reads `لا توجد بيانات`).

## PDF export / print

`تنزيل PDF` and `طباعة` render the data **currently on screen** into a real A4
PDF, entirely client-side (`pdf` + `printing`) — no backend endpoint, so the
report can never disagree with the table.

- `FinancialReturnsPdfBuilder` (in `model/`) builds the document: header with
  build timestamp, one chip per filter (`المدينة`, `الحالة`, `الفترة`, plus
  `البحث` when it is in use), the KPI tiles, and a paginated table
  whose header row repeats on every page. Arabic shaping, RTL and the embedded
  font subset all come from the bundled IBM Plex Sans Arabic files.
- Status chips keep their on-screen colours (green / gold / red) in print.
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

- **Loading**: green spinner while the first frame arrives; filter changes keep
  the current data on screen to avoid a flash.
- **Failure**: message + `إعادة المحاولة` retry button (dashboard and admin).
- **Report generation**: `تعذّر إنشاء التقرير` when the PDF can't be built, and
  `تعذّر فتح التقرير على هذا الجهاز` when the platform can't hand off the file.
- **Sign-in**: wrong credentials, disabled account, rate limiting and network
  failures each get their own Arabic message; a signed-in non-admin is signed
  out with an explicit reason.
- **Firebase init failure**: falls back to the mock graph and logs why, instead
  of a black screen.

## Tests

```bash
flutter test
```

- `financial_returns_cubit_test.dart` — load, in-memory city / status / period
  filters (individually and combined), filters surviving a live frame, clear,
  cached first frame then live frame, failure state, plus PDF generation and its
  two `null` paths.
- `financial_returns_kpi_test.dart` — sums, active count, empty list, decimals.
- `returns_filters_test.dart` — phone normalisation (every spelling of the same
  number), `الكل`, cities that only exist in the data, the uncategorised bucket,
  the status options / label mapping, and the guarantee that the current
  selection stays in the option list.
- `returns_period_test.dart` — each period window (month, three months, year),
  the new-year rollover, rows with no date, and UTC timestamps read in local
  time.
- `financial_returns_pdf_test.dart` — the bytes are a terminated PDF with an
  embedded font, and the empty-state report still renders.
- `admin_returns_cubit_test.dart` — load, create/delete with success feedback,
  failure that must not fake a success, and a broken stream.
- `app_form_factor_test.dart` — the tier boundaries.
- `responsive_layout_test.dart` — the shell, filters, KPI panel and both tables
  at 390 / 1024 / 1440: drawer vs sidebar, stacked vs row, cards vs grid, no
  overflow exceptions.

## Deployment

The web build is hosted on Firebase Hosting at
**https://benaa.web.app** (project `benaa-dashboard`, site `benaa`). The
`hosting.site` key in `firebase.json` is what points deploys at that site;
`benaa.web.app` is also listed under Firebase Auth → Settings → Authorized
domains, without which the admin sign-in would fail with
`auth/unauthorized-domain`.

```bash
flutter build web --release
firebase deploy --only hosting            # live
firebase hosting:channel:deploy preview --expires 7d   # throwaway URL to review first
firebase hosting:rollback                 # back to the previous release
```

- `firebase.json` publishes `build/web` and sets the cache policy that keeps
  updates honest: `/`, `index.html`, `main.dart.js`, `flutter_bootstrap.js`,
  `flutter_service_worker.js` and `manifest.json` are `no-cache`, so a new
  deploy is picked up on the next load; `/assets/**` is cached for a week.
- The site is `noindex` (meta tag + `robots.txt`) — it is an internal dashboard,
  not a landing page.
- `flutter build web` never sets `USE_MOCK`, so the deployed app talks to the
  real Firestore; the dashboard needs no sign-in because `firestore.rules`
  allows public reads on `returns`, while writes require an `admins/{uid}` row.

## Known placeholders (from the Figma file)

| Where | What the file contains |
|---|---|
| Filter row | Three identical dropdowns — mapped to three real filters: `المدينة`, `الحالة`, `الفترة` |
| Table header | All five columns read `رقم الجوال` — replaced by the five real field names |
| Sidebar | `صلاحيات المستخدم` repeated 5× — collapsed to one |
| Logo | Mark is drawn as three gold bars; the Figma paths were not exported |
| Brand font | Cairo ExtraBold is a variable font, weight applied via `fontVariations` |

Two of those placeholders are resolved in code. The filter row no longer
repeats one dropdown: the file drew the same component three times with no
second or third field, so the row was mapped to city, status and period. And the
header row no longer repeats `رقم الجوال`: `kReturnsTableHeaders` names the five
fields it actually labels (`الحالة`, `المبلغ`, `المرجع`, `الجوال`,
`الجوال البديل`), shared with the PDF and worded exactly like the admin table.
The magic row (`____ ريال`, `#/#/#`, repeated phone) is now a real record in
`returns`; its demo copy lives in `kDemoFinancialReturns`.

## Notes on fidelity

- Icons from the file's third-party sets (famicons, solar, humbleicons,
  healthicons, iconmind, ant-design) are mapped to Material equivalents in
  `core/constants/app_icons.dart`; swap in `flutter_svg` assets when exported.
- Text direction follows the design: values inside the table that are
  Latin/numeric (phone numbers) and the sidebar clock are forced LTR so bidi
  doesn't reorder them.
- The sidebar in the frame is 826pt tall (the page is 1199); it is stretched to
  full height here, and its navigation list scrolls.
- The repository composes the cache frame and the live stream with
  `Stream.multi` rather than an `async*` generator: cancelling a generator
  parked in `await for` can leave the inner subscription (and the cancel
  future) pending, which would leak a Firestore listener on every dispose.
- Newest-first ordering is applied in Dart (`newestFirst`), not with
  `orderBy('createdAt')`: a row written with `serverTimestamp()` has a pending
  null timestamp in the local snapshot, and an ordered query would hide it until
  the write round-trips.
