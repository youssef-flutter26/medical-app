import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class OrWidget extends StatelessWidget {
  const OrWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.gray400.withOpacity(0.35))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Text(
            LocaleKeys.or,
            style: AppTextStyles.withColor(
              AppTextStyles.inter10W400,
              AppColors.gray500,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.gray400.withOpacity(0.35))),
      ],
    );
  }
}
