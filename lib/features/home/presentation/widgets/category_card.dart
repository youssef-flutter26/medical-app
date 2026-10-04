import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.title,
    this.icon = Icons.local_hospital_rounded,
    this.imagePath,
    this.backgroundColor = const Color(0xFFF0FDF4),
    this.iconColor = AppColors.darkTeal,
    this.specialistsCount,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final String? imagePath;
  final Color backgroundColor;
  final Color iconColor;
  final int? specialistsCount;
  final VoidCallback? onTap;

  Widget _buildIcon() {
    final path = imagePath?.trim() ?? '';
    if (path.isNotEmpty) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.network(
            path,
            width: 32.r,
            height: 32.r,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                Icon(icon, size: 28.r, color: iconColor),
          ),
        );
      }
      final assetPath = path.startsWith('assets/images/')
          ? path
          : (path.startsWith('assets/') ? path : 'assets/images/$path');
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.asset(
          assetPath,
          width: 32.r,
          height: 32.r,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              Icon(icon, size: 28.r, color: iconColor),
        ),
      );
    }
    return Icon(
      icon,
      size: 28.r,
      color: iconColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.gray100,
              width: 1.w,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                alignment: Alignment.center,
                child: _buildIcon(),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.withColor(
                  AppTextStyles.inter14W500.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  AppColors.gray700,
                ),
              ),
              if (specialistsCount != null) ...[
                SizedBox(height: 4.h),
                Text(
                  '$specialistsCount+ Doctors',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.withColor(
                    AppTextStyles.inter12W400,
                    AppColors.gray400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
