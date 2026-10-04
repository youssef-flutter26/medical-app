import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';

class MedicalCenterItem extends StatelessWidget {
  const MedicalCenterItem({
    super.key,
    required this.name,
    this.category = '',
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    this.duration,
    this.type,
    this.imagePath,
    this.imageUrl,
    this.isFavorite = false,
    this.isAdmin = false,
    this.isFullWidth = false,
    this.onTap,
    this.onFavoriteTap,
    this.onEdit,
  });

  final String name;
  final String category;
  final String address;
  final double rating;
  final int reviewCount;
  final String distance;
  final String? duration;
  final String? type;
  final String? imagePath;
  final String? imageUrl;
  final bool isFavorite;
  final bool isAdmin;
  final bool isFullWidth;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onEdit;

  String get displayDistance {
    if (duration != null && duration!.isNotEmpty && !distance.contains('/')) {
      return '$distance / $duration';
    }
    return distance;
  }

  String get displayType {
    if (type != null && type!.isNotEmpty) {
      return type!;
    }
    if (category.toLowerCase().contains('hospital')) {
      return 'Hospital';
    }
    return 'Clinic';
  }

  Widget _buildImage() {
    DecorationImage? decorationImage;
    if (imagePath != null && imagePath!.isNotEmpty) {
      decorationImage = DecorationImage(
        image: AssetImage(imagePath!),
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      decorationImage = DecorationImage(
        image: NetworkImage(imageUrl!),
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: isFullWidth ? double.infinity : 232.w,
      height: 121.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
        gradient: decorationImage == null
            ? const LinearGradient(
                colors: [
                  AppColors.cardBgStart,
                  AppColors.cardBgEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        image: decorationImage,
      ),
      child: decorationImage == null
          ? Center(
              child: Icon(
                Icons.local_hospital_rounded,
                size: 38.r,
                color: AppColors.lightTeal.withValues(alpha: 0.6),
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : 232.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.gray100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkTeal.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image with heart icon
                Stack(
                  children: [
                    _buildImage(),
                    if (isAdmin && onEdit != null)
                      Positioned(
                        top: 8.h,
                        left: 8.w,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: const Key('medical_center_edit_button'),
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
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: InkWell(
                        onTap: onFavoriteTap,
                        borderRadius: BorderRadius.circular(16.r),
                        child: Container(
                          padding: EdgeInsets.all(5.r),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 16.r,
                            color: isFavorite ? AppColors.red : AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Card content
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.inter14W500.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTeal,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Address
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
                              address,
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
                      SizedBox(height: 4.h),
                      // Rating & Reviews
                      Row(
                        children: [
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTextStyles.inter12W500.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkTeal,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              5,
                              (index) {
                                final isFilled = (index + 1) <= rating.round().clamp(0, 5);
                                return Icon(
                                  Icons.star_rounded,
                                  size: 12.r,
                                  color: isFilled
                                      ? AppColors.amber
                                      : AppColors.gray400.withValues(alpha: 0.35),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Flexible(
                            child: Text(
                              '($reviewCount Reviews)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.inter12W400.copyWith(
                                fontSize: 10.sp,
                                color: AppColors.gray500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      // Divider
                      Divider(
                        height: 1.h,
                        thickness: 1,
                        color: AppColors.gray100,
                      ),
                      SizedBox(height: 6.h),
                      // Footer: Routing & Hospital type
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
                                    displayDistance,
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
                          SizedBox(width: 6.w),
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
                                displayType,
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
      ),
    );
  }
}
