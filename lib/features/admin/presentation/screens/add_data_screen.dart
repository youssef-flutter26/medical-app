import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/admin/presentation/widgets/admin_option_card.dart';

class AddDataScreen extends StatelessWidget {
  const AddDataScreen({super.key});

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
          'What do you want to add?',
          style: AppTextStyles.inter16W500,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              AdminOptionCard(
                title: 'Banner',
                icon: Icons.view_carousel_outlined,
                onTap: () {
                  Navigator.pushNamed(context, Routes.addBanner);
                },
              ),
              SizedBox(height: 16.h),
              AdminOptionCard(
                title: 'Category',
                icon: Icons.category_outlined,
                onTap: () {
                  Navigator.pushNamed(context, Routes.addCategory);
                },
              ),
              SizedBox(height: 16.h),
              AdminOptionCard(
                title: 'Medical Center',
                icon: Icons.local_hospital_outlined,
                onTap: () {
                  Navigator.pushNamed(context, Routes.addMedicalCenter);
                },
              ),
              SizedBox(height: 16.h),
              AdminOptionCard(
                title: 'Doctor',
                icon: Icons.person_outline,
                onTap: () {
                  Navigator.pushNamed(context, Routes.addDoctor);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
