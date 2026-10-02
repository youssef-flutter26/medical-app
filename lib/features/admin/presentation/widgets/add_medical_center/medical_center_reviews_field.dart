import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_compact_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_unit_badge.dart';

class MedicalCenterReviewsField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const MedicalCenterReviewsField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalCenterCompactField(
      key: const Key('medical_center_reviews_count_field'),
      inputKey: const Key('medical_center_reviews_count_input'),
      label: LocaleKeys.reviewsCount.tr(),
      hintText: LocaleKeys.reviewsCountHint.tr(),
      controller: controller,
      width: 78.w,
      keyboardType: TextInputType.number,
      validator: validator ?? ValidatorApp.validateReviewsCount,
      unitWidget: MedicalCenterUnitBadge(
        text: LocaleKeys.reviews.tr(),
      ),
    );
  }
}
