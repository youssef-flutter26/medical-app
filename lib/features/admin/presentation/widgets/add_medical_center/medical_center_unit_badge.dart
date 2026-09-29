import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class MedicalCenterUnitBadge extends StatelessWidget {
  final String text;

  const MedicalCenterUnitBadge({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.gray400.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.withColor(
          AppTextStyles.inter12W500,
          AppColors.gray600,
        ),
      ),
    );
  }
}
