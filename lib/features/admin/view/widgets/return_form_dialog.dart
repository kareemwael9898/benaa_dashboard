import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../financial_returns/model/financial_return.dart';
import '../../../financial_returns/model/financial_return_status.dart';
import '../../../financial_returns/model/return_filter_field.dart';

/// Create / edit form for one return.
///
/// Pops with the assembled [FinancialReturn] (`id` preserved when editing, empty
/// when creating — Firestore assigns the document id).
class ReturnFormDialog extends StatefulWidget {
  const ReturnFormDialog({super.key, this.existing});

  final FinancialReturn? existing;

  @override
  State<ReturnFormDialog> createState() => _ReturnFormDialogState();
}

class _ReturnFormDialogState extends State<ReturnFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _amount;
  late final TextEditingController _reference;
  late final TextEditingController _phone;
  late final TextEditingController _alternatePhone;

  late String _city;
  late FinancialReturnStatus _status;

  /// The city list the dashboard filters on — one source of truth, so an admin
  /// can never create a row the filter can't reach.
  static List<String> get _cities =>
      kReturnFilterFields.last.options;

  @override
  void initState() {
    super.initState();
    final FinancialReturn? existing = widget.existing;

    _amount = TextEditingController(
      text: existing == null ? '' : _plainAmount(existing.amount),
    );
    _reference = TextEditingController(text: existing?.reference ?? '');
    _phone = TextEditingController(text: existing?.phone ?? '');
    _alternatePhone = TextEditingController(text: existing?.alternatePhone ?? '');

    _city = existing?.cityId ?? _cities.first;
    if (!_cities.contains(_city)) _city = _cities.first;
    _status = existing?.status ?? FinancialReturnStatus.active;
  }

  /// `10000.0` → `10000`, `1500.5` → `1500.5`.
  static String _plainAmount(num value) {
    final double asDouble = value.toDouble();
    return asDouble == asDouble.roundToDouble()
        ? asDouble.toStringAsFixed(0)
        : asDouble.toString();
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _phone.dispose();
    _alternatePhone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final String phone = _phone.text.trim();
    final String alternate = _alternatePhone.text.trim();

    Navigator.of(context).pop(
      FinancialReturn(
        id: widget.existing?.id ?? '',
        cityId: _city,
        status: _status,
        amount: num.parse(_amount.text.trim()),
        reference: _reference.text.trim(),
        phone: phone,
        alternatePhone: alternate.isEmpty ? phone : alternate,
        createdAt: widget.existing?.createdAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existing != null;

    return Dialog(
      insetPadding: EdgeInsets.all(24.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560.w),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    isEditing ? 'تعديل صف' : 'إضافة صف',
                    style: AppTextStyles.body18Bold,
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: _Labeled(
                          label: 'المدينة',
                          child: DropdownButtonFormField<String>(
                            initialValue: _city,
                            dropdownColor: AppColors.surfaceField,
                            style: AppTextStyles.body16,
                            iconEnabledColor: AppColors.gold,
                            items: <DropdownMenuItem<String>>[
                              for (final String city in _cities)
                                DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(city),
                                ),
                            ],
                            onChanged: (String? value) {
                              if (value != null) _city = value;
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _Labeled(
                          label: 'الحالة',
                          child: DropdownButtonFormField<FinancialReturnStatus>(
                            initialValue: _status,
                            dropdownColor: AppColors.surfaceField,
                            style: AppTextStyles.body16,
                            iconEnabledColor: AppColors.gold,
                            items: <DropdownMenuItem<FinancialReturnStatus>>[
                              for (final FinancialReturnStatus status
                                  in FinancialReturnStatus.values)
                                DropdownMenuItem<FinancialReturnStatus>(
                                  value: status,
                                  child: Text(status.label),
                                ),
                            ],
                            onChanged: (FinancialReturnStatus? value) {
                              if (value != null) _status = value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  _Labeled(
                    label: 'المبلغ (ريال)',
                    child: TextFormField(
                      controller: _amount,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textDirection: TextDirection.ltr,
                      style: AppTextStyles.body16,
                      decoration: const InputDecoration(hintText: '10000'),
                      validator: (String? value) {
                        final String raw = (value ?? '').trim();
                        if (raw.isEmpty) return 'أدخل المبلغ';
                        final num? parsed = num.tryParse(raw);
                        if (parsed == null) return 'أدخل رقمًا صحيحًا';
                        if (parsed < 0) return 'لا يمكن أن يكون المبلغ سالبًا';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _Labeled(
                    label: 'المرجع',
                    child: TextFormField(
                      controller: _reference,
                      style: AppTextStyles.body16,
                      decoration: const InputDecoration(hintText: 'RET-1001'),
                      validator: (String? value) =>
                          (value ?? '').trim().isEmpty
                          ? 'أدخل رقم المرجع'
                          : null,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: _Labeled(
                          label: 'الجوال',
                          child: TextFormField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            style: AppTextStyles.body16,
                            decoration: const InputDecoration(
                              hintText: '05xxxxxxxx',
                            ),
                            validator: (String? value) =>
                                (value ?? '').trim().length < 6
                                ? 'أدخل رقم جوال صحيحًا'
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _Labeled(
                          label: 'الجوال البديل (اختياري)',
                          child: TextFormField(
                            controller: _alternatePhone,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            style: AppTextStyles.body16,
                            decoration: const InputDecoration(
                              hintText: '05xxxxxxxx',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 22.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textMuted,
                        ),
                        child: Text('إلغاء', style: AppTextStyles.body16),
                      ),
                      SizedBox(width: 8.w),
                      FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.pureBlack,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 14.h,
                          ),
                        ),
                        child: Text(
                          isEditing ? 'حفظ التعديلات' : 'إضافة',
                          style: AppTextStyles.body16.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.pureBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(label, style: AppTextStyles.body14Muted),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }
}
