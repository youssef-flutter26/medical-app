import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'package:medical_app/core/widgets/app_button.dart';
import 'package:medical_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:medical_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:medical_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:medical_app/features/auth/presentation/widgets/custom_health_pal.dart';
import 'package:medical_app/features/auth/presentation/widgets/have_an_account_widget.dart';
import 'package:medical_app/features/auth/presentation/widgets/or_widget.dart';
import 'package:medical_app/features/auth/presentation/widgets/social_auth_button.dart';

class RegisterScreenBody extends StatefulWidget {
  const RegisterScreenBody({super.key});

  @override
  State<RegisterScreenBody> createState() => _RegisterScreenBodyState();
}

class _RegisterScreenBodyState extends State<RegisterScreenBody> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is SignupSuccess) {
          Navigator.pushNamed(context, Routes.fillProfile);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0.w, vertical: 24.h),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SvgPicture.asset(
                    AppAssets.iconsLogo,
                    width: 66.w,
                    height: 66.h,
                  ),
                ),
                SizedBox(height: 16.h),
                const CustomHealthPal(),
                SizedBox(height: 25.h),
                Text('Create Account', style: AppTextStyles.inter20W600),
                SizedBox(height: 16.h),
                Text(
                  'We are here to help you!',
                  style: AppTextStyles.inter14W400.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
                SizedBox(height: 24.h),
                AuthTextField(
                  controller: nameController,
                  hintText: 'Your Name',
                  prefixIcon: SvgPicture.asset(AppAssets.iconsUser),
                  validator: ValidatorApp.validateName,
                ),
                SizedBox(height: 12.h),
                AuthTextField(
                  controller: emailController,
                  hintText: 'Your Email',
                  prefixIcon: SvgPicture.asset(AppAssets.iconsEmail),
                  validator: ValidatorApp.validateEmail,
                ),
                SizedBox(height: 12.h),
                AuthTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  prefixIcon: SvgPicture.asset(AppAssets.iconsPassword),
                  obscureText: obscurePassword,
                  validator: ValidatorApp.validatePassword,
                  suffixIcon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.gray400,
                    size: 18.sp,
                  ),
                  onSuffixPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
                SizedBox(height: 24.h),
                state is AuthLoading
                    ? const CircularProgressIndicator()
                    : AppButton(
                        text: 'Create Account',
                        backgroundColor: Colors.black,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthCubit>().signupUser(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text,
                            );
                          }
                        },
                      ),
                SizedBox(height: 24.h),
                const OrWidget(),
                SocialAuthButtons(
                  icon: AppAssets.iconsGoogle,
                  text: LocaleKeys.SignInWithGoogle,
                  onPressed: () {},
                ),
                SizedBox(height: 16.h),
                SocialAuthButtons(
                  icon: AppAssets.iconsFacebook,
                  text: LocaleKeys.SignInWithFacebook,
                  onPressed: () {},
                ),
                SizedBox(height: 12.h),
                const HaveAnAccountWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
