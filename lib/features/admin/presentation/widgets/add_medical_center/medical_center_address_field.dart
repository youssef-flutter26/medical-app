import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_form_field.dart';

class MedicalCenterAddressField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const MedicalCenterAddressField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalCenterFormField(
      key: const Key('medical_center_address_field'),
      inputKey: const Key('medical_center_address_input'),
      label: LocaleKeys.address.tr(),
      hintText: LocaleKeys.enterAddress.tr(),
      controller: controller,
      validator: validator ?? ValidatorApp.validateAddress,
      prefixIcon: const Icon(
        Icons.location_on_outlined,
        color: AppColors.gray500,
        size: 20,
      ),
    );
  }
}
