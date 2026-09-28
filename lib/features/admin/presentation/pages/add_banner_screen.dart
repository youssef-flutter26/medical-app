import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
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
  bool _isImagePressed = false;
  bool _isButtonPressed = false;

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
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocaleKeys.addBanner.tr(),
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
                LocaleKeys.bannerDetails.tr(),
                style: AppTextStyles.withColor(
                  AppTextStyles.inter20W600,
                  AppColors.darkTeal,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                LocaleKeys.addBannerInformation.tr(),
                style: AppTextStyles.withColor(
                  AppTextStyles.inter14W400,
                  AppColors.gray500,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                LocaleKeys.bannerTitle.tr(),
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
                  hintText: LocaleKeys.enterBannerTitle.tr(),
                  hintStyle: AppTextStyles.withColor(
                    AppTextStyles.inter14W400,
                    AppColors.gray400,
                  ),
                  filled: true,
                  fillColor: AppColors.gray100,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.gray400.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.gray400.withValues(alpha: 0.2),
                    ),
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
                LocaleKeys.description.tr(),
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
                  hintText: LocaleKeys.enterBannerDescription.tr(),
                  hintStyle: AppTextStyles.withColor(
                    AppTextStyles.inter14W400,
                    AppColors.gray400,
                  ),
                  filled: true,
                  fillColor: AppColors.gray100,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.gray400.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.gray400.withValues(alpha: 0.2),
                    ),
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
                LocaleKeys.bannerImage.tr(),
                style: AppTextStyles.withColor(
                  AppTextStyles.inter14W500,
                  AppColors.gray700,
                ),
              ),
              SizedBox(height: 8.h),
              AnimatedScale(
                scale: _isImagePressed ? 0.985 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: Container(
                  width: double.infinity,
                  height: 164.h,
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.gray400.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.r),
                      onHighlightChanged: (isHighlighted) {
                        setState(() {
                          _isImagePressed = isHighlighted;
                        });
                      },
                      onTap: () {
                        // Visual interaction placeholder
                      },
                      splashColor: AppColors.lightTeal.withValues(alpha: 0.1),
                      highlightColor: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 54.r,
                            height: 54.r,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkTeal.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 28.r,
                              color: AppColors.lightTeal,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            LocaleKeys.chooseImage.tr(),
                            style: AppTextStyles.withColor(
                              AppTextStyles.inter16W500,
                              AppColors.darkTeal,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            LocaleKeys.uploadBannerImage.tr(),
                            style: AppTextStyles.withColor(
                              AppTextStyles.inter12W500,
                              AppColors.gray500,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            LocaleKeys.imageFormatsHint.tr(),
                            style: AppTextStyles.withColor(
                              AppTextStyles.inter10W400,
                              AppColors.gray400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 36.h),
              AnimatedScale(
                scale: _isButtonPressed ? 0.97 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: Container(
                  width: double.infinity,
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: AppColors.darkTeal,
                    borderRadius: BorderRadius.circular(26.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkTeal.withValues(
                          alpha: _isButtonPressed ? 0.15 : 0.28,
                        ),
                        blurRadius: _isButtonPressed ? 6 : 14,
                        offset: Offset(0, _isButtonPressed ? 2 : 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onHighlightChanged: (isHighlighted) {
                        setState(() {
                          _isButtonPressed = isHighlighted;
                        });
                      },
                      onTap: () {
                        // UI interaction placeholder
                      },
                      borderRadius: BorderRadius.circular(26.r),
                      splashColor: AppColors.white.withValues(alpha: 0.15),
                      highlightColor: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.white,
                            size: 20.r,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            LocaleKeys.addBanner.tr(),
                            style: AppTextStyles.withColor(
                              AppTextStyles.inter16W500,
                              AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
