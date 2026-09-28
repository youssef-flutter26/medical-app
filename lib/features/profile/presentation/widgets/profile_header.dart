import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  final User? user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName != null && user!.displayName!.isNotEmpty
        ? user!.displayName!
        : (user?.email?.split('@').first ?? 'User');
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;

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
        ],
      ),
    );
  }
}
