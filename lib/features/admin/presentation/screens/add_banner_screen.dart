import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/common/widgets/app_button.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

class AddBannerScreen extends StatefulWidget {
  const AddBannerScreen({super.key});

  @override
  State<AddBannerScreen> createState() => _AddBannerScreenState();
}

class _AddBannerScreenState extends State<AddBannerScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
          'Add Banner',
          style: AppTextStyles.inter16W500,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title',
                style: AppTextStyles.withColor(
                  AppTextStyles.inter14W500,
                  AppColors.gray700,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _titleController,
                style: AppTextStyles.withColor(
                  AppTextStyles.inter14W400,
                  AppColors.gray700,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter banner title',
                  hintStyle: AppTextStyles.withColor(
                    AppTextStyles.inter14W400,
                    AppColors.gray400,
                  ),
                  filled: true,
                  fillColor: AppColors.gray100,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: AppColors.lightTeal,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Description',
                style: AppTextStyles.withColor(
                  AppTextStyles.inter14W500,
                  AppColors.gray700,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                style: AppTextStyles.withColor(
                  AppTextStyles.inter14W400,
                  AppColors.gray700,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter banner description',
                  hintStyle: AppTextStyles.withColor(
                    AppTextStyles.inter14W400,
                    AppColors.gray400,
                  ),
                  filled: true,
                  fillColor: AppColors.gray100,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: AppColors.lightTeal,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Banner Image',
                style: AppTextStyles.withColor(
                  AppTextStyles.inter14W500,
                  AppColors.gray700,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.gray400.withValues(alpha: 0.4),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () {
                      // UI interaction placeholder
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 28.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 38.sp,
                            color: AppColors.lightTeal,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'Choose Image',
                            style: AppTextStyles.withColor(
                              AppTextStyles.inter14W500,
                              AppColors.lightTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 36.h),
              AppButton(
                text: 'Add Banner',
                onPressed: () {
                  // UI interaction placeholder
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
