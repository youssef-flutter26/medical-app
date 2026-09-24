import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/features/auth/presentation/widgets/social_auth_button.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/validators/validator_app.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    debugPrint('SIGN IN PRESSED');

    if (!_formKey.currentState!.validate()) {
      debugPrint('VALIDATION FAILED');
      return;
    }

    debugPrint('VALIDATION PASSED');

    context.read<AuthCubit>().loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          debugPrint('AUTH STATE: ${state.runtimeType}');

          if (state case AuthFailure(:final message)) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }

          if (state is LoginSuccess) {
            debugPrint('LOGIN SUCCESS');
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    // =========================
                    // Logo Section
                    // =========================
                    SizedBox(
                      width: double.infinity,
                      height: 107.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          SvgPicture.asset(
                            AppAssets.iconsLogo,
                            width: 48.w,
                            height: 48.h,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            LocaleKeys.healthPal,
                            style: AppTextStyles.withColor(
                              AppTextStyles.inter14W400,
                              AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =========================
                    // Main Content
                    // =========================
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 28.h),

                              // =========================
                              // Welcome Text
                              // =========================
                              Text(
                                LocaleKeys.HiWelcomeBack,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.withColor(
                                  AppTextStyles.inter16W500,
                                  AppColors.darkTeal,
                                ),
                              ),

                              SizedBox(height: 4.h),

                              Text(
                                LocaleKeys.HopeYouAreDoingFine,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.withColor(
                                  AppTextStyles.inter10W400,
                                  AppColors.gray500,
                                ),
                              ),

                              SizedBox(height: 23.h),

                              // =========================
                              // Email
                              // =========================
                              AuthTextField(
                                controller: _emailController,
                                hintText: LocaleKeys.yourEmail,
                                prefixIcon: SvgPicture.asset(
                                  AppAssets.iconsEmail,
                                ),
                                validator: ValidatorApp.validateEmail,
                              ),

                              SizedBox(height: 10.h),

                              // =========================
                              // Password
                              // =========================
                              AuthTextField(
                                controller: _passwordController,
                                hintText: LocaleKeys.password,
                                prefixIcon: SvgPicture.asset(
                                  AppAssets.iconsPassword,
                                ),
                                obscureText: _obscurePassword,
                                validator: ValidatorApp.validatePassword,
                                suffixIcon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.gray400,
                                  size: 18.sp,
                                ),
                                onSuffixPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),

                              SizedBox(height: 12.h),

                              // =========================
                              // Sign In Button
                              // =========================
                              SizedBox(
                                width: double.infinity,
                                height: 34.h,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _login(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.darkTeal,
                                    foregroundColor: AppColors.white,
                                    disabledBackgroundColor: AppColors.darkTeal,
                                    disabledForegroundColor: AppColors.white,
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.r),
                                    ),
                                  ),
                                  child: isLoading
                                      ? SizedBox(
                                          width: 18.w,
                                          height: 18.w,
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.white,
                                              ),
                                        )
                                      : Text(
                                          LocaleKeys.signIn,
                                          style: AppTextStyles.withColor(
                                            AppTextStyles.inter12W500,
                                            AppColors.white,
                                          ),
                                        ),
                                ),
                              ),

                              SizedBox(height: 23.h),

                              // =========================
                              // Or
                              // =========================
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.gray400.withOpacity(
                                        0.35,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                    ),
                                    child: Text(
                                      LocaleKeys.or,
                                      style: AppTextStyles.withColor(
                                        AppTextStyles.inter10W400,
                                        AppColors.gray500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.gray400.withOpacity(
                                        0.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.h),

                              // =========================
                              // Social Buttons
                              // =========================
                              SizedBox(
                                width: double.infinity,
                                height: 98.h,
                                child: Column(
                                  children: [
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
                                  ],
                                ),
                              ),

                              SizedBox(height: 16.h),

                              // =========================
                              // Forgot Password
                              // =========================
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  LocaleKeys.forgotPassword,
                                  style: AppTextStyles.withColor(
                                    AppTextStyles.inter10W500,
                                    AppColors.primary600,
                                  ),
                                ),
                              ),

                              SizedBox(height: 16.h),

                              // =========================
                              // Sign Up
                              // =========================
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    Routes.register,
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: LocaleKeys.DontHaveAnAccountYet,
                                    style: AppTextStyles.withColor(
                                      AppTextStyles.inter10W400,
                                      AppColors.gray500,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ' ${LocaleKeys.signUp}',
                                        style: AppTextStyles.withColor(
                                          AppTextStyles.inter10W500,
                                          AppColors.primary600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Remaining space stays at the bottom.
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
