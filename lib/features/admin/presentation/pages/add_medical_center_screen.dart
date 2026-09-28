import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/validators/validator_app.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center_button.dart';
import 'package:medical_app/features/admin/presentation/widgets/medical_center_form_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/medical_center_header_section.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/usecases/add_medical_center.dart';

class AddMedicalCenterScreen extends StatefulWidget {
  final AddMedicalCenter? addMedicalCenter;

  const AddMedicalCenterScreen({
    super.key,
    this.addMedicalCenter,
  });

  @override
  State<AddMedicalCenterScreen> createState() => _AddMedicalCenterScreenState();
}

class _AddMedicalCenterScreenState extends State<AddMedicalCenterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _ratingController;
  late final TextEditingController _reviewsCountController;
  late final TextEditingController _distanceController;
  late final TextEditingController _durationController;
  late final TextEditingController _imageNameController;
  late final AddMedicalCenter? _addMedicalCenterUseCase;

  String _selectedType = 'Hospital';
  bool _isLoading = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _ratingController = TextEditingController();
    _reviewsCountController = TextEditingController();
    _distanceController = TextEditingController();
    _durationController = TextEditingController();
    _imageNameController = TextEditingController();

    _addMedicalCenterUseCase = widget.addMedicalCenter ??
        (getIt.isRegistered<AddMedicalCenter>()
            ? getIt<AddMedicalCenter>()
            : null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _ratingController.dispose();
    _reviewsCountController.dispose();
    _distanceController.dispose();
    _durationController.dispose();
    _imageNameController.dispose();
    super.dispose();
  }

  Future<void> _saveMedicalCenter() async {
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

    final rating = double.parse(_ratingController.text.trim());
    final reviewsCount = int.parse(_reviewsCountController.text.trim());

    final addUseCase = _addMedicalCenterUseCase ??
        (getIt.isRegistered<AddMedicalCenter>()
            ? getIt<AddMedicalCenter>()
            : null);

    if (addUseCase == null) {
      setState(() => _isLoading = false);
      return;
    }

    final result = await addUseCase(
      MedicalCenterEntity(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        rating: rating,
        reviewsCount: reviewsCount,
        distance: _distanceController.text.trim(),
        duration: _durationController.text.trim(),
        type: _selectedType,
        imagePath: imagePath,
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
            content: Text(
              LocaleKeys.medicalCenterAddedSuccessfully.tr(),
            ),
            backgroundColor: AppColors.lightTeal,
          ),
        );
        Navigator.pop(context);
      case ErrorAPI():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocaleKeys.failedToAddMedicalCenter.tr(),
            ),
            backgroundColor: AppColors.red,
          ),
        );
    }
  }

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.type.tr(),
          style: AppTextStyles.withColor(
            AppTextStyles.inter14W500,
            AppColors.gray700,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          key: const Key('medical_center_type_dropdown'),
          initialValue: _selectedType,
          dropdownColor: AppColors.white,
          style: AppTextStyles.withColor(
            AppTextStyles.inter14W400,
            AppColors.gray700,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.gray500,
          ),
          items: [
            DropdownMenuItem(
              value: 'Hospital',
              child: Text(LocaleKeys.hospital.tr()),
            ),
            DropdownMenuItem(
              value: 'Clinic',
              child: Text(LocaleKeys.clinic.tr()),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedType = value;
              });
            }
          },
          decoration: InputDecoration(
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
      ],
    );
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
          LocaleKeys.addMedicalCenter.tr(),
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
                const MedicalCenterHeaderSection(),
                SizedBox(height: 24.h),
                // 1. Medical Center Name
                MedicalCenterFormField(
                  key: const Key('medical_center_name_field'),
                  inputKey: const Key('medical_center_name_input'),
                  label: LocaleKeys.medicalCenterName.tr(),
                  hintText: LocaleKeys.enterMedicalCenterName.tr(),
                  controller: _nameController,
                  validator: ValidatorApp.validateMedicalCenterName,
                ),
                SizedBox(height: 20.h),
                // 2. Address
                MedicalCenterFormField(
                  key: const Key('medical_center_address_field'),
                  inputKey: const Key('medical_center_address_input'),
                  label: LocaleKeys.address.tr(),
                  hintText: LocaleKeys.enterAddress.tr(),
                  controller: _addressController,
                  validator: ValidatorApp.validateAddress,
                ),
                SizedBox(height: 20.h),
                // 3. Rating
                MedicalCenterFormField(
                  key: const Key('medical_center_rating_field'),
                  inputKey: const Key('medical_center_rating_input'),
                  label: LocaleKeys.rating.tr(),
                  hintText: LocaleKeys.enterRating.tr(),
                  controller: _ratingController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: ValidatorApp.validateRating,
                ),
                SizedBox(height: 20.h),
                // 4. Reviews Count
                MedicalCenterFormField(
                  key: const Key('medical_center_reviews_count_field'),
                  inputKey: const Key('medical_center_reviews_count_input'),
                  label: LocaleKeys.reviewsCount.tr(),
                  hintText: LocaleKeys.enterReviewsCount.tr(),
                  controller: _reviewsCountController,
                  keyboardType: TextInputType.number,
                  validator: ValidatorApp.validateReviewsCount,
                ),
                SizedBox(height: 20.h),
                // 5. Distance
                MedicalCenterFormField(
                  key: const Key('medical_center_distance_field'),
                  inputKey: const Key('medical_center_distance_input'),
                  label: LocaleKeys.distance.tr(),
                  hintText: LocaleKeys.enterDistance.tr(),
                  controller: _distanceController,
                  validator: ValidatorApp.validateDistance,
                ),
                SizedBox(height: 20.h),
                // 6. Duration
                MedicalCenterFormField(
                  key: const Key('medical_center_duration_field'),
                  inputKey: const Key('medical_center_duration_input'),
                  label: LocaleKeys.duration.tr(),
                  hintText: LocaleKeys.enterDuration.tr(),
                  controller: _durationController,
                  validator: ValidatorApp.validateDuration,
                ),
                SizedBox(height: 20.h),
                // 7. Type
                _buildTypeDropdown(),
                SizedBox(height: 20.h),
                // 8. Image Name
                MedicalCenterFormField(
                  key: const Key('medical_center_image_name_field'),
                  inputKey: const Key('medical_center_image_name_input'),
                  label: LocaleKeys.imageName.tr(),
                  hintText: LocaleKeys.enterImageName.tr(),
                  controller: _imageNameController,
                  validator: ValidatorApp.validateImageName,
                ),
                SizedBox(height: 36.h),
                // 9. Submit Button
                AddMedicalCenterButton(
                  key: const Key('medical_center_submit_button'),
                  isLoading: _isLoading,
                  text: LocaleKeys.addMedicalCenter.tr(),
                  icon: Icons.add_circle_outline_rounded,
                  onPressed: _saveMedicalCenter,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
