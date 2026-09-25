import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/onboarding/data/models/onboarding_page_model.dart';
import 'package:medical_app/features/onboarding/presentation/widgets/onboarding_bottom_section.dart';
import 'package:medical_app/features/onboarding/presentation/widgets/onboarding_image.dart';
import 'package:medical_app/features/onboarding/presentation/widgets/onboarding_text_content.dart';

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

  List<OnboardingPageModel> _getPages() {
    return [
      OnboardingPageModel(
        image: AppAssets.imagesOnboarding1,
        title: LocaleKeys.onboardingMeetDoctorsTitle.tr(),
        description:
        LocaleKeys.onboardingMeetDoctorsDescription.tr(),
      ),
      OnboardingPageModel(
        image: AppAssets.imagesOnboarding2,
        title: LocaleKeys.onboardingConnectSpecialistsTitle.tr(),
        description:
        LocaleKeys.onboardingMeetDoctorsDescription.tr(),
      ),
      OnboardingPageModel(
        image: AppAssets.imagesOnboarding3,
        title: LocaleKeys.onboardingSpecialistsTitle.tr(),
        description:
        LocaleKeys.onboardingSpecialistsDescription.tr(),
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
    if (widget.onFinish != null) {
      widget.onFinish!.call();
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      Routes.login,
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
                    OnboardingImage(
                      image: page.image,
                    ),
                    SizedBox(height: 28.h),
                    OnboardingTextContent(
                      title: page.title,
                      description: page.description,
                    ),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: 16.h),

          OnboardingBottomSection(
            pageCount: pages.length,
            currentIndex: _currentIndex,
            onNextPressed: () {
              _onNextPressed(pages.length);
            },
            onSkipPressed: _onSkipPressed,
          ),
        ],
      ),
    );
  }
}