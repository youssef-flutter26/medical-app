import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';

class FavoriteDoctorCard extends StatelessWidget {
  final DoctorEntity doctor;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final int index;

  const FavoriteDoctorCard({
    super.key,
    required this.doctor,
    this.onTap,
    this.onFavoriteTap,
    this.index = 0,
  });

  static const List<Color> _avatarPastelBgs = [
    Color(0xFFFDE8E8), // soft pink/coral
    Color(0xFFFDF0E6), // soft peach/orange
    Color(0xFFE6F7F5), // soft teal/sage
    Color(0xFFFEF9C3), // soft beige/yellow
    Color(0xFFE8F5E9), // soft mint/green
  ];

  Color get _backgroundColor {
    return _avatarPastelBgs[index % _avatarPastelBgs.length];
  }

  String get _formattedRating {
    if (doctor.rating % 1 == 0) {
      return doctor.rating.toInt().toString();
    }
    final fixed = doctor.rating.toStringAsFixed(2);
    if (fixed.endsWith('0')) {
      return doctor.rating.toStringAsFixed(1);
    }
    return fixed;
  }

  String get _formattedReviews {
    final count = doctor.reviewsCount;
    if (count >= 1000) {
      final thousands = count ~/ 1000;
      final remainder = (count % 1000).toString().padLeft(3, '0');
      return '$thousands,$remainder';
    }
    return count.toString();
  }

  String get _displayLocation {
    if (doctor.address.isNotEmpty) {
      return doctor.address;
    }
    if (doctor.categoryName.isNotEmpty) {
      return '${doctor.categoryName} Center';
    }
    return 'Clinic Center';
  }

  Widget _buildAvatar() {
    final imagePath = doctor.imagePath.trim();
    if (imagePath.isNotEmpty) {
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return Image.network(
          imagePath,
          width: 90.w,
          height: 90.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildAvatarPlaceholder(),
        );
      }
      return Image.asset(
        imagePath,
        width: 90.w,
        height: 90.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildAvatarPlaceholder(),
      );
    }
    return _buildAvatarPlaceholder();
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 90.w,
      height: 90.h,
      color: _backgroundColor,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 46.r,
          color: AppColors.darkTeal.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: _buildAvatar(),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              doctor.name,
                              style: AppTextStyles.inter16W500.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkTeal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          InkWell(
                            onTap: onFavoriteTap,
                            borderRadius: BorderRadius.circular(12.r),
                            child: Padding(
                              padding: EdgeInsets.all(4.r),
                              child: Icon(
                                Icons.favorite_rounded,
                                size: 20.r,
                                color: AppColors.darkTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        doctor.specialty,
                        style: AppTextStyles.inter12W500.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppAssets.iconsLocation2,
                            width: 12.w,
                            height: 12.h,
                            colorFilter: const ColorFilter.mode(
                              AppColors.gray400,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              _displayLocation,
                              style: AppTextStyles.inter12W400.copyWith(
                                fontSize: 12.sp,
                                color: AppColors.gray500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16.r,
                            color: const Color(0xFFFBBF24),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _formattedRating,
                            style: AppTextStyles.inter12W500.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkTeal,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '|',
                            style: TextStyle(
                              color: AppColors.gray400,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              '$_formattedReviews ${LocaleKeys.reviews.tr()}',
                              style: AppTextStyles.inter12W400.copyWith(
                                fontSize: 12.sp,
                                color: AppColors.gray500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
