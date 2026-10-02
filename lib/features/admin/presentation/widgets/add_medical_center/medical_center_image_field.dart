import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_form_field.dart';

class MedicalCenterImageField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const MedicalCenterImageField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalCenterFormField(
      key: const Key('medical_center_image_name_field'),
      inputKey: const Key('medical_center_image_name_input'),
      label: LocaleKeys.imageName.tr(),
      hintText: LocaleKeys.imageNameHint.tr(),
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
