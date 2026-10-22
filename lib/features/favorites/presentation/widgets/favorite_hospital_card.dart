import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';

class FavoriteHospitalCard extends StatelessWidget {
  final MedicalCenterEntity center;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const FavoriteHospitalCard({
    super.key,
    required this.center,
    this.onTap,
    this.onFavoriteTap,
  });

  String get _displayDistance {
    final distance = center.formattedDistance;
    if (distance.isNotEmpty) {
      return '$distance/40min';
    }
    return '2.5 km/40min';
  }

  String get _displayType {
    if (center.type.isNotEmpty) {
      return center.type;
    }
    return 'Hospital';
  }

  Widget _buildImage() {
    final path = center.imagePath.trim();
    if (path.isNotEmpty) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return Image.network(
          path,
          width: double.infinity,
          height: 135.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
        );
      }
      return Image.asset(
        path,
        width: double.infinity,
        height: 135.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
      );
    }
    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    return Container(
      width: double.infinity,
      height: 135.h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardBgStart, AppColors.cardBgEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.local_hospital_rounded,
          size: 42.r,
          color: AppColors.lightTeal.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.gray100, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0x06000000),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                    child: _buildImage(),
                  ),
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: InkWell(
                      onTap: onFavoriteTap,
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 16.r,
                          color: AppColors.darkTeal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      center.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.inter14W500.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTeal,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.iconsLocation2,
                          width: 12.w,
                          height: 12.h,
                          colorFilter: const ColorFilter.mode(
                            AppColors.gray500,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            center.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.inter12W400.copyWith(
                              fontSize: 11.sp,
                              color: AppColors.gray500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          center.rating.toStringAsFixed(1),
                          style: AppTextStyles.inter12W500.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            final isFilled =
                                (index + 1) <= center.rating.round().clamp(0, 5);
                            return Icon(
                              Icons.star_rounded,
                              size: 13.r,
                              color: isFilled
                                  ? AppColors.amber
                                  : AppColors.gray400.withValues(alpha: 0.35),
                            );
                          }),
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            '(${center.reviewsCount} ${LocaleKeys.reviews.tr()})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.inter10W400.copyWith(
                              fontSize: 10.sp,
                              color: AppColors.gray500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Divider(
                      height: 1.h,
                      thickness: 1,
                      color: AppColors.gray100,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/routing.svg',
                                width: 13.w,
                                height: 13.h,
                              ),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  _displayDistance,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.inter10W400.copyWith(
                                    fontSize: 10.sp,
                                    color: AppColors.gray500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/hospital.svg',
                              width: 13.w,
                              height: 13.h,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _displayType,
                              style: AppTextStyles.inter10W400.copyWith(
                                fontSize: 10.sp,
                                color: AppColors.gray500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
