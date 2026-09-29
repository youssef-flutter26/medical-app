import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_compact_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_rating_stars.dart';

class MedicalCenterRatingField extends StatelessWidget {
  final TextEditingController controller;
  final double rating;
  final ValueChanged<double>? onRatingChanged;
  final String? Function(String?)? validator;

  const MedicalCenterRatingField({
    super.key,
    required this.controller,
    required this.rating,
    this.onRatingChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalCenterCompactField(
      key: const Key('medical_center_rating_field'),
      inputKey: const Key('medical_center_rating_input'),
      label: LocaleKeys.rating.tr(),
      hintText: LocaleKeys.ratingHint.tr(),
      controller: controller,
      width: 72.w,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator ?? ValidatorApp.validateRating,
      unitWidget: MedicalCenterRatingStars(
        rating: rating,
        onRatingChanged: onRatingChanged,
      ),
    );
  }
}
