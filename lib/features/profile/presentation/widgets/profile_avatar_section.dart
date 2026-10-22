import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';

class ProfileAvatarSection extends StatelessWidget {
  final String? name;
  final String? subtitle;
  final String? avatarUrl;
  final ImageProvider? imageProvider;
  final VoidCallback? onEdit;
  final VoidCallback? onPickPhoto;

  const ProfileAvatarSection({
    super.key,
    this.name,
    this.subtitle,
    this.avatarUrl,
    this.imageProvider,
    this.onEdit,
    this.onPickPhoto,
  });

  Widget _buildPlaceholder() {
    return Container(
      width: 120.r,
      height: 120.r,
      color: AppColors.gray100,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppAssets.iconsUser,
        width: 50.r,
        height: 50.r,
        colorFilter: const ColorFilter.mode(
          AppColors.gray400,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (imageProvider != null) {
      return Image(
        image: imageProvider!,
        width: 120.r,
        height: 120.r,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      final url = avatarUrl!.trim();
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return Image.network(
          url,
          width: 120.r,
          height: 120.r,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultAssetImage(),
        );
      }

      final file = File(url);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 120.r,
          height: 120.r,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultAssetImage(),
        );
      }
    }

    return _buildDefaultAssetImage();
  }

  Widget _buildDefaultAssetImage() {
    return Image.asset(
      AppAssets.imagesUserAvatar,
      width: 120.r,
      height: 120.r,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (name != null && name!.trim().isNotEmpty)
        ? name!.trim()
        : null;

    final displaySubtitle = (subtitle != null && subtitle!.trim().isNotEmpty)
        ? subtitle!.trim()
        : null;

    final effectiveOnTap = onPickPhoto ?? onEdit;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: effectiveOnTap,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 120.r,
                height: 120.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gray100,
                ),
                child: ClipOval(
                  child: _buildAvatarImage(),
                ),
              ),
              PositionedDirectional(
                bottom: 4.r,
                end: 4.r,
                child: Container(
                  width: 28.r,
                  height: 28.r,
                  decoration: BoxDecoration(
                    color: AppColors.darkTeal,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    AppAssets.iconsEdit,
                    width: 14.r,
                    height: 14.r,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (displayName != null) ...[
          SizedBox(height: 14.h),
          Text(
            displayName,
            style: AppTextStyles.inter18W700.copyWith(
              fontSize: 18.sp,
              color: AppColors.darkTeal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (displaySubtitle != null) ...[
          SizedBox(height: 4.h),
          Text(
            displaySubtitle,
            style: AppTextStyles.inter14W400.copyWith(
              fontSize: 13.sp,
              color: AppColors.gray400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
