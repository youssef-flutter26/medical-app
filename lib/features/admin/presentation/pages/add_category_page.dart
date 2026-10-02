import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/domain/usecases/add_category.dart';
import 'package:medical_app/features/home/domain/usecases/update_category.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_category/add_category_button.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_category/category_image_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_category/category_name_field.dart';

class AddCategoryPage extends StatefulWidget {
  final Future<void> Function(String name, String imageName)? onSubmit;
  final CategoryEntity? initialCategory;
  final AddCategory? addCategory;
  final UpdateCategory? updateCategory;

  const AddCategoryPage({
    super.key,
    this.onSubmit,
    this.initialCategory,
    this.addCategory,
    this.updateCategory,
  });

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _imageNameController;
  late final AddCategory? _addCategoryUseCase;
  late final UpdateCategory? _updateCategoryUseCase;

  bool _isLoading = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  bool get isEditMode => widget.initialCategory != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCategory;
    _nameController = TextEditingController(text: initial?.name ?? '');

    String initialImageName = '';
    if (initial != null && initial.imagePath.isNotEmpty) {
      final path = initial.imagePath;
      initialImageName = path.startsWith('assets/images/')
          ? path.substring('assets/images/'.length)
          : path;
    }
    _imageNameController = TextEditingController(text: initialImageName);

    _addCategoryUseCase = widget.addCategory ??
        (getIt.isRegistered<AddCategory>() ? getIt<AddCategory>() : null);
    _updateCategoryUseCase = widget.updateCategory ??
        (getIt.isRegistered<UpdateCategory>() ? getIt<UpdateCategory>() : null);
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

    final categoryName = _nameController.text.trim();
    if (widget.onSubmit != null) {
      await widget.onSubmit!(categoryName, cleanImageName);
    } else {
      final imagePath = cleanImageName.isNotEmpty
          ? 'assets/images/$cleanImageName'
          : '';
      if (isEditMode) {
        final updateUseCase = _updateCategoryUseCase ??
            (getIt.isRegistered<UpdateCategory>()
                ? getIt<UpdateCategory>()
                : null);
        if (updateUseCase != null) {
          final res = await updateUseCase(
            CategoryEntity(
              id: widget.initialCategory!.id,
              name: categoryName,
              imagePath: imagePath,
              createdAt: widget.initialCategory!.createdAt,
            ),
          );
          if (res is ErrorAPI) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  LocaleKeys.failedToUpdateCategory.tr(),
                  style: AppTextStyles.withColor(
                    AppTextStyles.inter14W500,
                    AppColors.white,
                  ),
                ),
                backgroundColor: AppColors.red,
              ),
            );
            return;
          }
        }
      } else {
        final addUseCase = _addCategoryUseCase ??
            (getIt.isRegistered<AddCategory>() ? getIt<AddCategory>() : null);
        if (addUseCase != null) {
          final res = await addUseCase(
            CategoryEntity(
              name: categoryName,
              imagePath: imagePath,
              createdAt: DateTime.now(),
            ),
          );
          if (res is ErrorAPI) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  LocaleKeys.failedToAddCategory.tr(),
                  style: AppTextStyles.withColor(
                    AppTextStyles.inter14W500,
                    AppColors.white,
                  ),
                ),
                backgroundColor: AppColors.red,
              ),
            );
            return;
          }
        }
      }
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditMode
              ? LocaleKeys.categoryUpdatedSuccessfully.tr()
              : LocaleKeys.categoryAddedSuccessfully.tr(),
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
          isEditMode
              ? LocaleKeys.editCategory.tr()
              : LocaleKeys.addCategory.tr(),
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
                  isEditMode
                      ? LocaleKeys.editCategory.tr()
                      : LocaleKeys.categoryDetails.tr(),
                  style: AppTextStyles.withColor(
                    AppTextStyles.inter20W600,
                    AppColors.darkTeal,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isEditMode
                      ? LocaleKeys.editCategoryInformation.tr()
                      : LocaleKeys.addCategoryInformation.tr(),
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
                  text: isEditMode
                      ? LocaleKeys.updateCategory.tr()
                      : LocaleKeys.addCategory.tr(),
                  icon: isEditMode
                      ? Icons.check_circle_outline_rounded
                      : Icons.add_circle_outline_rounded,
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
