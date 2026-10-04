import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';

void showMedicalCenterDetailsSheet(
  BuildContext context,
  MedicalCenterEntity center, {
  bool isAdmin = false,
  VoidCallback? onEdit,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    backgroundColor: AppColors.white,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.gray400.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  center.name,
                  style: AppTextStyles.inter16W500.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTeal,
                    fontSize: 18.sp,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.lightTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  center.type,
                  style: AppTextStyles.inter12W500.copyWith(
                    color: AppColors.lightTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16.r,
                color: AppColors.gray500,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  center.address,
                  style: AppTextStyles.inter14W400.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                size: 18.r,
                color: AppColors.amber,
              ),
              SizedBox(width: 4.w),
              Text(
                center.rating.toStringAsFixed(1),
                style: AppTextStyles.inter14W500.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTeal,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '(${center.reviewsCount} ${LocaleKeys.reviews.tr()})',
                style: AppTextStyles.inter12W400.copyWith(
                  color: AppColors.gray500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.directions_walk_rounded,
                size: 16.r,
                color: AppColors.gray500,
              ),
              SizedBox(width: 4.w),
              Text(
                center.formattedDistance,
                style: AppTextStyles.inter12W500.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
          if (isAdmin && onEdit != null) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  onEdit();
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Medical Center'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
