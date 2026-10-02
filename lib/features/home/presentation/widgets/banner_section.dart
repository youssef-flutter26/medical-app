import 'package:flutter/material.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/presentation/widgets/home_banner.dart';
import 'package:medical_app/features/home/presentation/widgets/home_banner_slider.dart';

class BannerSection extends StatelessWidget {
  final List<BannerEntity>? banners;
  final bool isAdmin;
  final ValueChanged<BannerEntity>? onEditBanner;

  const BannerSection({
    super.key,
    this.banners,
    this.isAdmin = false,
    this.onEditBanner,
  });

  @override
  Widget build(BuildContext context) {
    final bannerList = banners;
    if (bannerList == null || bannerList.isEmpty) {
      return const HomeBanner();
    }

    return HomeBannerSlider(
      banners: bannerList,
      isAdmin: isAdmin,
      onEditBanner: onEditBanner,
    );
  }
}
