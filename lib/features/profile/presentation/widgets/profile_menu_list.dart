import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'profile_menu_item.dart';

class ProfileMenuList extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onFavorite;
  final VoidCallback onNotifications;
  final VoidCallback onSettings;
  final VoidCallback onHelpAndSupport;
  final VoidCallback onTermsAndConditions;
  final VoidCallback onLogout;

  const ProfileMenuList({
    super.key,
    required this.onEditProfile,
    required this.onFavorite,
    required this.onNotifications,
    required this.onSettings,
    required this.onHelpAndSupport,
    required this.onTermsAndConditions,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileMenuItem(
          leadingIcon: SvgPicture.asset(
            AppAssets.iconsUserEdit,
            width: 22.r,
            height: 22.r,
            colorFilter: const ColorFilter.mode(
              AppColors.gray700,
              BlendMode.srcIn,
            ),
          ),
          title: LocaleKeys.editProfile.tr(),
          onTap: onEditProfile,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          indent: 0,
          endIndent: 0,
          color: AppColors.gray100,
        ),
        ProfileMenuItem(
          leadingIcon: SvgPicture.asset(
            AppAssets.iconsHeart,
            width: 22.r,
            height: 22.r,
            colorFilter: const ColorFilter.mode(
              AppColors.gray700,
              BlendMode.srcIn,
            ),
          ),
          title: LocaleKeys.favorite.tr(),
          onTap: onFavorite,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          indent: 0,
          endIndent: 0,
          color: AppColors.gray100,
        ),
        ProfileMenuItem(
          leadingIcon: SvgPicture.asset(
            AppAssets.iconsNotificationSingle,
            width: 22.r,
            height: 22.r,
            colorFilter: const ColorFilter.mode(
              AppColors.gray700,
              BlendMode.srcIn,
            ),
          ),
          title: LocaleKeys.notifications.tr(),
          onTap: onNotifications,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          indent: 0,
          endIndent: 0,
          color: AppColors.gray100,
        ),
        ProfileMenuItem(
          leadingIcon: SvgPicture.asset(
            AppAssets.iconsSetting2,
            width: 22.r,
            height: 22.r,
            colorFilter: const ColorFilter.mode(
              AppColors.gray700,
              BlendMode.srcIn,
            ),
          ),
          title: LocaleKeys.settings.tr(),
          onTap: onSettings,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          indent: 0,
          endIndent: 0,
          color: AppColors.gray100,
        ),
        ProfileMenuItem(
          leadingIcon: SvgPicture.asset(
            AppAssets.iconsMessageQuestion,
            width: 22.r,
            height: 22.r,
            colorFilter: const ColorFilter.mode(
              AppColors.gray700,
              BlendMode.srcIn,
            ),
          ),
          title: LocaleKeys.helpAndSupport.tr(),
          onTap: onHelpAndSupport,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          indent: 0,
          endIndent: 0,
          color: AppColors.gray100,
        ),
        ProfileMenuItem(
          leadingIcon: SvgPicture.asset(
            AppAssets.iconsSecuritySafe,
            width: 22.r,
            height: 22.r,
            colorFilter: const ColorFilter.mode(
              AppColors.gray700,
              BlendMode.srcIn,
            ),
          ),
          title: LocaleKeys.termsAndConditions.tr(),
          onTap: onTermsAndConditions,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          indent: 0,
          endIndent: 0,
          color: AppColors.gray100,
        ),
        ProfileMenuItem(
          leadingIcon: SvgPicture.asset(
            AppAssets.iconsLogout,
            width: 22.r,
            height: 22.r,
            colorFilter: const ColorFilter.mode(
              AppColors.gray700,
              BlendMode.srcIn,
            ),
          ),
          title: LocaleKeys.logOut.tr(),
          showChevron: false,
          onTap: onLogout,
        ),
      ],
    );
  }
}
