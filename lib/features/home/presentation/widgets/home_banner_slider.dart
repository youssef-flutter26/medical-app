import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/presentation/widgets/home_banner.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeBannerSlider extends StatefulWidget {
  final List<BannerEntity> banners;
  final bool isAdmin;
  final void Function(BannerEntity banner)? onEditBanner;
  final Duration autoPlayInterval;
  final bool autoPlay;

  const HomeBannerSlider({
    super.key,
    required this.banners,
    this.isAdmin = false,
    this.onEditBanner,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.autoPlay = true,
  });

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  late final PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant HomeBannerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length ||
        oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval) {
      _stopAutoPlay();
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    if (!widget.autoPlay || widget.banners.length <= 1) return;
    _stopAutoPlay();
    _timer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!_pageController.hasClients) return;
      final int currentPage = _pageController.page?.round() ?? 0;
      final int nextPage = (currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopAutoPlay();
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
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is UserScrollNotification) {
                if (notification.direction != ScrollDirection.idle) {
                  _stopAutoPlay();
                } else {
                  _startAutoPlay();
                }
              }
              return false;
            },
            child: PageView.builder(
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
