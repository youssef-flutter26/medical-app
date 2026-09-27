import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class HaveAnAccountWidget extends StatelessWidget {
  const HaveAnAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LocaleKeys.alreadyHaveAnAccount.tr(),
          style: AppTextStyles.withColor(
            AppTextStyles.inter10W400,
            AppColors.gray500,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.login);
          },
          child: Text(
            LocaleKeys.signIn.tr(),
            style: AppTextStyles.withColor(
              AppTextStyles.inter10W500,
              AppColors.primary600,
            ),
          ),
        ),
      ],
    );
  }
}
