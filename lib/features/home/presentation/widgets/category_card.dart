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
    this.isAdmin = false,
    this.onEdit,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final String? imagePath;
  final Color backgroundColor;
  final Color iconColor;
  final int? specialistsCount;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  bool get _canEdit => isAdmin && onEdit != null;

  static String _resolveAssetPath(String path) {
    if (path.startsWith('assets/images/')) return path;
    if (path.startsWith('assets/')) return path;
    return 'assets/images/$path';
  }

  Widget _buildMedia() {
    final path = imagePath?.trim() ?? '';

    if (path.isNotEmpty) {
      final placeholder = Icon(icon, size: 34.r, color: iconColor);
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return Image.network(
          path,
          width: 44.r,
          height: 44.r,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => placeholder,
        );
      }
      return Image.asset(
        _resolveAssetPath(path),
        width: 44.r,
        height: 44.r,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    return Icon(icon, size: 34.r, color: iconColor);
  }

  Widget _buildTile() {
    return Container(
      width: 76.w,
      height: 76.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            Color.lerp(backgroundColor, AppColors.white, 0.5) ?? AppColors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(18.r),
      ),
      alignment: Alignment.center,
      child: _buildMedia(),
    );
  }

  Widget _buildLabels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.inter16W500.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: AppColors.darkTeal,
          ),
        ),
        if (specialistsCount != null) ...[
          SizedBox(height: 4.h),
          Text(
            '$specialistsCount+ Doctors',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.withColor(
              AppTextStyles.inter12W400,
              AppColors.gray500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEditButton() {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      child: InkWell(
        key: const Key('category_edit_button'),
        onTap: onEdit,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: backgroundColor, width: 1.5.w),
          ),
          child: Icon(
            Icons.edit_rounded,
            size: 18.r,
            color: iconColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.gray100, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkTeal.withValues(alpha: 0.06),
                blurRadius: 14.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                _buildTile(),
                SizedBox(width: 14.w),
                Expanded(child: _buildLabels()),
                SizedBox(width: 8.w),
                if (_canEdit) ...[
                  _buildEditButton(),
                  SizedBox(width: 8.w),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  size: 24.r,
                  color: AppColors.gray400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}