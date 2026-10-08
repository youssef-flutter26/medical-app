import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/admin/presentation/pages/add_doctor_page.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';

import '../../../reviews/domain/entities/review_summary.dart';
import '../../../reviews/domain/repositories/review_repository.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/usecases/get_doctors_by_category_stream.dart';
import '../../domain/usecases/get_doctors_stream.dart';
import '../widgets/category_doctors_header.dart';
import '../widgets/category_doctors_list.dart';
import '../widgets/doctor_card.dart';

class CategoryDoctorsPage extends StatefulWidget {
  final String? categoryName;
  final CategoryEntity? category;
  final String? pageTitle;
  final List<DoctorData>? initialDoctors;
  final int? resultsCount;
  final Stream<List<DoctorEntity>>? doctorsStream;
  final GetDoctorsStream? getDoctorsStream;
  final GetDoctorsByCategoryStream? getDoctorsByCategoryStream;

  final bool? isAdmin;
  final FirebaseAuth? firebaseAuth;
  final UserRemoteDataSource? userRemoteDataSource;

  const CategoryDoctorsPage({
    super.key,
    this.categoryName,
    this.category,
    this.pageTitle,
    this.initialDoctors,
    this.resultsCount,
    this.doctorsStream,
    this.getDoctorsStream,
    this.getDoctorsByCategoryStream,
    this.isAdmin,
    this.firebaseAuth,
    this.userRemoteDataSource,
  });

  @override
  State<CategoryDoctorsPage> createState() =>
      _CategoryDoctorsPageState();
}

class _CategoryDoctorsPageState extends State<CategoryDoctorsPage> {
  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  List<DoctorData>? _doctors;

  bool _isLoading = true;

  String? _errorMessage;

  StreamSubscription<List<DoctorEntity>>? _subscription;

  ReviewRepository? get _reviewRepository {
    try {
      if (getIt.isRegistered<ReviewRepository>()) {
        return getIt<ReviewRepository>();
      }
    } catch (_) {}

    return null;
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _loadRealReviewSummaries(List<DoctorData> doctors,) async {
    final repository = _reviewRepository;

    if (repository == null) {
      return;
    }

    final updatedDoctors = await Future.wait(
      doctors.map(
            (doctor) async {
          final doctorId = doctor.id;

          if (doctorId == null || doctorId
              .trim()
              .isEmpty) {
            return doctor;
          }

          try {
            final result = await repository.getReviewSummary(
              targetId: doctorId,
              targetType: 'doctor',
            );

            if (result is SuccessAPI<ReviewSummary>) {
              final summary = result.data;

              return doctor.copyWith(
                rating: summary.rating,
                reviewCount: summary.reviewCount,
              );
            }
          } catch (e) {
            debugPrint(
              'CategoryDoctorsPage: Failed to load '
                  'reviews for doctor $doctorId: $e',
            );
          }

          return doctor;
        },
      ),
    );

    if (!mounted) return;

    setState(() {
      _doctors = updatedDoctors;
    });
  }

  void _setDoctorsFromEntities(List<DoctorEntity> entities,) {
    final doctors = entities
        .map(
          (entity) => DoctorData.fromEntity(entity),
    )
        .toList();

    if (!mounted) return;

    setState(() {
      _doctors = doctors;
      _isLoading = false;
      _errorMessage = null;
    });

    _loadRealReviewSummaries(doctors);
  }

  void _initData() {
    if (widget.initialDoctors != null) {
      final doctors = List<DoctorData>.from(
        widget.initialDoctors!,
      );

      _doctors = doctors;
      _isLoading = false;

      _loadRealReviewSummaries(doctors);

      return;
    }

    final categoryId = widget.category?.id;

    Stream<List<DoctorEntity>>? stream =
        widget.doctorsStream;

    if (stream == null) {
      if (categoryId != null && categoryId.isNotEmpty) {
        final useCase =
            widget.getDoctorsByCategoryStream ??
                (getIt.isRegistered<GetDoctorsByCategoryStream>()
                    ? getIt<GetDoctorsByCategoryStream>()
                    : null);

        stream = useCase?.call(categoryId);
      } else {
        final useCase =
            widget.getDoctorsStream ??
                (getIt.isRegistered<GetDoctorsStream>()
                    ? getIt<GetDoctorsStream>()
                    : null);

        stream = useCase?.call();
      }
    }

    if (stream != null) {
      _subscription = stream.listen(
            (entities) {
          _setDoctorsFromEntities(entities);
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = error.toString();
            });
          }
        },
      );
    } else {
      _doctors = <DoctorData>[];
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String get _effectiveCategoryName {
    if (widget.categoryName != null &&
        widget.categoryName!.isNotEmpty) {
      return widget.categoryName!;
    }

    if (widget.category != null &&
        widget.category!.name.isNotEmpty) {
      return widget.category!.name;
    }

    return '';
  }

  String get _effectiveTitle {
    if (widget.pageTitle != null &&
        widget.pageTitle!.isNotEmpty) {
      return widget.pageTitle!;
    }

    final catName = _effectiveCategoryName;

    if (catName.isNotEmpty &&
        catName.toLowerCase() != 'all doctors') {
      return catName;
    }

    return LocaleKeys.allDoctors.tr();
  }

  List<DoctorData> get _filteredDoctors {
    final baseDoctors = _doctors ?? <DoctorData>[];

    final selectedCategory = _effectiveCategoryName;

    final hasCategoryFilter =
        selectedCategory.isNotEmpty &&
            selectedCategory.toLowerCase() != 'all doctors';

    final categoryFiltered =
    hasCategoryFilter && widget.category?.id == null
        ? baseDoctors.where((d) {
      final cat = d.category?.toLowerCase() ?? '';
      final spec = d.specialty.toLowerCase();
      final target = selectedCategory.toLowerCase();

      return cat == target ||
          spec.contains(target) ||
          target.contains(cat);
    }).toList()
        : baseDoctors;

    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return categoryFiltered;
    }

    return categoryFiltered.where((d) {
      return d.name.toLowerCase().contains(query) ||
          d.specialty.toLowerCase().contains(query) ||
          d.location.toLowerCase().contains(query);
    }).toList();
  }

  int get _effectiveResultsCount {
    if (widget.resultsCount != null) {
      return widget.resultsCount!;
    }

    return _filteredDoctors.length;
  }

  void _toggleFavorite(DoctorData doctor) {
    if (_doctors == null) return;

    setState(() {
      final index = _doctors!.indexWhere(
            (d) => d.id == doctor.id,
      );

      if (index != -1) {
        _doctors![index] = doctor.copyWith(
          isFavorite: !doctor.isFavorite,
        );
      }
    });
  }

  FirebaseAuth? get _auth {
    if (widget.firebaseAuth != null) {
      return widget.firebaseAuth;
    }

    try {
      return getIt.isRegistered<FirebaseAuth>()
          ? getIt<FirebaseAuth>()
          : FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  UserRemoteDataSource? get _userRemoteDataSource {
    if (widget.userRemoteDataSource != null) {
      return widget.userRemoteDataSource;
    }

    try {
      return getIt.isRegistered<UserRemoteDataSource>()
          ? getIt<UserRemoteDataSource>()
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _navigateToEditDoctor(DoctorData doctor,) async {
    final entity = doctor.toEntity();

    final updated = await Navigator.push<DoctorEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => AddDoctorPage(
          initialDoctor: entity,
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        if (_doctors != null) {
          final index = _doctors!.indexWhere(
                (d) => d.id == updated.id,
          );

          if (index != -1) {
            final oldFav = _doctors![index].isFavorite;

            _doctors![index] = DoctorData.fromEntity(updated).copyWith(
              isFavorite: oldFav,
            );
          }
        }
      });

      final doctors = _doctors;

      if (doctors != null && doctors.isNotEmpty) {
        await _loadRealReviewSummaries(
          List<DoctorData>.from(doctors),
        );
      }
    }
  }

  Future<void> _navigateToDoctorDetails(DoctorData doctor,) async {
    await Navigator.pushNamed(
      context,
      Routes.doctorDetails,
      arguments: doctor,
    );

    if (!mounted) return;

    // Refresh the real rating and review count after returning
    // from the doctor details/review page.
    final doctors = _doctors;

    if (doctors == null || doctors.isEmpty) {
      return;
    }

    await _loadRealReviewSummaries(
      List<DoctorData>.from(doctors),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAdmin != null) {
      return _buildScaffold(
        context,
        isAdmin: widget.isAdmin!,
      );
    }

    final firebaseAuth = _auth;
    final remoteDataSource = _userRemoteDataSource;

    if (firebaseAuth == null || remoteDataSource == null) {
      return _buildScaffold(
        context,
        isAdmin: false,
      );
    }

    return StreamBuilder<User?>(
      stream: firebaseAuth.authStateChanges(),
      builder: (context,
          authSnapshot,) {
        final currentUser =
            authSnapshot.data ?? firebaseAuth.currentUser;

        if (currentUser == null) {
          return _buildScaffold(
            context,
            isAdmin: false,
          );
        }

        return StreamBuilder<UserModel?>(
          stream: remoteDataSource.getUserStream(
            currentUser.uid,
          ),
          builder: (context,
              userSnapshot,) {
            final isAdmin =
                userSnapshot.data?.role == 'admin';

            return _buildScaffold(
              context,
              isAdmin: isAdmin,
            );
          },
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, {
    required bool isAdmin,
  }) {
    final doctors = _filteredDoctors;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppAssets.iconsBackIcon,
            width: 24.w,
            height: 24.h,
            colorFilter: const ColorFilter.mode(
              AppColors.darkTeal,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _effectiveTitle,
          style: AppTextStyles.inter18W700.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTeal,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryDoctorsHeader(
                searchController: _searchController,
                resultsCount: _effectiveResultsCount,
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onClearSearch: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),
              SizedBox(height: 16.h),
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 32.h,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.withColor(
                      AppTextStyles.inter14W400,
                      Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else if (_isLoading && _doctors == null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 48.h,
                  ),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: AppColors.darkTeal,
                  ),
                )
              else
                CategoryDoctorsList(
                  doctors: doctors,
                  isAdmin: isAdmin,
                  onDoctorTap: _navigateToDoctorDetails,
                  onFavoriteTap: _toggleFavorite,
                  onEditDoctor: _navigateToEditDoctor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
