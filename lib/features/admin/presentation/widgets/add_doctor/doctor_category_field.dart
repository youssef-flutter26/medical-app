import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';

class DoctorCategoryField extends StatelessWidget {
  final List<CategoryEntity>? categories;
  final bool isLoading;
  final String? errorMessage;
  final CategoryEntity? selectedCategory;
  final ValueChanged<CategoryEntity?> onChanged;
  final FormFieldValidator<CategoryEntity>? validator;
  final Key? dropdownKey;

  const DoctorCategoryField({
    super.key,
    required this.categories,
    this.isLoading = false,
    this.errorMessage,
    required this.selectedCategory,
    required this.onChanged,
    this.validator,
    this.dropdownKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.category.tr(),
          style: AppTextStyles.withColor(
            AppTextStyles.inter14W500,
            AppColors.gray700,
          ),
        ),
        SizedBox(height: 8.h),
        _buildContent(context),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return _buildErrorState(errorMessage!);
    }

    final catList = categories ?? [];
    if (catList.isEmpty) {
      return _buildEmptyState();
    }

    CategoryEntity? currentValue;
    if (selectedCategory != null) {
      final match = catList.where(
        (c) =>
            (c.id != null && c.id == selectedCategory!.id) ||
            c.name == selectedCategory!.name,
      );
      if (match.isNotEmpty) {
        currentValue = match.first;
      }
    }

    return DropdownButtonFormField<CategoryEntity>(
      key: dropdownKey ?? const Key('doctor_category_dropdown'),
      // ignore: deprecated_member_use
      value: currentValue,
      validator: validator ??
          (value) {
            if (value == null) {
              return LocaleKeys.categoryCannotBeEmpty.tr();
            }
            return null;
          },
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.gray500,
      ),
      elevation: 3,
      menuMaxHeight: 300.h,
      dropdownColor: AppColors.white,
      borderRadius: BorderRadius.circular(16.r),
      style: AppTextStyles.withColor(
        AppTextStyles.inter14W500,
        AppColors.darkTeal,
      ),
      decoration: InputDecoration(
        hintText: LocaleKeys.selectCategory.tr(),
        hintStyle: AppTextStyles.withColor(
          AppTextStyles.inter14W400,
          AppColors.gray400,
        ),
        prefixIcon: const Icon(
          Icons.category_outlined,
          color: AppColors.gray500,
          size: 20,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: AppColors.red,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: AppColors.red,
            width: 1.5,
          ),
        ),
      ),
      items: catList.map((cat) {
        final isSelected =
            (currentValue?.id != null && currentValue!.id == cat.id) ||
                currentValue?.name == cat.name;

        return DropdownMenuItem<CategoryEntity>(
          value: cat,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30.r,
                  height: 30.r,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.lightTeal.withValues(alpha: 0.15)
                        : AppColors.gray400.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.medical_services_rounded,
                      size: 16.r,
                      color: isSelected
                          ? AppColors.lightTeal
                          : AppColors.gray500,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  cat.name,
                  style: AppTextStyles.withColor(
                    isSelected
                        ? AppTextStyles.inter14W500
                        : AppTextStyles.inter14W400,
                    isSelected ? AppColors.darkTeal : AppColors.gray700,
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18.r,
                    color: AppColors.lightTeal,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.gray400.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18.r,
            height: 18.r,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightTeal),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            LocaleKeys.selectCategory.tr(),
            style: AppTextStyles.withColor(
              AppTextStyles.inter14W400,
              AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      key: const Key('doctor_category_empty_warning'),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.amber.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.amber,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.noCategoriesAvailable.tr(),
                  style: AppTextStyles.withColor(
                    AppTextStyles.inter14W500,
                    AppColors.amber,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  LocaleKeys.pleaseAddCategoryFirst.tr(),
                  style: AppTextStyles.withColor(
                    AppTextStyles.inter12W400,
                    AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.red,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              error,
              style: AppTextStyles.withColor(
                AppTextStyles.inter12W400,
                AppColors.red,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
