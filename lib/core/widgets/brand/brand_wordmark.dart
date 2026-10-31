import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_text_styles.dart';
import 'brand_mark.dart';

/// Logo block: the gold mark followed by the "بناء" wordmark.
///
/// Sized by its content (mark + wordmark) rather than a fixed 95pt box: a hard
/// height clips Cairo's tall ascenders when `.h` and `.sp` scale differently.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BrandMark(),
        SizedBox(height: 8.h),
        Text('بناء', style: AppTextStyles.wordmark),
      ],
    );
  }
}
