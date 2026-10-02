import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_category/add_category_button.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_category/category_image_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_category/category_name_field.dart';

class AddCategoryPage extends StatefulWidget {
  final Future<void> Function(String name, String imageName)? onSubmit;

  const AddCategoryPage({
    super.key,
    this.onSubmit,
  });

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _imageNameController;

  bool _isLoading = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _imageNameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageNameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autoValidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final trimmedName = _imageNameController.text.trim();
    final cleanImageName = trimmedName.startsWith('assets/images/')
        ? trimmedName.substring('assets/images/'.length)
        : trimmedName;

    if (widget.onSubmit != null) {
      await widget.onSubmit!(_nameController.text.trim(), cleanImageName);
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          LocaleKeys.categoryAddedSuccessfully.tr(),
          style: AppTextStyles.withColor(
            AppTextStyles.inter14W500,
            AppColors.white,
          ),
        ),
        backgroundColor: AppColors.darkTeal,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
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
          LocaleKeys.addCategory.tr(),
          style: AppTextStyles.inter16W500,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.categoryDetails.tr(),
                  style: AppTextStyles.withColor(
                    AppTextStyles.inter20W600,
                    AppColors.darkTeal,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  LocaleKeys.addCategoryInformation.tr(),
                  style: AppTextStyles.withColor(
                    AppTextStyles.inter14W400,
                    AppColors.gray500,
                  ),
                ),
                SizedBox(height: 24.h),
                CategoryNameField(
                  controller: _nameController,
                ),
                SizedBox(height: 18.h),
                CategoryImageField(
                  controller: _imageNameController,
                ),
                SizedBox(height: 32.h),
                AddCategoryButton(
                  isLoading: _isLoading,
                  onPressed: _saveCategory,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

typedef AddCategoryScreen = AddCategoryPage;
