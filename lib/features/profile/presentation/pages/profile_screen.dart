import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/logout_bottom_sheet.dart';
import '../widgets/profile_avatar_section.dart';
import '../widgets/profile_menu_list.dart';
import '../widgets/profile_photo_bottom_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..init(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _navigateToEditProfile(BuildContext context, ProfileState state) {
    String name = '';
    String email = '';

    if (state is ProfileLoaded && state.user != null) {
      if (state.user!.name != null && state.user!.name!.trim().isNotEmpty) {
        name = state.user!.name!.trim();
      }
      email = state.user!.email;
    }

    Navigator.pushNamed(
      context,
      Routes.fillProfile,
      arguments: {
        'name': name,
        'email': email,
      },
    );
  }

  Future<void> _handlePhotoAction(
    BuildContext context, {
    required bool hasExistingPhoto,
  }) async {
    final action = await ProfilePhotoBottomSheet.show(
      context,
      hasExistingPhoto: hasExistingPhoto,
    );

    if (action == null || !context.mounted) return;

    switch (action) {
      case ProfilePhotoAction.gallery:
        await _pickAndSavePhoto(context, ImageSource.gallery);
        break;
      case ProfilePhotoAction.camera:
        await _pickAndSavePhoto(context, ImageSource.camera);
        break;
      case ProfilePhotoAction.remove:
        await _confirmAndRemovePhoto(context);
        break;
    }
  }

  Future<void> _pickAndSavePhoto(
    BuildContext context, [
    ImageSource source = ImageSource.gallery,
  ]) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null && context.mounted) {
        await context.read<ProfileCubit>().updatePhoto(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Error picking profile image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmAndRemovePhoto(BuildContext context) async {
    final confirmed = await ProfilePhotoBottomSheet.showConfirmRemove(context);
    if (confirmed == true && context.mounted) {
      await context.read<ProfileCubit>().removePhoto();
    }
  }

  void _showLogoutDialog(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();

    LogoutBottomSheet.show(
      context,
      onConfirmLogout: () async {
        final success = await profileCubit.logout();
        if (context.mounted && success) {
          Navigator.of(context).pop(); // Dismiss bottom sheet
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.login,
            (route) => false,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: canPop,
        leading: canPop
            ? IconButton(
                icon: SvgPicture.asset(
                  AppAssets.iconsBackIcon,
                  width: 24.r,
                  height: 24.r,
                  colorFilter: const ColorFilter.mode(
                    AppColors.gray700,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          LocaleKeys.profile.tr(),
          style: AppTextStyles.inter18W700.copyWith(
            fontSize: 18.sp,
            color: AppColors.darkTeal,
          ),
        ),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLogoutFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          String? userName;
          String? userSubtitle;
          String? userAvatarUrl;

          if (state is ProfileLoaded && state.user != null) {
            final user = state.user!;
            if (user.name != null && user.name!.trim().isNotEmpty) {
              userName = user.name!.trim();
            }
            if (user.email.isNotEmpty) {
              userSubtitle = user.email;
            }
            if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
              userAvatarUrl = user.photoUrl;
            }
          }

          final hasExistingPhoto =
              userAvatarUrl != null && userAvatarUrl.trim().isNotEmpty;

          return SafeArea(
            top: false,
            left: false,
            right: false,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 12.h),
                  ProfileAvatarSection(
                    name: userName,
                    subtitle: userSubtitle,
                    avatarUrl: userAvatarUrl,
                    onEdit: () => _handlePhotoAction(
                      context,
                      hasExistingPhoto: hasExistingPhoto,
                    ),
                    onPickPhoto: () => _handlePhotoAction(
                      context,
                      hasExistingPhoto: hasExistingPhoto,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ProfileMenuList(
                    onEditProfile: () => _navigateToEditProfile(context, state),
                    onFavorite: () {
                      Navigator.pushNamed(context, Routes.favorites);
                    },
                    onNotifications: () {
                      // Navigate to notifications or show info
                    },
                    onSettings: () {
                      // Navigate to settings or show info
                    },
                    onHelpAndSupport: () {
                      // Navigate to help or show info
                    },
                    onTermsAndConditions: () {
                      // Navigate to terms or show info
                    },
                    onLogout: () => _showLogoutDialog(context),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
