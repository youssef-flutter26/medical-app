import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class MedicalCenterCompactField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Key? inputKey;
  final double width;
  final Widget? unitWidget;
  final ValueChanged<String>? onChanged;

  const MedicalCenterCompactField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.width,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputKey,
    this.unitWidget,
    this.onChanged,
  });

  @override
  State<MedicalCenterCompactField> createState() =>
      _MedicalCenterCompactFieldState();
}

class _MedicalCenterCompactFieldState extends State<MedicalCenterCompactField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(covariant MedicalCenterCompactField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      widget.controller.addListener(_handleControllerChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _handleControllerChange() {
    if (_fieldKey.currentState != null &&
        _fieldKey.currentState!.value != widget.controller.text) {
      _fieldKey.currentState!.didChange(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _fieldKey,
      initialValue: widget.controller.text,
      validator: (_) => widget.validator?.call(widget.controller.text),
      builder: (FormFieldState<String> fieldState) {
        final bool hasError = fieldState.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: AppTextStyles.withColor(
                AppTextStyles.inter14W500,
                AppColors.gray700,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: widget.width,
                  child: TextFormField(
                    key: widget.inputKey,
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.withColor(
                      AppTextStyles.inter14W500,
                      AppColors.darkTeal,
                    ),
                    onChanged: (val) {
                      fieldState.didChange(val);
                      widget.onChanged?.call(val);
                    },
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: AppTextStyles.withColor(
                        AppTextStyles.inter14W400,
                        AppColors.gray400,
                      ),
                      filled: true,
                      fillColor: AppColors.gray100,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 12.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: hasError
                              ? AppColors.red
                              : AppColors.gray400.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: hasError
                              ? AppColors.red
                              : AppColors.gray400.withValues(alpha: 0.2),
                          width: hasError ? 1.5 : 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: hasError ? AppColors.red : AppColors.lightTeal,
                          width: 1.5,
                        ),
                      ),
                      errorStyle: const TextStyle(
                        height: 0,
                        fontSize: 0,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                if (widget.unitWidget != null) ...[
                  SizedBox(width: 8.w),
                  widget.unitWidget!,
                ],
              ],
            ),
            if (hasError) ...[
              SizedBox(height: 4.h),
              Text(
                fieldState.errorText ?? '',
                style: AppTextStyles.withColor(
                  AppTextStyles.inter12W400,
                  AppColors.red,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
