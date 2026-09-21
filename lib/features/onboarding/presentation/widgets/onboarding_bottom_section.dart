import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/widgets/app_button.dart';
import 'package:medical_app/features/onboarding/presentation/widgets/onboarding_page_indicator.dart';
import 'package:medical_app/features/onboarding/presentation/widgets/onboarding_skip_button.dart';

class OnboardingBottomSection extends StatelessWidget {
  const OnboardingBottomSection({
    super.key,
    required this.pageCount,
    required this.currentIndex,
    required this.onNextPressed,
    required this.onSkipPressed,
  });

  final int pageCount;
  final int currentIndex;
  final VoidCallback onNextPressed;
  final VoidCallback onSkipPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              key: const Key('onboarding_next_button'),
              text: LocaleKeys.onboardingNext.tr(),
              onPressed: onNextPressed,
            ),
            SizedBox(height: 28.h),
            OnboardingPageIndicator(
              count: pageCount,
              currentIndex: currentIndex,
            ),
            SizedBox(height: 24.h),
            OnboardingSkipButton(
              onPressed: onSkipPressed,
            ),
            SizedBox(height: 56.h),
          ],
        ),
      ),
    );
  }
}
