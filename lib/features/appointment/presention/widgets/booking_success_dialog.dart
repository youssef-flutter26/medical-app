import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class BookingSuccessDialog extends StatelessWidget {
  const BookingSuccessDialog({
    super.key,
    required this.doctorName,
    required this.formattedDate,
    required this.formattedTime,
    required this.onDone,
  });

  final String doctorName;
  final String formattedDate;
  final String formattedTime;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 38.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 20.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70.w,
              height: 70.w,
              decoration: const BoxDecoration(
                color: Color(0xFFA5D8CE),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.darkTeal,
                    size: 28.r,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              LocaleKeys.congratulations.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.inter18W700.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTeal,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Your appointment with Dr. $doctorName is confirmed for $formattedDate at $formattedTime.',
              textAlign: TextAlign.center,
              style: AppTextStyles.inter12W400.copyWith(
                fontSize: 12.sp,
                height: 1.5,
                color: AppColors.gray500,
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                child: Text(
                  LocaleKeys.done.tr(),
                  style: AppTextStyles.inter14W500.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              LocaleKeys.editYourAppointment.tr(),
              style: AppTextStyles.inter12W400.copyWith(
                fontSize: 11.sp,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
