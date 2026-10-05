import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

/// A compact, full-width category row.
///
/// Uses the same neutral surface as the rest of the app (white, `gray100`
/// hairline border, soft shadow, 16.r radius) so the category artwork stays the
/// visual focus.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.title,
    this.icon = Icons.local_hospital_rounded,
    this.imagePath,
    this.iconColor = AppColors.darkTeal,
    this.isAdmin = false,
    this.onEdit,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final String? imagePath;
  final Color iconColor;
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
    final placeholder = Icon(icon, size: 24.r, color: iconColor);

    if (path.isEmpty) return placeholder;

    // BoxFit.contain keeps the artwork at its natural aspect ratio so it is
    // never stretched to fill the tile.
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    return Image.asset(
      _resolveAssetPath(path),
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => placeholder,
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 56.w,
      height: 56.h,
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: _buildMedia(),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
      style: AppTextStyles.inter16W500.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.darkTeal,
      ),
    );
  }

  Widget _buildEditButton() {
    // Same Material icon, size and colour as the other admin edit
    // affordances (DoctorCard / MedicalCenterItem), without a filled circle.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('category_edit_button'),
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(4.r),
          child: Icon(
            Icons.edit_rounded,
            size: 14.r,
            color: AppColors.darkTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingArrow(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Icon(
      isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
      size: 20.r,
      color: AppColors.gray400,
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: radius,
        border: Border.all(color: AppColors.gray100, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkTeal.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Row(
            children: [
              _buildThumbnail(),
              SizedBox(width: 12.w),
              Expanded(child: _buildTitle()),
              if (_canEdit) ...[_buildEditButton(), SizedBox(width: 8.w)],
              _buildTrailingArrow(context),
            ],
          ),
        ),
      ),
    );
  }
}
