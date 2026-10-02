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
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_about_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_category_dropdown.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_experience_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_header_section.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_image_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_name_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_rating_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_reviews_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_specialty_field.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/doctor/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/doctor/domain/usecases/add_doctor.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/domain/usecases/get_categories_stream.dart';

class AddDoctorPage extends StatefulWidget {
  final AddDoctor? addDoctor;
  final GetCategoriesStream? getCategoriesStream;
  final Stream<List<CategoryEntity>>? categoriesStream;
  final List<CategoryEntity>? initialCategories;
  final FirebaseAuth? firebaseAuth;
  final UserRemoteDataSource? userRemoteDataSource;
  final Future<void> Function(DoctorEntity doctor)? onSubmit;

  const AddDoctorPage({
    super.key,
    this.addDoctor,
    this.getCategoriesStream,
    this.categoriesStream,
    this.initialCategories,
    this.firebaseAuth,
    this.userRemoteDataSource,
    this.onSubmit,
  });

  @override
  State<AddDoctorPage> createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _specialtyController;
  late final TextEditingController _experienceController;
  late final TextEditingController _ratingController;
  late final TextEditingController _reviewsCountController;
  late final TextEditingController _aboutController;
  late final TextEditingController _imageNameController;

  late final AddDoctor? _addDoctorUseCase;
  late final Stream<List<CategoryEntity>> _categoriesStream;
  StreamSubscription<List<CategoryEntity>>? _categoriesSubscription;
  late final FirebaseAuth? _auth;
  late final UserRemoteDataSource? _userRemoteDataSource;

  List<CategoryEntity>? _categories;
  bool _isCategoriesLoading = true;
  String? _categoriesError;
  CategoryEntity? _selectedCategory;
  bool _isLoading = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  bool get _hasCategories => _categories != null && _categories!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _specialtyController = TextEditingController();
    _experienceController = TextEditingController();
    _ratingController = TextEditingController();
    _reviewsCountController = TextEditingController();
    _aboutController = TextEditingController();
    _imageNameController = TextEditingController();

    if (widget.initialCategories != null) {
      _categories = widget.initialCategories;
      _isCategoriesLoading = false;
    }

    _addDoctorUseCase = widget.addDoctor ??
        (getIt.isRegistered<AddDoctor>() ? getIt<AddDoctor>() : null);

    _categoriesStream = widget.categoriesStream ??
        (widget.getCategoriesStream?.call() ??
            (getIt.isRegistered<GetCategoriesStream>()
                ? getIt<GetCategoriesStream>()()
                : const Stream.empty()));

    _categoriesSubscription = _categoriesStream.listen(
      (categories) {
        if (mounted) {
          setState(() {
            _categories = categories;
            _isCategoriesLoading = false;
            _categoriesError = null;
            if (_selectedCategory != null &&
                !categories.any((c) => c.id == _selectedCategory?.id)) {
              _selectedCategory = null;
            }
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isCategoriesLoading = false;
            _categoriesError = error.toString();
          });
        }
      },
    );

    _auth = widget.firebaseAuth ??
        (getIt.isRegistered<FirebaseAuth>() ? getIt<FirebaseAuth>() : null);

    _userRemoteDataSource = widget.userRemoteDataSource ??
        (getIt.isRegistered<UserRemoteDataSource>()
            ? getIt<UserRemoteDataSource>()
            : null);
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    _nameController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    _ratingController.dispose();
    _reviewsCountController.dispose();
    _aboutController.dispose();
    _imageNameController.dispose();
    super.dispose();
  }

  Future<bool> _verifyAdminPermission() async {
    if (widget.onSubmit != null) return true;

    final currentUser = _auth?.currentUser;
    if (currentUser == null) {
      return false;
    }

    if (_userRemoteDataSource == null) {
      return true;
    }

    try {
      final userModel = await _userRemoteDataSource.getUser(currentUser.uid);
      return userModel?.role == 'admin';
    } catch (e) {
      debugPrint('Error verifying admin permissions: $e');
      return false;
    }
  }

  Future<void> _saveDoctor() async {
    if (_isLoading) return;

    if (!_hasCategories) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.pleaseAddCategoryFirst.tr()),
          backgroundColor: AppColors.amber,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autoValidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.categoryCannotBeEmpty.tr()),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final isAdmin = await _verifyAdminPermission();
    if (!isAdmin) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.notAuthorizedAdmin.tr()),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final trimmedImage = _imageNameController.text.trim();
    final cleanImageName = trimmedImage.startsWith('assets/images/')
        ? trimmedImage.substring('assets/images/'.length)
        : trimmedImage;
    final imagePath =
        cleanImageName.isNotEmpty ? 'assets/images/$cleanImageName' : '';

    final rating = double.parse(_ratingController.text.trim());
    final reviewsCount = int.parse(_reviewsCountController.text.trim());
    final experience = int.parse(_experienceController.text.trim());

    final doctor = DoctorEntity(
      name: _nameController.text.trim(),
      specialty: _specialtyController.text.trim(),
      categoryId: _selectedCategory!.id ?? '',
      categoryName: _selectedCategory!.name,
      experience: experience,
      rating: rating,
      reviewsCount: reviewsCount,
      about: _aboutController.text.trim(),
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );

    if (widget.onSubmit != null) {
      await widget.onSubmit!(doctor);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.doctorAddedSuccessfully.tr()),
          backgroundColor: AppColors.lightTeal,
        ),
      );
      Navigator.pop(context);
      return;
    }

    final addUseCase = _addDoctorUseCase ??
        (getIt.isRegistered<AddDoctor>() ? getIt<AddDoctor>() : null);

    if (addUseCase == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final result = await addUseCase(doctor);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    switch (result) {
      case SuccessAPI():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.doctorAddedSuccessfully.tr()),
            backgroundColor: AppColors.lightTeal,
          ),
        );
        Navigator.pop(context);
      case ErrorAPI(:final failure):
        debugPrint('Failed to add doctor: ${failure.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.failedToAddDoctor.tr()),
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
          LocaleKeys.addDoctor.tr(),
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
                const DoctorHeaderSection(),
                SizedBox(height: 20.h),
                DoctorNameField(controller: _nameController),
                SizedBox(height: 16.h),
                DoctorSpecialtyField(controller: _specialtyController),
                SizedBox(height: 16.h),
                DoctorCategoryDropdown(
                  categories: _categories,
                  isLoading: _isCategoriesLoading,
                  errorMessage: _categoriesError,
                  selectedCategory: _selectedCategory,
                  onChanged: (cat) => setState(() => _selectedCategory = cat),
                ),
                SizedBox(height: 16.h),
                DoctorExperienceField(controller: _experienceController),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DoctorRatingField(controller: _ratingController),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: DoctorReviewsField(
                        controller: _reviewsCountController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                DoctorAboutField(controller: _aboutController),
                SizedBox(height: 16.h),
                DoctorImageField(controller: _imageNameController),
                SizedBox(height: 28.h),
                AddDoctorButton(
                  isLoading: _isLoading,
                  isEnabled: _hasCategories,
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
