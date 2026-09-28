import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/usecases/add_banner.dart';
import 'package:medical_app/features/home/domain/usecases/update_banner.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_banner_button.dart';
import 'package:medical_app/features/admin/presentation/widgets/banner_description_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/banner_header_section.dart';
import 'package:medical_app/features/admin/presentation/widgets/banner_image_name_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/banner_title_field.dart';

class AddBannerScreen extends StatefulWidget {
  final BannerEntity? initialBanner;
  final AddBanner? addBanner;
  final UpdateBanner? updateBanner;

  const AddBannerScreen({
    super.key,
    this.initialBanner,
    this.addBanner,
    this.updateBanner,
  });

  @override
  State<AddBannerScreen> createState() => _AddBannerScreenState();
}

class _AddBannerScreenState extends State<AddBannerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageNameController;
  late final AddBanner? _addBannerUseCase;
  late final UpdateBanner? _updateBannerUseCase;
  bool _isLoading = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  bool get isEditMode => widget.initialBanner != null;

  @override
  void initState() {
    super.initState();
    final banner = widget.initialBanner;
    _titleController = TextEditingController(text: banner?.title ?? '');
    _descriptionController =
        TextEditingController(text: banner?.description ?? '');

    String initialImageName = '';
    if (banner != null && banner.imagePath.isNotEmpty) {
      final path = banner.imagePath;
      initialImageName = path.startsWith('assets/images/')
          ? path.substring('assets/images/'.length)
          : path;
    }
    _imageNameController = TextEditingController(text: initialImageName);

    _addBannerUseCase = widget.addBanner ??
        (getIt.isRegistered<AddBanner>() ? getIt<AddBanner>() : null);
    _updateBannerUseCase = widget.updateBanner ??
        (getIt.isRegistered<UpdateBanner>() ? getIt<UpdateBanner>() : null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageNameController.dispose();
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

    final trimmedName = _imageNameController.text.trim();
    final cleanName = trimmedName.startsWith('assets/images/')
        ? trimmedName.substring('assets/images/'.length)
        : trimmedName;
    final imagePath = 'assets/images/$cleanName';

    final Result<void> result;
    if (isEditMode) {
      final updateUseCase = _updateBannerUseCase ??
          (getIt.isRegistered<UpdateBanner>() ? getIt<UpdateBanner>() : null);
      if (updateUseCase == null) {
        setState(() => _isLoading = false);
        return;
      }
      result = await updateUseCase(
        BannerEntity(
          id: widget.initialBanner!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imagePath: imagePath,
          createdAt: widget.initialBanner!.createdAt,
        ),
      );
    } else {
      final addUseCase = _addBannerUseCase ??
          (getIt.isRegistered<AddBanner>() ? getIt<AddBanner>() : null);
      if (addUseCase == null) {
        setState(() => _isLoading = false);
        return;
      }
      result = await addUseCase(
        BannerEntity(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          imagePath: imagePath,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    switch (result) {
      case SuccessAPI():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? LocaleKeys.bannerUpdatedSuccessfully.tr()
                  : LocaleKeys.bannerAddedSuccessfully.tr(),
            ),
            backgroundColor: AppColors.lightTeal,
          ),
        );
        Navigator.pop(context);
      case ErrorAPI():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? LocaleKeys.failedToUpdateBanner.tr()
                  : LocaleKeys.failedToAddBanner.tr(),
            ),
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
          isEditMode ? LocaleKeys.editBanner.tr() : LocaleKeys.addBanner.tr(),
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
                BannerHeaderSection(
                  title: isEditMode ? LocaleKeys.editBanner.tr() : null,
                  subtitle: isEditMode
                      ? LocaleKeys.editBannerInformation.tr()
                      : null,
                ),
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
                BannerImageNameField(
                  controller: _imageNameController,
                  validator: ValidatorApp.validateImageName,
                ),
                SizedBox(height: 36.h),
                AddBannerButton(
                  isLoading: _isLoading,
                  text: isEditMode
                      ? LocaleKeys.updateBanner.tr()
                      : LocaleKeys.addBanner.tr(),
                  icon: isEditMode
                      ? Icons.check_circle_outline_rounded
                      : Icons.add_circle_outline_rounded,
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
