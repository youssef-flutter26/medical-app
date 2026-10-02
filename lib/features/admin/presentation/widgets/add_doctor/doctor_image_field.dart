import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'doctor_form_field.dart';

class DoctorImageField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const DoctorImageField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DoctorFormField(
      inputKey: const Key('doctor_image_name_input'),
      label: LocaleKeys.imageName.tr(),
      hintText: LocaleKeys.doctorImageHint.tr(),
      controller: controller,
      validator: validator ?? ValidatorApp.validateImageName,
      prefixIcon: const Icon(
        Icons.image_outlined,
        color: AppColors.gray500,
        size: 20,
      ),
    );
  }
}
