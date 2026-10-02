import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class DoctorData {
  final String? id;
  final String name;
  final String specialty;
  final String? category;
  final String location;
  final double rating;
  final int reviewCount;
  final String? imagePath;
  final bool isFavorite;
  final Color? backgroundColor;

  const DoctorData({
    this.id,
    required this.name,
    required this.specialty,
    this.category,
    required this.location,
    required this.rating,
    required this.reviewCount,
    this.imagePath,
    this.isFavorite = false,
    this.backgroundColor,
  });

  DoctorData copyWith({
    String? id,
    String? name,
    String? specialty,
    String? category,
    String? location,
    double? rating,
    int? reviewCount,
    String? imagePath,
    bool? isFavorite,
    Color? backgroundColor,
  }) {
    return DoctorData(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      category: category ?? this.category,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}

class DoctorCard extends StatelessWidget {
  final DoctorData doctor;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    this.onTap,
    this.onFavoriteTap,
  });

  String get _formattedRating {
    if (doctor.rating % 1 == 0) {
      return doctor.rating.toInt().toString();
    }
    return doctor.rating.toString();
  }

  String get _formattedReviews {
    final count = doctor.reviewCount;
    if (count >= 1000) {
      final thousands = count ~/ 1000;
      final remainder = (count % 1000).toString().padLeft(3, '0');
      return '$thousands,$remainder';
    }
    return count.toString();
  }

  Widget _buildImage() {
    final path = doctor.imagePath?.trim() ?? '';
    final bgColor = doctor.backgroundColor ?? const Color(0xFFFDE8E8);

    if (path.isNotEmpty) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return Image.network(
          path,
          width: 92.w,
          height: 92.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildAvatarPlaceholder(bgColor),
        );
      }
      return Image.asset(
        path,
        width: 92.w,
        height: 92.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildAvatarPlaceholder(bgColor),
      );
    }
    return _buildAvatarPlaceholder(bgColor);
  }

  Widget _buildAvatarPlaceholder(Color bgColor) {
    return Container(
      width: 92.w,
      height: 92.h,
      color: bgColor,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 48.r,
          color: AppColors.darkTeal.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.r),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: _buildImage(),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      InkWell(
                        onTap: onFavoriteTap,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: Icon(
                            doctor.isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 20.r,
                            color: doctor.isFavorite
                                ? Colors.red
                                : AppColors.gray400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
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
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.r,
                        color: AppColors.gray400,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          doctor.location,
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
                          fontWeight: FontWeight.w600,
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
    );
  }
}
