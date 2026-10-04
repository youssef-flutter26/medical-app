import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/add_doctor_button.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_address_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_category_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_header_section.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_image_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_name_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_rating_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_reviews_field.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/doctor/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:medical_app/features/doctor/domain/usecases/add_doctor.dart';
import 'package:medical_app/features/doctor/domain/usecases/update_doctor.dart';
import 'package:medical_app/features/home/data/datasources/home_remote_data_source_impl.dart';
import 'package:medical_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/domain/usecases/get_categories_stream.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDoctorPage extends StatefulWidget {
  final DoctorEntity? initialDoctor;
  final AddDoctor? addDoctor;
  final UpdateDoctor? updateDoctor;
  final GetCategoriesStream? getCategoriesStream;
  final Stream<List<CategoryEntity>>? categoriesStream;
  final List<CategoryEntity>? initialCategories;
  final FirebaseAuth? firebaseAuth;
  final UserRemoteDataSource? userRemoteDataSource;
  final Future<void> Function(DoctorEntity doctor)? onSubmit;

  const AddDoctorPage({
    super.key,
    this.initialDoctor,
    this.addDoctor,
    this.updateDoctor,
    this.getCategoriesStream,
    this.categoriesStream,
    this.initialCategories,
    this.firebaseAuth,
    this.userRemoteDataSource,
    this.onSubmit,
  });

  @override
  State<AddDoctorPage> createState() =>
      _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _ratingController;
  late final TextEditingController _reviewsCountController;
  late final TextEditingController _imageNameController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  late final AddDoctor? _addDoctorUseCase;

  late final Stream<List<CategoryEntity>>
  _categoriesStream;

  StreamSubscription<List<CategoryEntity>>?
  _categoriesSubscription;

  late final FirebaseAuth? _auth;

  late final UserRemoteDataSource?
  _userRemoteDataSource;

  List<CategoryEntity>? _categories;

  bool _isCategoriesLoading = true;

  String? _categoriesError;

  CategoryEntity? _selectedCategory;

  bool _isLoading = false;

  AutovalidateMode _autoValidateMode =
      AutovalidateMode.disabled;

  bool get isEditMode =>
      widget.initialDoctor != null;

  bool get _hasCategories =>
      _categories != null &&
          _categories!.isNotEmpty;

  @override
  void initState() {
    super.initState();

    final initial = widget.initialDoctor;

    _nameController = TextEditingController(
      text: initial?.name ?? '',
    );

    _addressController = TextEditingController(
      text: initial?.address ?? '',
    );

    _ratingController = TextEditingController(
      text: initial != null
          ? (initial.rating % 1 == 0
          ? initial.rating.toInt().toString()
          : initial.rating.toString())
          : '',
    );

    _reviewsCountController =
        TextEditingController(
          text: initial != null
              ? initial.reviewsCount.toString()
              : '',
        );

    _latitudeController =
        TextEditingController(
          text:
          initial?.latitude?.toString() ?? '',
        );

    _longitudeController =
        TextEditingController(
          text:
          initial?.longitude?.toString() ?? '',
        );

    String initialImageName = '';

    if (initial != null &&
        initial.imagePath.isNotEmpty) {
      final path = initial.imagePath;

      initialImageName =
      path.startsWith('assets/images/')
          ? path.substring(
        'assets/images/'.length,
      )
          : path;
    }

    _imageNameController =
        TextEditingController(
          text: initialImageName,
        );

    if (widget.initialCategories != null) {
      _categories = widget.initialCategories;
      _isCategoriesLoading = false;

      if (initial != null) {
        _selectedCategory =
            _findMatchingCategory(
              _categories!,
              initial,
            );
      }
    }

    _addDoctorUseCase =
        widget.addDoctor ??
            (getIt.isRegistered<AddDoctor>()
                ? getIt<AddDoctor>()
                : null);

    /*
     * Category loading:
     *
     * 1. Use stream supplied to widget.
     * 2. Use GetCategoriesStream from GetIt.
     * 3. Build GetCategoriesStream directly from Firebase.
     * 4. Never fall back to Stream.empty(), because that
     *    leaves the UI loading forever.
     */
    if (widget.categoriesStream != null) {
      _categoriesStream =
      widget.categoriesStream!;
    } else if (widget.getCategoriesStream != null) {
      _categoriesStream =
          widget.getCategoriesStream!();
    } else if (
    getIt.isRegistered<GetCategoriesStream>()) {
      _categoriesStream =
          getIt<GetCategoriesStream>()();
    } else if (
    getIt.isRegistered<FirebaseFirestore>()) {
      final repository = HomeRepositoryImpl(
        HomeRemoteDataSourceImpl(
          getIt<FirebaseFirestore>(),
        ),
      );

      _categoriesStream =
          GetCategoriesStream(repository)();
    } else {
      _categoriesStream = Stream.error(
        'Unable to load categories from Firebase.',
      );
    }

    _categoriesSubscription =
        _categoriesStream.listen(
              (categories) {
            if (!mounted) return;

            setState(() {
              _categories = categories;
              _isCategoriesLoading = false;
              _categoriesError = null;

              if (_selectedCategory == null &&
                  initial != null) {
                _selectedCategory =
                    _findMatchingCategory(
                      categories,
                      initial,
                    );
              } else if (
              _selectedCategory != null &&
                  !categories.any(
                        (category) =>
                    category.id ==
                        _selectedCategory!.id,
                  )) {
                _selectedCategory = null;
              }
            });
          },
          onError: (error) {
            if (!mounted) return;

            setState(() {
              _isCategoriesLoading = false;
              _categoriesError = error.toString();
            });
          },
        );

    _auth = widget.firebaseAuth ??
        (getIt.isRegistered<FirebaseAuth>()
            ? getIt<FirebaseAuth>()
            : null);

    _userRemoteDataSource =
        widget.userRemoteDataSource ??
            (getIt.isRegistered<
                UserRemoteDataSource>()
                ? getIt<UserRemoteDataSource>()
                : null);
  }

  CategoryEntity? _findMatchingCategory(List<CategoryEntity> categories,
      DoctorEntity doctor,) {
    final categoryName =
    doctor.categoryName.trim().toLowerCase();

    final specialty =
    doctor.specialty.trim().toLowerCase();

    for (final category in categories) {
      if (category.id == doctor.categoryId) {
        return category;
      }

      final name =
      category.name.trim().toLowerCase();

      if (name == categoryName ||
          name == specialty) {
        return category;
      }
    }

    return null;
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();

    _nameController.dispose();
    _addressController.dispose();
    _ratingController.dispose();
    _reviewsCountController.dispose();
    _imageNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();

    super.dispose();
  }

  Future<bool> _verifyAdminPermission() async {
    if (widget.onSubmit != null) {
      return true;
    }

    final currentUser = _auth?.currentUser;

    if (currentUser == null) {
      return false;
    }

    if (_userRemoteDataSource == null) {
      return true;
    }

    try {
      final userModel =
      await _userRemoteDataSource.getUser(
        currentUser.uid,
      );

      return userModel?.role == 'admin';
    } catch (e) {
      debugPrint(
        'Error verifying admin permissions: $e',
      );

      return false;
    }
  }

  Future<void> _saveDoctor() async {
    if (_isLoading) return;

    if (_isCategoriesLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please wait until categories are loaded.',
          ),
          backgroundColor: AppColors.amber,
        ),
      );

      return;
    }

    if (!_hasCategories) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.pleaseAddCategoryFirst.tr(),
          ),
          backgroundColor: AppColors.amber,
        ),
      );

      return;
    }

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autoValidateMode =
            AutovalidateMode.onUserInteraction;
      });

      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.categoryCannotBeEmpty.tr(),
          ),
          backgroundColor: AppColors.red,
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    final isAdmin =
    await _verifyAdminPermission();

    if (!isAdmin) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.notAuthorizedAdmin.tr(),
          ),
          backgroundColor: AppColors.red,
        ),
      );

      return;
    }

    final trimmedImage =
    _imageNameController.text.trim();

    final cleanImageName =
    trimmedImage.startsWith(
        'assets/images/')
        ? trimmedImage.substring(
      'assets/images/'.length,
    )
        : trimmedImage;

    final imagePath =
    cleanImageName.isNotEmpty
        ? 'assets/images/$cleanImageName'
        : '';

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
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid doctor data.',
          ),
        ),
      );

      return;
    }

    final doctor = DoctorEntity(
      id: widget.initialDoctor?.id,
      name: _nameController.text.trim(),
      specialty: _selectedCategory!.name,
      categoryId: _selectedCategory!.id ?? '',
      categoryName: _selectedCategory!.name,
      address: _addressController.text.trim(),
      rating: rating,
      reviewsCount: reviewsCount,
      availableTime:
      widget.initialDoctor?.availableTime ??
          'Mon - Sat: 09:00 AM - 05:00 PM',
      imagePath: imagePath,
      createdAt:
      widget.initialDoctor?.createdAt ??
          DateTime.now(),
      latitude: latitude,
      longitude: longitude,
    );

    if (widget.onSubmit != null) {
      await widget.onSubmit!(doctor);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? LocaleKeys
                .doctorUpdatedSuccessfully
                .tr()
                : LocaleKeys
                .doctorAddedSuccessfully
                .tr(),
          ),
          backgroundColor: AppColors.lightTeal,
        ),
      );

      Navigator.pop(context, doctor);

      return;
    }

    final Result<void> result;

    if (isEditMode) {
      final updateUseCase =
          widget.updateDoctor ??
              (getIt.isRegistered<UpdateDoctor>()
                  ? getIt<UpdateDoctor>()
                  : null);

      if (updateUseCase != null) {
        result = await updateUseCase(doctor);
      } else if (
      getIt.isRegistered<DoctorRepository>()) {
        result =
        await getIt<DoctorRepository>().updateDoctor(
          doctor,
        );
      } else {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Update Doctor service is not available.',
            ),
          ),
        );

        return;
      }
    } else {
      final addUseCase =
          _addDoctorUseCase ??
              (getIt.isRegistered<AddDoctor>()
                  ? getIt<AddDoctor>()
                  : null);

      if (addUseCase != null) {
        result = await addUseCase(doctor);
      } else if (
      getIt.isRegistered<DoctorRepository>()) {
        result =
        await getIt<DoctorRepository>().addDoctor(
          doctor,
        );
      } else {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Add Doctor service is not available.',
            ),
          ),
        );

        return;
      }
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
                  .doctorUpdatedSuccessfully
                  .tr()
                  : LocaleKeys
                  .doctorAddedSuccessfully
                  .tr(),
            ),
            backgroundColor: AppColors.lightTeal,
          ),
        );

        Navigator.pop(context, doctor);

      case ErrorAPI(:final failure):
        debugPrint(
          'Failed to '
              '${isEditMode ? 'update' : 'add'} doctor: '
              '${failure.message}',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? LocaleKeys.failedToUpdateDoctor.tr()
                  : LocaleKeys.failedToAddDoctor.tr(),
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
          onPressed: () =>
              Navigator.pop(context),
        ),
        title: Text(
          isEditMode
              ? LocaleKeys.editDoctor.tr()
              : LocaleKeys.addDoctor.tr(),
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
            autovalidateMode:
            _autoValidateMode,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                DoctorHeaderSection(
                  title: isEditMode
                      ? LocaleKeys.editDoctor.tr()
                      : null,
                  subtitle: isEditMode
                      ? LocaleKeys
                      .editDoctorInformation
                      .tr()
                      : null,
                ),

                SizedBox(height: 20.h),

                DoctorNameField(
                  controller: _nameController,
                ),

                SizedBox(height: 16.h),

                DoctorCategoryField(
                  categories: _categories,
                  isLoading:
                  _isCategoriesLoading,
                  errorMessage:
                  _categoriesError,
                  selectedCategory:
                  _selectedCategory,
                  onChanged: (category) {
                    setState(() {
                      _selectedCategory =
                          category;
                    });
                  },
                ),

                SizedBox(height: 16.h),

                DoctorAddressField(
                  controller: _addressController,
                ),

                SizedBox(height: 16.h),

                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller:
                        _latitudeController,
                        keyboardType:
                        const TextInputType
                            .numberWithOptions(
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
                        controller:
                        _longitudeController,
                        keyboardType:
                        const TextInputType
                            .numberWithOptions(
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

                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DoctorRatingField(
                        controller:
                        _ratingController,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: DoctorReviewsField(
                        controller:
                        _reviewsCountController,
                      ),
                    ),
                  ],
                ),

                DoctorImageField(
                  controller:
                  _imageNameController,
                ),

                SizedBox(height: 28.h),

                AddDoctorButton(
                  text: isEditMode
                      ? LocaleKeys.updateDoctor.tr()
                      : null,
                  isLoading: _isLoading,
                  isEnabled: _hasCategories &&
                      !_isCategoriesLoading,
                  onPressed: _saveDoctor,
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

typedef AddDoctorScreen = AddDoctorPage;