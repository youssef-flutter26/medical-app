import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/common/widgets/app_button.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

enum ProfilePhotoAction {
  gallery,
  remove,
}

class ProfilePhotoBottomSheet extends StatelessWidget {
  final bool hasExistingPhoto;
  final ValueChanged<ProfilePhotoAction> onActionSelected;

  const ProfilePhotoBottomSheet({
    super.key,
    required this.hasExistingPhoto,
    required this.onActionSelected,
  });

  static Future<ProfilePhotoAction?> show(
    BuildContext context, {
    required bool hasExistingPhoto,
  }) {
    return showModalBottomSheet<ProfilePhotoAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => ProfilePhotoBottomSheet(
        hasExistingPhoto: hasExistingPhoto,
        onActionSelected: (action) {
          Navigator.pop(bottomSheetContext, action);
        },
      ),
    );
  }

  static Future<bool?> showConfirmRemove(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28.r),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          24.w,
          22.h,
          24.w,
          24.h + MediaQuery.of(bottomSheetContext).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocaleKeys.removeProfilePicture.tr(),
              style: AppTextStyles.inter18W700.copyWith(
                fontSize: 18.sp,
                color: AppColors.darkTeal,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.gray100,
            ),
            SizedBox(height: 24.h),
            Text(
              LocaleKeys.removePhotoConfirmation.tr(),
              style: AppTextStyles.inter14W500.copyWith(
                fontSize: 14.sp,
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: LocaleKeys.cancel.tr(),
                    backgroundColor: AppColors.gray100,
                    textColor: AppColors.gray700,
                    height: 48.h,
                    borderRadius: 24.r,
                    textStyle: AppTextStyles.inter14W500.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.gray700,
                      fontWeight: FontWeight.w600,
                    ),
                    onPressed: () => Navigator.pop(bottomSheetContext, false),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: AppButton(
                    text: LocaleKeys.yesRemove.tr(),
                    backgroundColor: AppColors.red,
                    textColor: AppColors.white,
                    height: 48.h,
                    borderRadius: 24.r,
                    textStyle: AppTextStyles.inter14W500.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    onPressed: () => Navigator.pop(bottomSheetContext, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24.w,
        22.h,
        24.w,
        24.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LocaleKeys.profilePicture.tr(),
            style: AppTextStyles.inter18W700.copyWith(
              fontSize: 18.sp,
              color: AppColors.darkTeal,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.gray100,
          ),
          SizedBox(height: 12.h),
          _buildOptionTile(
            icon: Icons.photo_library_outlined,
            title: LocaleKeys.chooseFromGallery.tr(),
            color: AppColors.darkTeal,
            onTap: () => onActionSelected(ProfilePhotoAction.gallery),
          ),
          if (hasExistingPhoto)
            _buildOptionTile(
              icon: Icons.delete_outline_rounded,
              title: LocaleKeys.removeProfilePicture.tr(),
              color: AppColors.red,
              onTap: () => onActionSelected(ProfilePhotoAction.remove),
            ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 22.r,
                color: color,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.inter16W500.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.r,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}
