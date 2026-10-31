import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';

/// The small gold mark that sits above the "بناء" wordmark.
///
/// PLACEHOLDER: the Figma export only describes the mark as three overlapping
/// vector strokes inside a 46.5 × 24.6 box — it does not include the paths.
/// This draws three ascending bars of that size; drop the exported SVG in here
/// (or swap for `SvgPicture`) once the asset is available.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46.5.w,
      height: 24.6.h,
      child: const CustomPaint(painter: _BrandMarkPainter()),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = AppColors.gold;

    void bar(double leftFactor, double topFactor) {
      final Rect rect = Rect.fromLTWH(
        size.width * leftFactor,
        size.height * topFactor,
        size.width * 0.22,
        size.height * (1 - topFactor),
      );
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(1.5)), paint);
    }

    bar(0.02, 0.42);
    bar(0.39, 0.20);
    bar(0.76, 0.0);
  }

  @override
  bool shouldRepaint(covariant _BrandMarkPainter oldDelegate) => false;
}
