import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon, // أصبح اختياري بدون required
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixPressed,
  });

  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixPressed;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      style: AppTextStyles.withColor(
        AppTextStyles.inter14W400,
        AppColors.gray700,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.withColor(
          AppTextStyles.inter14W400,
          AppColors.gray400,
        ),
        // فحص إذا كان الـ prefixIcon ممرر أم لا
        prefixIcon: prefixIcon == null
            ? null
            : Padding(padding: EdgeInsets.all(14.w), child: prefixIcon),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(onPressed: onSuffixPressed, icon: suffixIcon!),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.gray400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.gray400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.primary600),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
