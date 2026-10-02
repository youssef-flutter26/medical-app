import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'doctor_form_field.dart';

class DoctorExperienceField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const DoctorExperienceField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DoctorFormField(
      inputKey: const Key('doctor_experience_input'),
      label: LocaleKeys.experience.tr(),
      hintText: LocaleKeys.enterExperience.tr(),
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator ?? ValidatorApp.validateExperience,
      prefixIcon: const Icon(
        Icons.work_outline_rounded,
        color: AppColors.gray500,
        size: 20,
      ),
    );
  }
}
