import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'package:medical_app/features/admin/domain/entities/banner_entity.dart';
import 'package:medical_app/features/admin/domain/usecases/add_banner.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_banner_button.dart';
import 'package:medical_app/features/admin/presentation/widgets/banner_description_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/banner_header_section.dart';
import 'package:medical_app/features/admin/presentation/widgets/banner_image_url_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/banner_title_field.dart';

class AddBannerScreen extends StatefulWidget {
  final AddBanner? addBanner;

  const AddBannerScreen({super.key, this.addBanner});

  @override
  State<AddBannerScreen> createState() => _AddBannerScreenState();
}

class _AddBannerScreenState extends State<AddBannerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final AddBanner _addBannerUseCase;
  bool _isLoading = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _imageUrlController = TextEditingController();
    _addBannerUseCase = widget.addBanner ?? getIt<AddBanner>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveBanner() async {
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

    final result = await _addBannerUseCase(
      BannerEntity(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
      ),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    switch (result) {
      case SuccessAPI():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.bannerAddedSuccessfully.tr()),
            backgroundColor: AppColors.lightTeal,
          ),
        );
        Navigator.pop(context);
      case ErrorAPI():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.failedToAddBanner.tr()),
            backgroundColor: AppColors.red,
          ),
        );
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
          LocaleKeys.addBanner.tr(),
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
                const BannerHeaderSection(),
                SizedBox(height: 24.h),
                BannerTitleField(
                  controller: _titleController,
                  validator: ValidatorApp.validateTitle,
                ),
                SizedBox(height: 20.h),
                BannerDescriptionField(
                  controller: _descriptionController,
                  validator: ValidatorApp.validateDescription,
                ),
                SizedBox(height: 20.h),
                BannerImageUrlField(
                  controller: _imageUrlController,
                  validator: ValidatorApp.validateImageUrl,
                ),
                SizedBox(height: 36.h),
                AddBannerButton(
                  isLoading: _isLoading,
                  onPressed: _saveBanner,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
