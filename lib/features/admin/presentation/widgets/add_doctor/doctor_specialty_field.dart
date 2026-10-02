import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'doctor_form_field.dart';

class DoctorSpecialtyField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const DoctorSpecialtyField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DoctorFormField(
      inputKey: const Key('doctor_specialty_input'),
      label: LocaleKeys.specialty.tr(),
      hintText: LocaleKeys.enterSpecialty.tr(),
      controller: controller,
      validator: validator ?? ValidatorApp.validateSpecialty,
      prefixIcon: const Icon(
        Icons.medical_services_outlined,
        color: AppColors.gray500,
        size: 20,
      ),
    );
  }
}
