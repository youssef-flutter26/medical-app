import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({
    super.key,
    this.title,
    this.subtitle,
    this.buttonText,
    this.imagePath,
    this.onButtonPressed,
    this.pageController,
    this.bannerCount = 4,
    this.currentIndex = 0,
    this.showDots = true,
    this.isAdmin = false,
    this.onEdit,
  });

  final String? title;
  final String? subtitle;
  final String? buttonText;
  final String? imagePath;
  final VoidCallback? onButtonPressed;
  final PageController? pageController;
  final int bannerCount;
  final int currentIndex;
  final bool showDots;
  final bool isAdmin;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? LocaleKeys.lookingForSpecialistDoctors.tr();
    final effectiveSubtitle = subtitle ?? LocaleKeys.bannerSubtext.tr();
    final hasBackgroundImage = imagePath != null && imagePath!.isNotEmpty;

    return Container(
      width: double.infinity,
      height: 163.h,
      decoration: BoxDecoration(
        color: hasBackgroundImage ? AppColors.bannerBgStart : null,
        borderRadius: BorderRadius.circular(16.r),
        gradient: hasBackgroundImage
            ? null
            : const LinearGradient(
                colors: [
                  AppColors.bannerBgStart,
                  AppColors.bannerBgEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        image: hasBackgroundImage
            ? DecorationImage(
                image: AssetImage(imagePath!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // 1. _1 blur/background layer (top-left)
            Positioned(
              top: 0,
              left: 0,
              child: SvgPicture.asset(
                'assets/icons/Background_1.svg',
                width: 114.w,
                height: 99.h,
                fit: BoxFit.contain,
              ),
            ),

            // 2. _2 blur/background layer (bottom-left)
            Positioned(
              bottom: 0,
              left: 70.w,
              child: SvgPicture.asset(
                'assets/icons/Background_2.svg',
                width: 83.w,
                height: 12.h,
                fit: BoxFit.contain,
              ),
            ),

            // 3. Fallback decorative circles when no background image
            if (!hasBackgroundImage) ...[
              Positioned(
                right: -10.w,
                bottom: -20.h,
                child: Container(
                  width: 120.r,
                  height: 120.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.35),
                  ),
                ),
              ),
              Positioned(
                right: 40.w,
                top: -10.h,
                child: Container(
                  width: 60.r,
                  height: 60.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ],

            // 4. Content (Title + Description + Optional Action Button)
            Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                top: 12.h,
                right: 16.w,
                bottom: 22.h,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            effectiveTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: AppTextStyles.withColor(
                              AppTextStyles.inter18W700.copyWith(
                                fontSize: 18.sp,
                                height: 1.2,
                              ),
                              AppColors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            effectiveSubtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: AppTextStyles.withColor(
                              AppTextStyles.inter12W400.copyWith(
                                fontSize: 12.sp,
                                height: 1.25,
                              ),
                              AppColors.white,
                            ),
                          ),
                        if (onButtonPressed != null) ...[
                          SizedBox(height: 10.h),
                          ElevatedButton(
                            onPressed: onButtonPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkTeal,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 6.h,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                            child: Text(
                              buttonText ?? LocaleKeys.explore.tr(),
                              style: AppTextStyles.withColor(
                                AppTextStyles.inter10W500.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                  if (!hasBackgroundImage)
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: _buildDefaultIcon(),
                      ),
                    )
                  else
                    const Spacer(flex: 5),
                ],
              ),
            ),

            // 5. Banner Dots Indicator
            if (showDots && bannerCount > 1)
              Positioned(
                bottom: 8.h,
                left: 0,
                right: 0,
                child: Center(
                  child: pageController != null
                      ? SmoothPageIndicator(
                          controller: pageController!,
                          count: bannerCount,
                          effect: ExpandingDotsEffect(
                            dotWidth: 6.r,
                            dotHeight: 6.r,
                            expansionFactor: 4,
                            spacing: 5.w,
                            activeDotColor: AppColors.white,
                            dotColor: AppColors.white.withValues(alpha: 0.5),
                            radius: 4.r,
                          ),
                        )
                      : AnimatedSmoothIndicator(
                          activeIndex: currentIndex,
                          count: bannerCount,
                          effect: ExpandingDotsEffect(
                            dotWidth: 6.r,
                            dotHeight: 6.r,
                            expansionFactor: 4,
                            spacing: 5.w,
                            activeDotColor: AppColors.white,
                            dotColor: AppColors.white.withValues(alpha: 0.5),
                            radius: 4.r,
                          ),
                        ),
                ),
              ),

            // 6. Admin Edit Button
            if (isAdmin && onEdit != null)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const Key('banner_edit_button'),
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: AppColors.darkTeal.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: AppColors.white,
                        size: 16.r,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: 72.r,
      height: 72.r,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.85),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkTeal.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.medical_services_rounded,
        size: 38.r,
        color: AppColors.lightTeal,
      ),
    );
  }
}
