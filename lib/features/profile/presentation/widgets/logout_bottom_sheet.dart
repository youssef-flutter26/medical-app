import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/common/widgets/app_button.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class LogoutBottomSheet extends StatefulWidget {
  final Future<void> Function() onConfirmLogout;

  const LogoutBottomSheet({
    super.key,
    required this.onConfirmLogout,
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onConfirmLogout,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogoutBottomSheet(onConfirmLogout: onConfirmLogout),
    );
  }

  @override
  State<LogoutBottomSheet> createState() => _LogoutBottomSheetState();
}

class _LogoutBottomSheetState extends State<LogoutBottomSheet> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onConfirmLogout();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24.w,
        22.h,
        24.w,
        24.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LocaleKeys.logout.tr(),
            style: AppTextStyles.inter18W700.copyWith(
              fontSize: 18.sp,
              color: AppColors.darkTeal,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.gray100,
          ),
          SizedBox(height: 24.h),
          Text(
            LocaleKeys.logOutConfirmation.tr(),
            style: AppTextStyles.inter14W500.copyWith(
              fontSize: 14.sp,
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: LocaleKeys.cancel.tr(),
                  backgroundColor: AppColors.gray100,
                  textColor: AppColors.gray700,
                  height: 48.h,
                  borderRadius: 24.r,
                  textStyle: AppTextStyles.inter14W500.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: AppButton(
                  text: LocaleKeys.yesLogout.tr(),
                  backgroundColor: AppColors.darkTeal,
                  textColor: AppColors.white,
                  height: 48.h,
                  borderRadius: 24.r,
                  isLoading: _isLoading,
                  textStyle: AppTextStyles.inter14W500.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: _isLoading ? null : _handleConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
