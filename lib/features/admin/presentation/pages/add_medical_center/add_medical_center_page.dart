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
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_distance_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_duration_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_image_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_name_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_rating_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_reviews_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_type_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_medical_center/medical_center_header_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medical_app/features/home/data/datasources/home_remote_data_source_impl.dart';
import 'package:medical_app/features/home/data/repositories/home_repository_impl.dart';
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
  State<AddMedicalCenterPage> createState() => _AddMedicalCenterPageState();
}

class _AddMedicalCenterPageState extends State<AddMedicalCenterPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _ratingController;
  late final TextEditingController _reviewsCountController;
  late final TextEditingController _distanceController;
  late final TextEditingController _durationController;
  late final TextEditingController _imageNameController;
  late final AddMedicalCenter? _addMedicalCenterUseCase;
  late final UpdateMedicalCenter? _updateMedicalCenterUseCase;

  String _selectedType = 'Hospital';
  double _rating = 0.0;
  bool _isLoading = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  bool get isEditMode => widget.initialMedicalCenter != null;

  @override
  void initState() {
    super.initState();
    final center = widget.initialMedicalCenter;
    _nameController = TextEditingController(text: center?.name ?? '');
    _addressController = TextEditingController(text: center?.address ?? '');
    _ratingController = TextEditingController(
      text: center != null ? center.rating.toString() : '',
    );
    _reviewsCountController = TextEditingController(
      text: center != null ? center.reviewsCount.toString() : '',
    );

    String initialDistance = '';
    if (center != null) {
      final distMatch =
          RegExp(r'[0-9]+(?:\.[0-9]+)?').firstMatch(center.distance);
      initialDistance =
          distMatch != null ? distMatch.group(0)! : center.distance;
    }
    _distanceController = TextEditingController(text: initialDistance);

    String initialDuration = '';
    if (center != null) {
      final durMatch = RegExp(r'[0-9]+').firstMatch(center.duration);
      initialDuration =
          durMatch != null ? durMatch.group(0)! : center.duration;
    }
    _durationController = TextEditingController(text: initialDuration);

    String initialImageName = '';
    if (center != null && center.imagePath.isNotEmpty) {
      final path = center.imagePath;
      initialImageName = path.startsWith('assets/images/')
          ? path.substring('assets/images/'.length)
          : path;
    }
    _imageNameController = TextEditingController(text: initialImageName);

    if (center != null && center.type.isNotEmpty) {
      _selectedType = center.type;
    }
    _rating = center?.rating ?? 0.0;

    _ratingController.addListener(_onRatingControllerChanged);

    _addMedicalCenterUseCase = widget.addMedicalCenter ??
        (getIt.isRegistered<AddMedicalCenter>()
            ? getIt<AddMedicalCenter>()
            : null);
    _updateMedicalCenterUseCase = widget.updateMedicalCenter ??
        (getIt.isRegistered<UpdateMedicalCenter>()
            ? getIt<UpdateMedicalCenter>()
            : null);
  }

  void _onRatingControllerChanged() {
    final parsed = double.tryParse(_ratingController.text.trim()) ?? 0.0;
    if (parsed != _rating && mounted) {
      setState(() {
        _rating = parsed;
      });
    }
  }

  @override
  void dispose() {
    _ratingController.removeListener(_onRatingControllerChanged);
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

    final Result<void> result;
    if (isEditMode) {
      UpdateMedicalCenter? updateUseCase = _updateMedicalCenterUseCase;
      if (updateUseCase == null) {
        if (getIt.isRegistered<UpdateMedicalCenter>()) {
          updateUseCase = getIt<UpdateMedicalCenter>();
        } else {
          try {
            final firestore = getIt.isRegistered<FirebaseFirestore>()
                ? getIt<FirebaseFirestore>()
                : FirebaseFirestore.instance;
            updateUseCase = UpdateMedicalCenter(
              HomeRepositoryImpl(HomeRemoteDataSourceImpl(firestore)),
            );
          } catch (_) {
            updateUseCase = null;
          }
        }
      }

      if (updateUseCase == null) {
        setState(() => _isLoading = false);
        return;
      }

      result = await updateUseCase(
        MedicalCenterEntity(
          id: widget.initialMedicalCenter!.id,
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          rating: rating,
          reviewsCount: reviewsCount,
          distance: distance,
          duration: duration,
          type: _selectedType,
          imagePath: imagePath,
          createdAt: widget.initialMedicalCenter!.createdAt,
        ),
      );
    } else {
      AddMedicalCenter? addUseCase = _addMedicalCenterUseCase;
      if (addUseCase == null) {
        if (getIt.isRegistered<AddMedicalCenter>()) {
          addUseCase = getIt<AddMedicalCenter>();
        } else {
          try {
            final firestore = getIt.isRegistered<FirebaseFirestore>()
                ? getIt<FirebaseFirestore>()
                : FirebaseFirestore.instance;
            addUseCase = AddMedicalCenter(
              HomeRepositoryImpl(HomeRemoteDataSourceImpl(firestore)),
            );
          } catch (_) {
            addUseCase = null;
          }
        }
      }

      if (addUseCase == null) {
        setState(() => _isLoading = false);
        return;
      }

      result = await addUseCase(
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
                  ? LocaleKeys.medicalCenterUpdatedSuccessfully.tr()
                  : LocaleKeys.medicalCenterAddedSuccessfully.tr(),
            ),
            backgroundColor: AppColors.lightTeal,
          ),
        );
        Navigator.pop(context);
      case ErrorAPI(:final failure):
        debugPrint(
          'Failed to ${isEditMode ? "update" : "add"} medical center: ${failure.message}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? LocaleKeys.failedToUpdateMedicalCenter.tr()
                  : LocaleKeys.failedToAddMedicalCenter.tr(),
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
          isEditMode
              ? LocaleKeys.editMedicalCenter.tr()
              : LocaleKeys.addMedicalCenter.tr(),
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
                MedicalCenterHeaderSection(
                  title: isEditMode
                      ? LocaleKeys.editMedicalCenter.tr()
                      : null,
                  subtitle: isEditMode
                      ? LocaleKeys.editMedicalCenterInformation.tr()
                      : null,
                ),
                SizedBox(height: 20.h),
                MedicalCenterNameField(controller: _nameController),
                SizedBox(height: 16.h),
                MedicalCenterAddressField(controller: _addressController),
                SizedBox(height: 16.h),
                MedicalCenterTypeField(
                  selectedType: _selectedType,
                  onTypeChanged: (type) => setState(() => _selectedType = type),
                ),
                SizedBox(height: 16.h),
                MedicalCenterRatingField(
                  controller: _ratingController,
                  rating: _rating,
                  onRatingChanged: (newRating) {
                    _ratingController.text = newRating.toStringAsFixed(1);
                  },
                ),
                SizedBox(height: 16.h),
                MedicalCenterReviewsField(
                  controller: _reviewsCountController,
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MedicalCenterDistanceField(
                        controller: _distanceController,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: MedicalCenterDurationField(
                        controller: _durationController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                MedicalCenterImageField(controller: _imageNameController),
                SizedBox(height: 28.h),
                AddMedicalCenterButton(
                  key: const Key('medical_center_submit_button'),
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
