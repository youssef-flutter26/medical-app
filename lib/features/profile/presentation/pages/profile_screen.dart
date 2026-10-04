import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
import 'package:medical_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:medical_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:medical_app/features/profile/presentation/widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseAuth? auth;
  final UserRemoteDataSource? userRemoteDataSource;
  final AuthRepository? authRepository;
  final Stream<UserModel?>? userModelStream;
  final User? currentUser;

  const ProfileScreen({
    super.key,
    this.auth,
    this.userRemoteDataSource,
    this.authRepository,
    this.userModelStream,
    this.currentUser,
  });

  FirebaseAuth? get _auth {
    if (auth != null) return auth;
    try {
      return getIt.isRegistered<FirebaseAuth>()
          ? getIt<FirebaseAuth>()
          : FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  UserRemoteDataSource? get _userRemoteDataSource {
    if (userRemoteDataSource != null) return userRemoteDataSource;
    try {
      return getIt.isRegistered<UserRemoteDataSource>()
          ? getIt<UserRemoteDataSource>()
          : null;
    } catch (_) {
      return null;
    }
  }

  AuthRepository? get _authRepository {
    if (authRepository != null) return authRepository;
    try {
      return getIt.isRegistered<AuthRepository>()
          ? getIt<AuthRepository>()
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            LocaleKeys.logOut.tr(),
            style: AppTextStyles.inter16W500,
          ),
          content: Text(
            LocaleKeys.logOutConfirmation.tr(),
            style: AppTextStyles.withColor(
              AppTextStyles.inter14W400,
              AppColors.gray500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                LocaleKeys.cancel.tr(),
                style: AppTextStyles.withColor(
                  AppTextStyles.inter14W500,
                  AppColors.gray500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                LocaleKeys.logOut.tr(),
                style: AppTextStyles.withColor(
                  AppTextStyles.inter14W500,
                  AppColors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      if (_authRepository != null) {
        final result = await _authRepository!.logout();
        if (result is ErrorAPI) {
          throw Exception(result.failure.message);
        }
      } else {
        final authToUse = _auth ?? FirebaseAuth.instance;
        await authToUse.signOut();
        try {
          await GoogleSignIn.instance.signOut();
        } catch (_) {
          // Ignore if Google sign-in was not used
        }
      }

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.login,
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userModelStream != null) {
      return StreamBuilder<UserModel?>(
        stream: userModelStream,
        builder: (context, userSnapshot) {
          return _buildScaffold(
            context,
            user: currentUser,
            userModel: userSnapshot.data,
          );
        },
      );
    }

    final firebaseAuth = _auth;
    final remoteDataSource = _userRemoteDataSource;

    if (firebaseAuth == null) {
      return _buildScaffold(context, user: null, userModel: null);
    }

    return StreamBuilder<User?>(
      stream: firebaseAuth.authStateChanges(),
      builder: (context, authSnapshot) {
        final currentUser = authSnapshot.data ?? firebaseAuth.currentUser;

        if (currentUser == null || remoteDataSource == null) {
          return _buildScaffold(context, user: currentUser, userModel: null);
        }

        return StreamBuilder<UserModel?>(
          stream: remoteDataSource.getUserStream(currentUser.uid),
          builder: (context, userSnapshot) {
            final userModel = userSnapshot.data;
            return _buildScaffold(
              context,
              user: currentUser,
              userModel: userModel,
            );
          },
        );
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context, {
    required User? user,
    required UserModel? userModel,
  }) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          LocaleKeys.profile.tr(),
          style: AppTextStyles.inter16W500,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              ProfileHeader(user: user, userModel: userModel),
              SizedBox(height: 16.h),
              if (userModel != null) ...[
                if (userModel.nickname != null &&
                    userModel.nickname!.trim().isNotEmpty) ...[
                  _buildProfileInfoTile(
                    title: LocaleKeys.nickname.tr(),
                    value: userModel.nickname!.trim(),
                    icon: Icons.badge_outlined,
                  ),
                  SizedBox(height: 12.h),
                ],
                if (userModel.birthDate != null &&
                    userModel.birthDate!.trim().isNotEmpty) ...[
                  _buildProfileInfoTile(
                    title: LocaleKeys.dateOfBirth.tr(),
                    value: userModel.birthDate!.trim(),
                    icon: Icons.calendar_today_rounded,
                  ),
                  SizedBox(height: 12.h),
                ],
                if (userModel.gender != null &&
                    userModel.gender!.trim().isNotEmpty) ...[
                  _buildProfileInfoTile(
                    title: LocaleKeys.gender.tr(),
                    value: userModel.gender!.trim(),
                    icon: Icons.person_outline_rounded,
                  ),
                  SizedBox(height: 12.h),
                ],
              ],
              SizedBox(height: 12.h),
              ProfileMenuItem(
                title: LocaleKeys.logOut.tr(),
                icon: Icons.logout_rounded,
                isDestructive: true,
                onTap: () => _handleLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 22.r,
              color: AppColors.darkTeal,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.withColor(
                    AppTextStyles.inter12W500,
                    AppColors.gray500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTextStyles.withColor(
                    AppTextStyles.inter16W500,
                    AppColors.gray700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
