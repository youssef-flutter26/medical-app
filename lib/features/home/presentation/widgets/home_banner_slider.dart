import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/presentation/widgets/home_banner.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeBannerSlider extends StatefulWidget {
  final List<BannerEntity> banners;
  final bool isAdmin;
  final void Function(BannerEntity banner)? onEditBanner;

  const HomeBannerSlider({
    super.key,
    required this.banners,
    this.isAdmin = false,
    this.onEditBanner,
  });

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  late final PageController _pageController;

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

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const HomeBanner();
    }

    if (widget.banners.length == 1) {
      final banner = widget.banners.first;
      return HomeBanner(
        title: banner.title.isNotEmpty ? banner.title : null,
        subtitle: banner.description.isNotEmpty ? banner.description : null,
        imagePath: banner.imagePath.isNotEmpty ? banner.imagePath : null,
        bannerCount: 4,
        currentIndex: 0,
        showDots: true,
        isAdmin: widget.isAdmin,
        onEdit: widget.isAdmin && widget.onEditBanner != null
            ? () => widget.onEditBanner!(banner)
            : null,
      );
    }

    return SizedBox(
      height: 163.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: HomeBanner(
                  title: banner.title.isNotEmpty ? banner.title : null,
                  subtitle: banner.description.isNotEmpty
                      ? banner.description
                      : null,
                  imagePath:
                      banner.imagePath.isNotEmpty ? banner.imagePath : null,
                  showDots: false,
                  isAdmin: widget.isAdmin,
                  onEdit: widget.isAdmin && widget.onEditBanner != null
                      ? () => widget.onEditBanner!(banner)
                      : null,
                ),
              );
            },
          ),
          Positioned(
            bottom: 8.h,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: widget.banners.length,
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
        ],
      ),
    );
  }
}
