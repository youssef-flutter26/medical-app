import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class BannerHeaderSection extends StatelessWidget {
  const BannerHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bannerDetails.tr(),
          style: AppTextStyles.withColor(
            AppTextStyles.inter20W600,
            AppColors.darkTeal,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          LocaleKeys.addBannerInformation.tr(),
          style: AppTextStyles.withColor(
            AppTextStyles.inter14W400,
            AppColors.gray500,
          ),
        ),
      ],
    );
  }
}
