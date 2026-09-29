import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/theme/app_colors.dart';

class MedicalCenterRatingStars extends StatelessWidget {
  final double rating;
  final ValueChanged<double>? onRatingChanged;

  const MedicalCenterRatingStars({
    super.key,
    required this.rating,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = rating >= starIndex;

        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged!(starIndex.toDouble())
              : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Icon(
              Icons.star_rounded,
              size: 22.r,
              color: isSelected
                  ? AppColors.amber
                  : AppColors.gray400.withValues(alpha: 0.35),
            ),
          ),
        );
      }),
    );
  }
}
