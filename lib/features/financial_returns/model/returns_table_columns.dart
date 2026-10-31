/// Column headers of the financial-returns table, in visual order
/// (right → left in the app, left → right in the printed report).
///
/// The Figma file repeats "رقم الجوال" in all five cells; that placeholder is
/// replaced here by the field each column actually shows. The wording matches
/// the admin table and the compact cards, so the same column never carries two
/// names. Shared by the on-screen table and the PDF so the two can't drift.
const List<String> kReturnsTableHeaders = <String>[
  'الحالة',
  'المبلغ',
  'المرجع',
  'الجوال',
  'الجوال البديل',
];
