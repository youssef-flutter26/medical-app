import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'doctor_form_field.dart';

class DoctorAboutField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const DoctorAboutField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DoctorFormField(
      inputKey: const Key('doctor_about_input'),
      label: LocaleKeys.aboutDoctor.tr(),
      hintText: LocaleKeys.enterAboutDoctor.tr(),
      controller: controller,
      maxLines: 4,
      keyboardType: TextInputType.multiline,
      validator: validator ?? ValidatorApp.validateAboutDoctor,
      prefixIcon: const Padding(
        padding: EdgeInsets.only(bottom: 56),
        child: Icon(
          Icons.notes_rounded,
          color: AppColors.gray500,
          size: 20,
        ),
      ),
    );
  }
}
