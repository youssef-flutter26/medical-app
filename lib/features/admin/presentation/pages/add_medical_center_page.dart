import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/add_medical_center_button.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_address_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_image_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_name_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_rating_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_reviews_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_type_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_header_section.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/usecases/add_medical_center.dart';
import 'package:medical_app/features/home/domain/usecases/update_medical_center.dart';

class AddMedicalCenterPage extends StatefulWidget {
  final MedicalCenterEntity? initialMedicalCenter;
  final AddMedicalCenter? addMedicalCenter;
  final UpdateMedicalCenter? updateMedicalCenter;

  const AddMedicalCenterPage({
    super.key,
    this.initialMedicalCenter,
    this.addMedicalCenter,
    this.updateMedicalCenter,
  });

  @override
  State<AddMedicalCenterPage> createState() =>
      _AddMedicalCenterPageState();
}

class _AddMedicalCenterPageState extends State<AddMedicalCenterPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _ratingController;
  late final TextEditingController _reviewsCountController;
  late final TextEditingController _imageNameController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  late final AddMedicalCenter? _addMedicalCenterUseCase;
  late final UpdateMedicalCenter? _updateMedicalCenterUseCase;

  String _selectedType = 'Hospital';

  double _rating = 0.0;

  bool _isLoading = false;

  AutovalidateMode _autoValidateMode =
      AutovalidateMode.disabled;

  bool get isEditMode =>
      widget.initialMedicalCenter != null;

  @override
  void initState() {
    super.initState();

    final center = widget.initialMedicalCenter;

    _nameController = TextEditingController(
      text: center?.name ?? '',
    );

    _addressController = TextEditingController(
      text: center?.address ?? '',
    );

    _ratingController = TextEditingController(
      text: center != null ? center.rating.toString() : '',
    );

    _reviewsCountController = TextEditingController(
      text: center != null
          ? center.reviewsCount.toString()
          : '',
    );

    String initialImageName = '';

    if (center != null && center.imagePath.isNotEmpty) {
      final path = center.imagePath;

      initialImageName =
      path.startsWith('assets/images/')
          ? path.substring('assets/images/'.length)
          : path;
    }

    _imageNameController = TextEditingController(
      text: initialImageName,
    );

    _latitudeController = TextEditingController(
      text: center?.latitude?.toString() ?? '',
    );

    _longitudeController = TextEditingController(
      text: center?.longitude?.toString() ?? '',
    );

    if (center != null && center.type.isNotEmpty) {
      _selectedType = center.type;
    }

    _rating = center?.rating ?? 0.0;

    _ratingController.addListener(
      _onRatingControllerChanged,
    );

    _addMedicalCenterUseCase =
        widget.addMedicalCenter ??
            (getIt.isRegistered<AddMedicalCenter>()
                ? getIt<AddMedicalCenter>()
                : null);

    _updateMedicalCenterUseCase =
        widget.updateMedicalCenter ??
            (getIt.isRegistered<UpdateMedicalCenter>()
                ? getIt<UpdateMedicalCenter>()
                : null);
  }

  void _onRatingControllerChanged() {
    final parsed = double.tryParse(
      _ratingController.text
          .trim()
          .replaceAll(',', '.'),
    ) ??
        0.0;

    if (parsed != _rating && mounted) {
      setState(() {
        _rating = parsed;
      });
    }
  }

  @override
  void dispose() {
    _ratingController.removeListener(
      _onRatingControllerChanged,
    );

    _nameController.dispose();
    _addressController.dispose();
    _ratingController.dispose();
    _reviewsCountController.dispose();
    _imageNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();

    super.dispose();
  }

  Future<void> _saveMedicalCenter() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autoValidateMode =
            AutovalidateMode.onUserInteraction;
      });

      return;
    }

    final rating = double.tryParse(
      _ratingController.text
          .trim()
          .replaceAll(',', '.'),
    );

    final reviewsCount = int.tryParse(
      _reviewsCountController.text.trim(),
    );

    final latitude = double.tryParse(
      _latitudeController.text
          .trim()
          .replaceAll(',', '.'),
    );

    final longitude = double.tryParse(
      _longitudeController.text
          .trim()
          .replaceAll(',', '.'),
    );

    if (rating == null ||
        reviewsCount == null ||
        latitude == null ||
        longitude == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid medical center data.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    final trimmedImage =
    _imageNameController.text.trim();

    final cleanImageName =
    trimmedImage.startsWith('assets/images/')
        ? trimmedImage.substring(
      'assets/images/'.length,
    )
        : trimmedImage;

    final imagePath = cleanImageName.isNotEmpty
        ? 'assets/images/$cleanImageName'
        : '';

    final center = MedicalCenterEntity(
      id: widget.initialMedicalCenter?.id,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      rating: rating,
      reviewsCount: reviewsCount,

      // Distance is NOT entered by the admin.
      // It is calculated at runtime from the user's location.
      distance:
      widget.initialMedicalCenter?.distance ?? 0.0,

      type: _selectedType,
      imagePath: imagePath,
      createdAt:
      widget.initialMedicalCenter?.createdAt ??
          DateTime.now(),
      latitude: latitude,
      longitude: longitude,
    );

    final Result<void> result;

    if (isEditMode) {
      final updateUseCase =
          _updateMedicalCenterUseCase ??
              (getIt.isRegistered<UpdateMedicalCenter>()
                  ? getIt<UpdateMedicalCenter>()
                  : null);

      if (updateUseCase == null) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Update Medical Center service is not available.',
            ),
          ),
        );

        return;
      }

      result = await updateUseCase(center);
    } else {
      final addUseCase =
          _addMedicalCenterUseCase ??
              (getIt.isRegistered<AddMedicalCenter>()
                  ? getIt<AddMedicalCenter>()
                  : null);

      if (addUseCase == null) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Add Medical Center service is not available.',
            ),
          ),
        );

        return;
      }

      result = await addUseCase(center);
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
                  ? LocaleKeys
                  .medicalCenterUpdatedSuccessfully
                  .tr()
                  : LocaleKeys
                  .medicalCenterAddedSuccessfully
                  .tr(),
            ),
            backgroundColor: AppColors.lightTeal,
          ),
        );

        Navigator.pop(context);

      case ErrorAPI(:final failure):
        debugPrint(
          'Failed to '
              '${isEditMode ? "update" : "add"} '
              'medical center: ${failure.message}',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? LocaleKeys
                  .failedToUpdateMedicalCenter
                  .tr()
                  : LocaleKeys
                  .failedToAddMedicalCenter
                  .tr(),
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
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.gray700,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode
              ? LocaleKeys.editMedicalCenter.tr()
              : LocaleKeys.addMedicalCenter.tr(),
          style: AppTextStyles.inter16W500,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidateMode,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                MedicalCenterHeaderSection(
                  title: isEditMode
                      ? LocaleKeys.editMedicalCenter.tr()
                      : null,
                  subtitle: isEditMode
                      ? LocaleKeys
                      .editMedicalCenterInformation
                      .tr()
                      : null,
                ),

                SizedBox(height: 20.h),

                MedicalCenterNameField(
                  controller: _nameController,
                ),

                SizedBox(height: 16.h),

                MedicalCenterAddressField(
                  controller: _addressController,
                ),

                SizedBox(height: 16.h),

                MedicalCenterTypeField(
                  selectedType: _selectedType,
                  onTypeChanged: (type) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                ),

                SizedBox(height: 16.h),

                MedicalCenterRatingField(
                  controller: _ratingController,
                  rating: _rating,
                  onRatingChanged: (newRating) {
                    _ratingController.text =
                        newRating.toStringAsFixed(1);
                  },
                ),

                SizedBox(height: 16.h),

                MedicalCenterReviewsField(
                  controller: _reviewsCountController,
                ),

                SizedBox(height: 16.h),

                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudeController,
                        keyboardType:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration:
                        const InputDecoration(
                          labelText: 'Latitude',
                          hintText: '30.0444',
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudeController,
                        keyboardType:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration:
                        const InputDecoration(
                          labelText: 'Longitude',
                          hintText: '31.2357',
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                MedicalCenterImageField(
                  controller: _imageNameController,
                ),

                SizedBox(height: 28.h),

                AddMedicalCenterButton(
                  isLoading: _isLoading,
                  text: isEditMode
                      ? LocaleKeys.updateMedicalCenter.tr()
                      : LocaleKeys.addMedicalCenter.tr(),
                  icon: isEditMode
                      ? Icons.check_circle_outline_rounded
                      : Icons.add_circle_outline_rounded,
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

typedef AddMedicalCenterScreen = AddMedicalCenterPage;