import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class CancelBookingDialog extends StatelessWidget {
  const CancelBookingDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const CancelBookingDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Text(
        LocaleKeys.cancel.tr(),
        style: AppTextStyles.inter16W500.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.darkTeal,
        ),
      ),
      content: Text(
        LocaleKeys.cancelBookingConfirmation.tr(),
        style: AppTextStyles.inter14W400.copyWith(
          color: AppColors.gray600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            LocaleKeys.cancel.tr(),
            style: AppTextStyles.inter14W500.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          child: Text(
            LocaleKeys.ok.tr(),
            style: AppTextStyles.inter14W500.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
