import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.title,
    this.icon = Icons.local_hospital_rounded,
    this.imagePath,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
    this.isAdmin = false,
    this.onEdit,
  });

  final String title;
  final IconData? icon;
  final String? imagePath;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isAdmin;
  final VoidCallback? onEdit;

  String get _displayTitle {
    if (title.length > 9) {
      return '${title.substring(0, 7)}..';
    }
    return title;
  }

  Widget _buildContent() {
    final path = imagePath?.trim() ?? '';
    if (path.isNotEmpty) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Image.network(
            path,
            width: 64.w,
            height: 64.h,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildIcon(),
          ),
        );
      }
      final assetPath = path.startsWith('assets/images/')
          ? path
          : (path.startsWith('assets/') ? path : 'assets/images/$path');
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.asset(
          assetPath,
          width: 64.w,
          height: 64.h,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildIcon(),
        ),
      );
    }
    return _buildIcon();
  }

  Widget _buildIcon() {
    return Icon(
      icon ?? Icons.local_hospital_rounded,
      size: 26.r,
      color: iconColor ?? AppColors.darkTeal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.gray100,
              borderRadius: BorderRadius.circular(16.r),
            ),
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                _buildContent(),
                if (isAdmin && onEdit != null)
                  Positioned(
                    top: 2.h,
                    right: 2.w,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: const Key('category_edit_button'),
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color: AppColors.darkTeal.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            color: AppColors.white,
                            size: 12.r,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _displayTitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.inter12W500.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }
}
