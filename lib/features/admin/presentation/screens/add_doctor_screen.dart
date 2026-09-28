import 'package:flutter/material.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class AddDoctorScreen extends StatelessWidget {
  const AddDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Doctor',
          style: AppTextStyles.inter16W500,
        ),
      ),
      body: const SafeArea(
        child: Center(
          child: Text(
            'Add Doctor',
            style: AppTextStyles.inter14W400,
          ),
        ),
      ),
    );
  }
}
