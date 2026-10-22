import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'package:medical_app/core/common/widgets/app_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:medical_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:medical_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:medical_app/features/auth/presentation/widgets/gender_type.dart';
import 'package:medical_app/features/profile/presentation/widgets/profile_photo_bottom_sheet.dart';

class FillProfile extends StatefulWidget {
  final String name;
  final String email;

  const FillProfile({super.key, required this.name, required this.email});

  @override
  State<FillProfile> createState() => _FillProfileState();
}

class _FillProfileState extends State<FillProfile> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController nickNameController;
  late final TextEditingController genderController;
  late final TextEditingController birthDateController;
  late final TextEditingController emailController;

  bool isSaving = false;
  bool isLoadingData = true;
  String? photoUrl;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
    nickNameController = TextEditingController();
    genderController = TextEditingController();
    birthDateController = TextEditingController();

    _loadExistingUserData();
  }

  Future<void> _loadExistingUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        if (nameController.text.trim().isEmpty &&
            currentUser.displayName != null &&
            currentUser.displayName!.trim().isNotEmpty) {
          nameController.text = currentUser.displayName!.trim();
        }
        if (emailController.text.trim().isEmpty &&
            currentUser.email != null &&
            currentUser.email!.trim().isNotEmpty) {
          emailController.text = currentUser.email!.trim();
        }
        if (currentUser.photoURL != null && currentUser.photoURL!.isNotEmpty) {
          photoUrl = currentUser.photoURL;
        }

        try {
          final prefs = await SharedPreferences.getInstance();
          final cachedPhoto = prefs.getString('profile_photo_${currentUser.uid}');
          if (cachedPhoto != null && cachedPhoto.isNotEmpty) {
            photoUrl = cachedPhoto;
          }
        } catch (_) {}

        final userRemoteDataSource = getIt<UserRemoteDataSource>();
        final userModel = await userRemoteDataSource.getUser(currentUser.uid);
        if (userModel != null && mounted) {
          if (userModel.name != null && userModel.name!.trim().isNotEmpty) {
            nameController.text = userModel.name!.trim();
          }
          if (userModel.email.trim().isNotEmpty) {
            emailController.text = userModel.email.trim();
          }
          if (userModel.nickname != null && userModel.nickname!.trim().isNotEmpty) {
            nickNameController.text = userModel.nickname!.trim();
          }
          if (userModel.birthDate != null && userModel.birthDate!.trim().isNotEmpty) {
            birthDateController.text = userModel.birthDate!.trim();
          }
          if (userModel.gender != null && userModel.gender!.trim().isNotEmpty) {
            genderController.text = userModel.gender!.trim();
          }
          if (userModel.photoUrl != null && userModel.photoUrl!.isNotEmpty) {
            photoUrl = userModel.photoUrl;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading existing user data in FillProfile: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingData = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;
    final action = await ProfilePhotoBottomSheet.show(
      context,
      hasExistingPhoto: hasPhoto,
    );

    if (action == null || !mounted) return;

    switch (action) {
      case ProfilePhotoAction.gallery:
        await _chooseImage(ImageSource.gallery);
        break;
      case ProfilePhotoAction.camera:
        await _chooseImage(ImageSource.camera);
        break;
      case ProfilePhotoAction.remove:
        final confirmed =
            await ProfilePhotoBottomSheet.showConfirmRemove(context);
        if (confirmed == true && mounted) {
          setState(() {
            photoUrl = null;
          });
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('profile_photo_${currentUser.uid}');
            } catch (_) {}
          }
        }
        break;
    }
  }

  Future<void> _chooseImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() {
          photoUrl = picked.path;
        });

        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(
              'profile_photo_${currentUser.uid}',
              picked.path,
            );
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Error picking image in FillProfile: $e');
    }
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 120.r,
      height: 120.r,
      color: const Color(0xFFEBE8E8),
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

  Widget _buildAvatarWidget() {
    Widget imageWidget;
    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      final path = photoUrl!.trim();
      if (path.startsWith('http://') || path.startsWith('https://')) {
        imageWidget = Image.network(
          path,
          width: 120.r,
          height: 120.r,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholderAvatar(),
        );
      } else {
        final file = File(path);
        if (file.existsSync()) {
          imageWidget = Image.file(
            file,
            width: 120.r,
            height: 120.r,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildPlaceholderAvatar(),
          );
        } else {
          imageWidget = _buildPlaceholderAvatar();
        }
      }
    } else {
      imageWidget = _buildPlaceholderAvatar();
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 120.r,
            height: 120.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEBE8E8),
            ),
            child: ClipOval(child: imageWidget),
          ),
          PositionedDirectional(
            bottom: 0,
            end: 0,
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.edit,
                size: 18.r,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    nickNameController.dispose();
    genderController.dispose();
    birthDateController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final authCubit = getIt<AuthCubit>();
    final isVerified = await authCubit.isEmailVerified();

    if (!mounted) {
      return;
    }

    if (!isVerified) {
      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.pleaseVerifyEmail.tr()),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final saved = await authCubit.saveProfile(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      nickname: nickNameController.text.trim(),
      birthDate: birthDateController.text.trim(),
      gender: genderController.text.trim(),
      photoUrl: photoUrl,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isSaving = false;
    });

    if (!saved) {
      return;
    }

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7FA899),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: const Color(0xFF7FA899),
                        size: 28.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  LocaleKeys.congratulations.tr(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  LocaleKeys.accountReadyShort.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24.h),
                const CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }

      Navigator.of(context, rootNavigator: true).pop(); // dismiss dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.mainLayout,
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';

    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            setState(() {
              isSaving = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Transform.flip(
                flipX: isRtl,
                child: const Icon(Icons.arrow_back),
              ),
            ),
            title: Text(
              LocaleKeys.fillYourProfile.tr(),
              style: AppTextStyles.inter20W600.copyWith(color: Colors.black),
            ),
          ),
          body: isLoadingData
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.darkTeal),
                )
              : Form(
                  key: formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 24.h),
                          Center(
                            child: _buildAvatarWidget(),
                          ),
                          SizedBox(height: 26.h),
                          AuthTextField(
                            controller: nameController,
                            hintText: LocaleKeys.yourName.tr(),
                            validator: ValidatorApp.validateName,
                          ),
                          SizedBox(height: 16.h),
                          AuthTextField(
                            controller: nickNameController,
                            hintText: LocaleKeys.nickname.tr(),
                            validator: ValidatorApp.validateNickname,
                          ),
                          SizedBox(height: 16.h),
                          AuthTextField(
                            controller: emailController,
                            hintText: LocaleKeys.yourEmail.tr(),
                            validator: ValidatorApp.validateEmail,
                          ),
                          SizedBox(height: 16.h),
                          AuthTextField(
                            controller: birthDateController,
                            hintText: LocaleKeys.dateOfBirth.tr(),
                            validator: ValidatorApp.validateBirthDate,
                          ),
                          SizedBox(height: 16.h),
                          AuthTextField(
                            controller: genderController,
                            hintText: LocaleKeys.gender.tr(),
                            suffixIcon: GenderType(
                              genderController: genderController,
                            ),
                            validator: ValidatorApp.validateGender,
                          ),
                          SizedBox(height: 32.h),
                          isSaving
                              ? const CircularProgressIndicator(
                                  color: AppColors.darkTeal,
                                )
                              : AppButton(
                                  text: LocaleKeys.save.tr(),
                                  onPressed: _saveProfile,
                                ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
