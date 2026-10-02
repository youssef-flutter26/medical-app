import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'doctor_form_field.dart';

class DoctorNameField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const DoctorNameField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DoctorFormField(
      inputKey: const Key('doctor_name_input'),
      label: LocaleKeys.doctorName.tr(),
      hintText: LocaleKeys.enterDoctorName.tr(),
      controller: controller,
      validator: validator ?? ValidatorApp.validateDoctorName,
      prefixIcon: const Icon(
        Icons.person_outline_rounded,
        color: AppColors.gray500,
        size: 20,
      ),
    );
  }
}
