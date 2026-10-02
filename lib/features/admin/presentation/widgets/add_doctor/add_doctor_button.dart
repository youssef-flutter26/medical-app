import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class AddDoctorButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final String? text;
  final IconData? icon;

  const AddDoctorButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.text,
    this.icon,
  });

  @override
  State<AddDoctorButton> createState() => _AddDoctorButtonState();
}

class _AddDoctorButtonState extends State<AddDoctorButton> {
  bool _isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled =
        widget.isLoading || !widget.isEnabled || widget.onPressed == null;

    final bgColor = isDisabled
        ? AppColors.darkTeal.withValues(alpha: 0.4)
        : AppColors.darkTeal;

    return AnimatedScale(
      scale: _isButtonPressed && !isDisabled ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(26.r),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: AppColors.darkTeal.withValues(
                      alpha: _isButtonPressed ? 0.15 : 0.28,
                    ),
                    blurRadius: _isButtonPressed ? 6 : 14,
                    offset: Offset(0, _isButtonPressed ? 2 : 5),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('add_doctor_submit_button'),
            onHighlightChanged: isDisabled
                ? null
                : (isHighlighted) {
                    setState(() {
                      _isButtonPressed = isHighlighted;
                    });
                  },
            onTap: isDisabled ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(26.r),
            splashColor: AppColors.white.withValues(alpha: 0.15),
            highlightColor: Colors.transparent,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.icon ?? Icons.add_circle_outline_rounded,
                          color: AppColors.white,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            widget.text ?? LocaleKeys.addDoctor.tr(),
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.withColor(
                              AppTextStyles.inter16W500,
                              AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
