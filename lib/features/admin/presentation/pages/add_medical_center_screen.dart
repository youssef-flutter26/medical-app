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
import 'package:medical_app/features/admin/presentation/widgets/medical_center_compact_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/medical_center_form_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/medical_center_header_section.dart';
import 'package:medical_app/features/admin/presentation/widgets/medical_center_type_selector.dart';
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

    _ratingController.addListener(_onFieldChanged);
    _imageNameController.addListener(_onFieldChanged);

    _addMedicalCenterUseCase = widget.addMedicalCenter ??
        (getIt.isRegistered<AddMedicalCenter>()
            ? getIt<AddMedicalCenter>()
            : null);
  }

  void _onFieldChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ratingController.removeListener(_onFieldChanged);
    _imageNameController.removeListener(_onFieldChanged);
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

    final rawDistance = _distanceController.text.trim();
    final distance = rawDistance.toLowerCase().endsWith('km')
        ? rawDistance
        : '$rawDistance km';

    final rawDuration = _durationController.text.trim();
    final duration = rawDuration.toLowerCase().endsWith('min')
        ? rawDuration
        : '$rawDuration min';

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
        distance: distance,
        duration: duration,
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

  Widget _buildRatingStars() {
    final ratingVal = double.tryParse(_ratingController.text.trim()) ?? 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = ratingVal >= starIndex;

        return GestureDetector(
          onTap: () {
            _ratingController.text = starIndex.toDouble().toStringAsFixed(1);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Icon(
              Icons.star_rounded,
              size: 22.r,
              color: isSelected
                  ? AppColors.amber
                  : AppColors.gray400.withValues(alpha: 0.35),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildReviewsBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.gray400.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        'Reviews',
        style: AppTextStyles.withColor(
          AppTextStyles.inter12W500,
          AppColors.gray600,
        ),
      ),
    );
  }

  Widget _buildUnitText(String unit) {
    return Text(
      unit,
      style: AppTextStyles.withColor(
        AppTextStyles.inter14W500,
        AppColors.gray600,
      ),
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
                SizedBox(height: 20.h),

                // 1. Medical Center Name
                MedicalCenterFormField(
                  key: const Key('medical_center_name_field'),
                  inputKey: const Key('medical_center_name_input'),
                  label: LocaleKeys.medicalCenterName.tr(),
                  hintText: LocaleKeys.enterMedicalCenterName.tr(),
                  controller: _nameController,
                  validator: ValidatorApp.validateMedicalCenterName,
                  prefixIcon: const Icon(
                    Icons.domain_rounded,
                    color: AppColors.gray500,
                    size: 20,
                  ),
                ),
                SizedBox(height: 16.h),

                // 2. Address
                MedicalCenterFormField(
                  key: const Key('medical_center_address_field'),
                  inputKey: const Key('medical_center_address_input'),
                  label: LocaleKeys.address.tr(),
                  hintText: LocaleKeys.enterAddress.tr(),
                  controller: _addressController,
                  validator: ValidatorApp.validateAddress,
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.gray500,
                    size: 20,
                  ),
                ),
                SizedBox(height: 16.h),

                // 3. Facility Type Selector
                MedicalCenterTypeSelector(
                  key: const Key('medical_center_type_dropdown'),
                  selectedType: _selectedType,
                  onTypeChanged: (type) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                ),
                SizedBox(height: 16.h),

                // 4. Rating (Compact Field + 5 Stars Preview)
                MedicalCenterCompactField(
                  key: const Key('medical_center_rating_field'),
                  inputKey: const Key('medical_center_rating_input'),
                  label: LocaleKeys.rating.tr(),
                  hintText: '4.5',
                  controller: _ratingController,
                  width: 72.w,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: ValidatorApp.validateRating,
                  unitWidget: _buildRatingStars(),
                ),
                SizedBox(height: 16.h),

                // 5. Reviews Count (Compact Numeric Field + 'Reviews' Badge)
                MedicalCenterCompactField(
                  key: const Key('medical_center_reviews_count_field'),
                  inputKey: const Key('medical_center_reviews_count_input'),
                  label: LocaleKeys.reviewsCount.tr(),
                  hintText: '58',
                  controller: _reviewsCountController,
                  width: 78.w,
                  keyboardType: TextInputType.number,
                  validator: ValidatorApp.validateReviewsCount,
                  unitWidget: _buildReviewsBadge(),
                ),
                SizedBox(height: 16.h),

                // 6. Distance & Duration (Side-by-Side Compact Fields)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MedicalCenterCompactField(
                        key: const Key('medical_center_distance_field'),
                        inputKey: const Key('medical_center_distance_input'),
                        label: LocaleKeys.distance.tr(),
                        hintText: '2.5',
                        controller: _distanceController,
                        width: 68.w,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: ValidatorApp.validateDistance,
                        unitWidget: _buildUnitText('km'),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: MedicalCenterCompactField(
                        key: const Key('medical_center_duration_field'),
                        inputKey: const Key('medical_center_duration_input'),
                        label: LocaleKeys.duration.tr(),
                        hintText: '40',
                        controller: _durationController,
                        width: 68.w,
                        keyboardType: TextInputType.number,
                        validator: ValidatorApp.validateDuration,
                        unitWidget: _buildUnitText('min'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // 7. Image Name (with Path Preview Helper)
                MedicalCenterFormField(
                  key: const Key('medical_center_image_name_field'),
                  inputKey: const Key('medical_center_image_name_input'),
                  label: LocaleKeys.imageName.tr(),
                  hintText: 'clinic1.png',
                  controller: _imageNameController,
                  validator: ValidatorApp.validateImageName,
                  prefixIcon: const Icon(
                    Icons.image_outlined,
                    color: AppColors.gray500,
                    size: 20,
                  )
                ),
                SizedBox(height: 28.h),

                // 8. Submit Button
                AddMedicalCenterButton(
                  key: const Key('medical_center_submit_button'),
                  isLoading: _isLoading,
                  text: LocaleKeys.addMedicalCenter.tr(),
                  icon: Icons.add_circle_outline_rounded,
                  onPressed: _saveMedicalCenter,
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
