import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'doctor_form_field.dart';

class DoctorReviewsField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const DoctorReviewsField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DoctorFormField(
      inputKey: const Key('doctor_reviews_count_input'),
      label: LocaleKeys.reviewsCount.tr(),
      hintText: LocaleKeys.reviewsCountHint.tr(),
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator ?? ValidatorApp.validateReviewsCount,
      prefixIcon: const Icon(
        Icons.rate_review_outlined,
        color: AppColors.gray500,
        size: 20,
      ),
    );
  }
}
