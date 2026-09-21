import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.onFinish,
  });

  final VoidCallback? onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<_OnboardingPageItem> _getPages() {
    return [
      _OnboardingPageItem(
        image: AppAssets.imagesOnboarding1,
        title: LocaleKeys.onboardingMeetDoctorsTitle.tr(),
        description: LocaleKeys.onboardingMeetDoctorsDescription.tr(),
      ),
      _OnboardingPageItem(
        image: AppAssets.imagesOnboarding2,
        title: LocaleKeys.onboardingConnectSpecialistsTitle.tr(),
        description: LocaleKeys.onboardingMeetDoctorsDescription.tr(),
      ),
      _OnboardingPageItem(
        image: AppAssets.imagesOnboarding3,
        title: LocaleKeys.onboardingSpecialistsTitle.tr(),
        description: LocaleKeys.onboardingSpecialistsDescription.tr(),
      ),
    ];
  }

  void _onNextPressed(int pageCount) {
    if (_currentIndex < pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinish();
    }
  }

  void _onSkipPressed() {
    _onFinish();
  }

  void _onFinish() {
    widget.onFinish?.call();
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: isActive ? AppColors.darkTeal : AppColors.gray500,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final page = pages[index];
                return Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: Image.asset(
                          page.image,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                    // Space between image and title: 28
                    SizedBox(height: 28.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Text(
                        page.title,
                        textAlign: TextAlign.center,
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        style: AppTextStyles.withColor(
                          AppTextStyles.inter20W600,
                          AppColors.darkTeal,
                        ),
                      ),
                    ),
                    // Space between title and description: 8
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 44.w),
                      child: Text(
                        page.description,
                        textAlign: TextAlign.center,
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        style: AppTextStyles.withColor(
                          AppTextStyles.inter14W400,
                          AppColors.gray500,
                        ).copyWith(
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Space between description and button: adjusted to 16 to visually match Figma reference
          SizedBox(height: 16.h),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 36.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    key: const Key('onboarding_next_button'),
                    text: LocaleKeys.onboardingNext.tr(),
                    onPressed: () => _onNextPressed(pages.length),
                  ),
                  // Space between button(s) and page dots: 28
                  SizedBox(height: 28.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => _buildIndicator(index == _currentIndex),
                    ),
                  ),
                  // Space between page dots and Skip text: 24
                  SizedBox(height: 24.h),
                  TextButton(
                    key: const Key('onboarding_skip_button'),
                    onPressed: _onSkipPressed,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      LocaleKeys.onboardingSkip.tr(),
                      style: AppTextStyles.withColor(
                        AppTextStyles.inter14W500,
                        AppColors.gray500,
                      ),
                    ),
                  ),
                  // Bottom spacing: 24
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageItem {
  final String image;
  final String title;
  final String description;

  const _OnboardingPageItem({
    required this.image,
    required this.title,
    required this.description,
  });
}
