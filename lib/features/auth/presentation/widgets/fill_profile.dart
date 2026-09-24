import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'package:medical_app/core/widgets/app_button.dart';
import 'package:medical_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:medical_app/features/auth/presentation/widgets/gender_type.dart';

class FillProfile extends StatefulWidget {
  const FillProfile({super.key});

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

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    nickNameController = TextEditingController();
    genderController = TextEditingController();
    birthDateController = TextEditingController();
    emailController = TextEditingController();
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Circle
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
                // Title
                Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                // Subtitle
                Text(
                  'Your account is ready to use. You will be redirected to the Home Page in a few seconds',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24.h),
                // Loading Indicator
                const CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 3.0,
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.login,
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Fill Your Profile',
          style: AppTextStyles.inter20W600.copyWith(color: Colors.black),
        ),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.0.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 24.h),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60.r,
                        backgroundColor: const Color(0xFFEBE8E8),
                        child: Icon(
                          Icons.person,
                          size: 80.r,
                          color: Colors.grey[400],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
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
                ),
                SizedBox(height: 26.h),
                AuthTextField(
                  controller: nameController,
                  hintText: 'Name',
                  validator: ValidatorApp.validateName,
                ),
                SizedBox(height: 16.h),
                AuthTextField(
                  controller: nickNameController,
                  hintText: 'Nickname',
                  validator: ValidatorApp.validateNickname,
                ),
                SizedBox(height: 16.h),
                AuthTextField(
                  controller: emailController,
                  hintText: 'Email',
                  validator: ValidatorApp.validateEmail,
                ),
                SizedBox(height: 16.h),
                AuthTextField(
                  controller: birthDateController,
                  hintText: 'Birth of date',
                  validator: ValidatorApp.validateBirthDate,
                ),
                SizedBox(height: 16.h),
                AuthTextField(
                  controller: genderController,
                  hintText: 'Gender',
                  suffixIcon: GenderType(genderController: genderController),
                  validator: ValidatorApp.validateGender,
                ),
                SizedBox(height: 32.h),
                AppButton(
                  text: 'Save',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      _showSuccessDialog();
                    }
                  },
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
