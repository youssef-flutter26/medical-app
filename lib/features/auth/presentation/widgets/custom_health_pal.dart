import 'package:flutter/material.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class CustomHealthPal extends StatelessWidget {
  const CustomHealthPal({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Health',
          style: AppTextStyles.inter14W400.copyWith(color: Colors.black45),
        ),
        Text(
          'Pal',
          style: AppTextStyles.inter14W400.copyWith(color: Colors.black),
        ),
      ],
    );
  }
}
