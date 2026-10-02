import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final User? user;
  final UserModel? userModel;

  const ProfileHeader({
    super.key,
    required this.user,
    this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName =
        (userModel?.name != null && userModel!.name!.trim().isNotEmpty)
            ? userModel!.name!.trim()
            : (user?.displayName != null && user!.displayName!.trim().isNotEmpty
                ? user!.displayName!.trim()
                : (userModel?.email.split('@').first ??
                    user?.email?.split('@').first ??
                    LocaleKeys.user.tr()));
    final String email =
        (userModel?.email != null && userModel!.email.trim().isNotEmpty)
            ? userModel!.email.trim()
            : (user?.email ?? '');
    final photoUrl = user?.photoURL;
    final isAdmin = userModel?.role == 'admin';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.gray400.withValues(alpha: 0.22),
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
      child: Column(
        children: [
          CircleAvatar(
            radius: 46.r,
            backgroundColor: AppColors.bannerBgStart,
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : null,
            child: photoUrl == null || photoUrl.isEmpty
                ? Icon(
                    Icons.person_rounded,
                    size: 50.r,
                    color: AppColors.lightTeal,
                  )
                : null,
          ),
          SizedBox(height: 14.h),
          Text(
            displayName,
            style: AppTextStyles.withColor(
              AppTextStyles.inter18W700,
              AppColors.darkTeal,
            ),
            textAlign: TextAlign.center,
          ),
          if (email.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              email,
              style: AppTextStyles.withColor(
                AppTextStyles.inter14W400,
                AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (isAdmin) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.darkTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.darkTeal.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Admin',
                style: AppTextStyles.withColor(
                  AppTextStyles.inter12W500,
                  AppColors.darkTeal,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
