import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/brand/brand_wordmark.dart';
import '../view_model/auth_cubit.dart';
import '../view_model/auth_state.dart';

/// Admin sign-in form. Stays mounted while Firebase verifies the credentials,
/// so a failed attempt keeps the typed email.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().signIn(
      email: _email.text,
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthState state = context.watch<AuthCubit>().state;
    final bool busy = state is AuthSigningIn;
    final String? error = state is AuthSignedOut ? state.message : null;

    return Scaffold(
      backgroundColor: AppColors.pureBlack,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 460.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandWordmark(),
                SizedBox(height: 18.h),
                Text('إدارة العوائد المالية', style: AppTextStyles.header3),
                SizedBox(height: 6.h),
                Text(
                  'سجّل الدخول بحساب مشرف للوصول إلى لوحة الإدارة',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body14Muted,
                ),
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('تسجيل الدخول', style: AppTextStyles.body18Bold),
                        SizedBox(height: 16.h),
                        _FieldLabel('البريد الإلكتروني'),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const <String>[
                            AutofillHints.username,
                          ],
                          textDirection: TextDirection.ltr,
                          style: AppTextStyles.body16,
                          decoration: const InputDecoration(
                            hintText: 'admin@benaa.com',
                          ),
                          validator: (String? value) {
                            final String email = (value ?? '').trim();
                            if (email.isEmpty) return 'أدخل البريد الإلكتروني';
                            if (!email.contains('@')) {
                              return 'أدخل بريدًا إلكترونيًا صحيحًا';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 14.h),
                        _FieldLabel('كلمة المرور'),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          autofillHints: const <String>[AutofillHints.password],
                          style: AppTextStyles.body16,
                          decoration: const InputDecoration(
                            hintText: '••••••••',
                          ),
                          onFieldSubmitted: (_) => _submit(),
                          validator: (String? value) =>
                              (value ?? '').isEmpty
                              ? 'أدخل كلمة المرور'
                              : null,
                        ),
                        if (error != null) ...<Widget>[
                          SizedBox(height: 14.h),
                          Text(
                            error,
                            style: AppTextStyles.body14.copyWith(
                              color: AppColors.red,
                            ),
                          ),
                        ],
                        SizedBox(height: 20.h),
                        SizedBox(
                          height: 48.h,
                          child: FilledButton(
                            onPressed: busy ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.pureBlack,
                              disabledBackgroundColor: AppColors.surfaceField,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: busy
                                ? SizedBox(
                                    width: 20.r,
                                    height: 20.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'دخول',
                                    style: AppTextStyles.body16.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.pureBlack,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                  ),
                  child: Text(
                    'العودة إلى لوحة التحكم',
                    style: AppTextStyles.body14Muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(text, style: AppTextStyles.body14Muted),
    );
  }
}
