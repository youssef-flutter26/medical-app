import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';

class NotificationsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int unreadCount;
  final VoidCallback? onBack;

  const NotificationsAppBar({
    super.key,
    required this.unreadCount,
    this.onBack,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: SvgPicture.asset(
          AppAssets.iconsBackIcon,
          width: 22.r,
          height: 22.r,
          colorFilter: const ColorFilter.mode(
            AppColors.darkTeal,
            BlendMode.srcIn,
          ),
        ),
        onPressed: onBack ?? () => Navigator.pop(context),
      ),
      title: Text(
        LocaleKeys.notification.tr(),
        style: AppTextStyles.inter18W700.copyWith(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTeal,
        ),
      ),
      actions: [
        if (unreadCount > 0)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E384D),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  LocaleKeys.newNotificationsCount.tr(args: ['$unreadCount']),
                  style: AppTextStyles.inter12W500.copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
