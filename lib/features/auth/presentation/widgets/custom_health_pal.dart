import 'package:flutter/material.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class CustomHealthPal extends StatelessWidget {
  const CustomHealthPal({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        textDirection: TextDirection.ltr,
        children: [
          Text(
            'Health',
            textDirection: TextDirection.ltr,
            style: AppTextStyles.inter14W400.copyWith(color: Colors.black45),
          ),
          Text(
            'Pal',
            textDirection: TextDirection.ltr,
            style: AppTextStyles.inter14W400.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
