import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
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
      children: [
        ProfileMenuItem(
          leadingIcon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 22.r,
                color: AppColors.gray700,
              ),
              PositionedDirectional(
                top: 0,
                start: -1,
                child: Icon(
                  Icons.edit,
                  size: 9.r,
                  color: AppColors.gray700,
                ),
              ),
            ],
          ),
          title: LocaleKeys.editProfile.tr(),
          onTap: onEditProfile,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.gray100,
        ),
        ProfileMenuItem(
          leadingIcon: Icon(
            Icons.favorite_border_rounded,
            size: 21.r,
            color: AppColors.gray700,
          ),
          title: LocaleKeys.favorite.tr(),
          onTap: onFavorite,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.gray100,
        ),
        ProfileMenuItem(
          leadingIcon: Icon(
            Icons.notifications_none_rounded,
            size: 22.r,
            color: AppColors.gray700,
          ),
          title: LocaleKeys.notifications.tr(),
          onTap: onNotifications,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.gray100,
        ),
        ProfileMenuItem(
          leadingIcon: Icon(
            Icons.settings_outlined,
            size: 22.r,
            color: AppColors.gray700,
          ),
          title: LocaleKeys.settings.tr(),
          onTap: onSettings,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.gray100,
        ),
        ProfileMenuItem(
          leadingIcon: Icon(
            Icons.contact_support_outlined,
            size: 22.r,
            color: AppColors.gray700,
          ),
          title: LocaleKeys.helpAndSupport.tr(),
          onTap: onHelpAndSupport,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.gray100,
        ),
        ProfileMenuItem(
          leadingIcon: Icon(
            Icons.privacy_tip_outlined,
            size: 22.r,
            color: AppColors.gray700,
          ),
          title: LocaleKeys.termsAndConditions.tr(),
          onTap: onTermsAndConditions,
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.gray100,
        ),
        ProfileMenuItem(
          leadingIcon: Icon(
            Icons.logout_rounded,
            size: 22.r,
            color: AppColors.gray700,
          ),
          title: LocaleKeys.logOut.tr(),
          showChevron: false,
          onTap: onLogout,
        ),
      ],
    );
  }
}
