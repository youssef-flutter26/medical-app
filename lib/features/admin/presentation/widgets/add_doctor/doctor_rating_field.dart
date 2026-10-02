import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'doctor_form_field.dart';

class DoctorRatingField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const DoctorRatingField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DoctorFormField(
      inputKey: const Key('doctor_rating_input'),
      label: LocaleKeys.rating.tr(),
      hintText: LocaleKeys.ratingHint.tr(),
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*')),
      ],
      validator: validator ?? ValidatorApp.validateRating,
      prefixIcon: const Icon(
        Icons.star_rounded,
        color: Color(0xFFFBBF24),
        size: 20,
      ),
    );
  }
}
