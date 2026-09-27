import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/validators/validator_app.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthCubit>().sendPasswordResetEmail(
      email: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetEmailSent) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  title: Text(
                    'Check Your Email',
                    style: AppTextStyles.inter16W500,
                  ),
                  content: Text(
                    'We sent a password reset link to your email address. '
                    'Open the link from your email to create a new password.',
                    style: AppTextStyles.inter14W400.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'OK',
                        style: AppTextStyles.inter12W500.copyWith(
                          color: AppColors.primary600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }

          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: AppColors.white,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        Navigator.pop(context);
                                      },
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 22.sp,
                                  color: AppColors.gray700,
                                ),
                              ),
                            ),

                            SizedBox(height: 20.h),

                            SvgPicture.asset(
                              AppAssets.iconsLogo,
                              width: 52.w,
                              height: 70.h,
                            ),

                            SizedBox(height: 8.h),

                            Text(
                              LocaleKeys.healthPal,
                              style: AppTextStyles.withColor(
                                AppTextStyles.inter14W400,
                                AppColors.gray500,
                              ),
                            ),

                            SizedBox(height: 24.h),

                            Text(
                              'Forgot Password?',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.inter16W500.copyWith(
                                color: AppColors.gray700,
                              ),
                            ),

                            SizedBox(height: 8.h),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.w),
                              child: Text(
                                'Enter your Email, we will send you a password reset link.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.inter10W400.copyWith(
                                  color: AppColors.gray500,
                                  height: 1.5,
                                ),
                              ),
                            ),

                            SizedBox(height: 24.h),

                            AuthTextField(
                              controller: _emailController,
                              hintText: LocaleKeys.yourEmail,
                              prefixIcon: SvgPicture.asset(
                                AppAssets.iconsEmail,
                              ),
                              validator: ValidatorApp.validateEmail,
                            ),

                            SizedBox(height: 20.h),

                            SizedBox(
                              width: double.infinity,
                              height: 40.h,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        _sendResetLink(context);
                                      },
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
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.white,
                                        ),
                                      )
                                    : Text(
                                        'Send Reset Link',
                                        style: AppTextStyles.withColor(
                                          AppTextStyles.inter12W500,
                                          AppColors.white,
                                        ),
                                      ),
                              ),
                            ),

                            SizedBox(height: 30.h),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
