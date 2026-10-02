import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_compact_field.dart';

class MedicalCenterDistanceField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const MedicalCenterDistanceField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalCenterCompactField(
      key: const Key('medical_center_distance_field'),
      inputKey: const Key('medical_center_distance_input'),
      label: LocaleKeys.distance.tr(),
      hintText: LocaleKeys.distanceHint.tr(),
      controller: controller,
      width: 68.w,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator ?? ValidatorApp.validateDistance,
      unitText: LocaleKeys.km.tr(),
    );
  }
}
