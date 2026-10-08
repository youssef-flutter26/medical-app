import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class ConfirmBookingButton extends StatelessWidget {
  const ConfirmBookingButton({
    super.key,
    required this.isBooking,
    required this.isTimeSelected,
    required this.isLoadingSlots,
    required this.onPressed,
  });

  final bool isBooking;
  final bool isTimeSelected;
  final bool isLoadingSlots;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool canPress = !isBooking && isTimeSelected && !isLoadingSlots;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0x10000000),
            blurRadius: 12.r,
            offset: Offset(0, -3.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: canPress ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkTeal,
              disabledBackgroundColor: AppColors.gray100,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26.r),
              ),
            ),
            child: isBooking
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    LocaleKeys.confirm.tr(),
                    style: AppTextStyles.inter16W500.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: canPress ? AppColors.white : AppColors.gray400,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
