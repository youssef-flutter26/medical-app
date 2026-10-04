import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/category/presentation/widgets/category_doctors/doctor_card.dart';
import 'package:medical_app/features/doctor/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/presentation/widgets/medical_center_item.dart';
import 'package:medical_app/features/home/presentation/widgets/nearby_medical_centers.dart';

class HomeSearchResults extends StatelessWidget {
  final String searchQuery;
  final bool isLoading;
  final bool isAdmin;
  final List<DoctorEntity> doctors;
  final List<CategoryEntity> categories;
  final List<MedicalCenterEntity> medicalCenters;
  final List<BannerEntity> banners;
  final ValueChanged<DoctorEntity> onDoctorTap;
  final ValueChanged<CategoryEntity> onCategoryTap;
  final ValueChanged<MedicalCenterEntity> onMedicalCenterTap;
  final ValueChanged<DoctorEntity>? onDoctorEdit;
  final ValueChanged<CategoryEntity>? onCategoryEdit;
  final ValueChanged<MedicalCenterEntity>? onMedicalCenterEdit;

  const HomeSearchResults({
    super.key,
    required this.searchQuery,
    this.isLoading = false,
    this.isAdmin = false,
    this.doctors = const [],
    this.categories = const [],
    this.medicalCenters = const [],
    this.banners = const [],
    required this.onDoctorTap,
    required this.onCategoryTap,
    required this.onMedicalCenterTap,
    this.onDoctorEdit,
    this.onCategoryEdit,
    this.onMedicalCenterEdit,
  });

  int get totalCount =>
      doctors.length + categories.length + medicalCenters.length + banners.length;

  bool get isEmpty => totalCount == 0;

  @override
  Widget build(BuildContext context) {
    if (isLoading && isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 48.h),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          color: AppColors.darkTeal,
        ),
      );
    }

    if (isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryHeader(),
        SizedBox(height: 16.h),
        if (categories.isNotEmpty) ...[
          _buildSectionHeader(
            title: LocaleKeys.categories.tr(),
            count: categories.length,
            icon: Icons.grid_view_rounded,
            color: AppColors.lightTeal,
          ),
          ...categories.map((cat) => _buildCategoryItem(context, cat)),
          SizedBox(height: 12.h),
        ],
        if (doctors.isNotEmpty) ...[
          _buildSectionHeader(
            title: LocaleKeys.allDoctors.tr(),
            count: doctors.length,
            icon: Icons.person_rounded,
            color: AppColors.primary600,
          ),
          ...doctors.map(
            (doctor) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: DoctorCard(
                doctor: DoctorData.fromEntity(doctor),
                isAdmin: isAdmin,
                onTap: () => onDoctorTap(doctor),
                onEdit: isAdmin && onDoctorEdit != null
                    ? () => onDoctorEdit!(doctor)
                    : null,
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
        if (medicalCenters.isNotEmpty) ...[
          _buildSectionHeader(
            title: LocaleKeys.nearbyMedicalCenters.tr(),
            count: medicalCenters.length,
            icon: Icons.local_hospital_rounded,
            color: AppColors.darkTeal,
          ),
          ...medicalCenters.map(
            (center) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildMedicalCenterItem(center),
            ),
          ),
          SizedBox(height: 12.h),
        ],
        if (banners.isNotEmpty) ...[
          _buildSectionHeader(
            title: '${LocaleKeys.banner.tr()}s',
            count: banners.length,
            icon: Icons.campaign_rounded,
            color: AppColors.amber,
          ),
          ...banners.map((banner) => _buildBannerItem(banner)),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _buildSummaryHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Results for "$searchQuery"',
            style: AppTextStyles.inter16W500.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
              color: AppColors.darkTeal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.lightTeal.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            '$totalCount found',
            style: AppTextStyles.inter12W500.copyWith(
              color: AppColors.lightTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 4.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 16.r, color: color),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: AppTextStyles.inter16W500.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              color: AppColors.darkTeal,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.inter12W500.copyWith(
                color: AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryEntity category) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () => onCategoryTap(category),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                _buildCategoryIcon(category),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              style: AppTextStyles.inter14W500.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTeal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightTeal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              LocaleKeys.category.tr(),
                              style: AppTextStyles.inter12W500.copyWith(
                                fontSize: 11.sp,
                                color: AppColors.lightTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'View doctors in ${category.name}',
                        style: AppTextStyles.inter12W400.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                if (isAdmin && onCategoryEdit != null)
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18.r,
                      color: AppColors.lightTeal,
                    ),
                    onPressed: () => onCategoryEdit!(category),
                  ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.r,
                  color: AppColors.gray400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(CategoryEntity category) {
    final path = category.imagePath?.trim() ?? '';
    if (path.isNotEmpty) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Image.network(
            path,
            width: 40.r,
            height: 40.r,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _buildFallbackCategoryIcon(),
          ),
        );
      }
      final assetPath = path.startsWith('assets/images/')
          ? path
          : (path.startsWith('assets/') ? path : 'assets/images/$path');
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Image.asset(
          assetPath,
          width: 40.r,
          height: 40.r,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildFallbackCategoryIcon(),
        ),
      );
    }
    return _buildFallbackCategoryIcon();
  }

  Widget _buildFallbackCategoryIcon() {
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        color: AppColors.lightTeal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(
        Icons.local_hospital_rounded,
        size: 20.r,
        color: AppColors.lightTeal,
      ),
    );
  }

  Widget _buildMedicalCenterItem(MedicalCenterEntity center) {
    final centerData = MedicalCenterData(
      id: center.id,
      name: center.name,
      address: center.address,
      rating: center.rating,
      reviewCount: center.reviewsCount,
      distance: '${center.distance} km',
      duration: center.duration > 0 ? '${center.duration} min' : null,
      type: center.type,
      imagePath: center.imagePath,
      imageUrl: center.imagePath.startsWith('http') ? center.imagePath : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedicalCenterItem(
          name: centerData.name,
          address: centerData.address,
          rating: centerData.rating,
          reviewCount: centerData.reviewCount,
          distance: centerData.distance,
          duration: centerData.duration,
          type: centerData.type,
          imagePath: centerData.imagePath,
          imageUrl: centerData.imageUrl,
          isAdmin: isAdmin,
          onTap: () => onMedicalCenterTap(center),
          onEdit: isAdmin && onMedicalCenterEdit != null
              ? () => onMedicalCenterEdit!(center)
              : null,
        ),
      ],
    );
  }

  Widget _buildBannerItem(BannerEntity banner) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  banner.title,
                  style: AppTextStyles.inter14W500.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTeal,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  LocaleKeys.banner.tr(),
                  style: AppTextStyles.inter12W500.copyWith(
                    fontSize: 11.sp,
                    color: AppColors.amber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (banner.description.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              banner.description,
              style: AppTextStyles.inter12W400.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.h),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68.r,
            height: 68.r,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 34.r,
              color: AppColors.gray400,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            LocaleKeys.contentNotFound.tr(),
            style: AppTextStyles.inter16W500.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkTeal,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'No matching doctors, categories, or medical centers found.',
            style: AppTextStyles.inter14W400.copyWith(
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
