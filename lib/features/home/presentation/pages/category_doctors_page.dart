import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/admin/presentation/pages/add_doctor_page.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
import 'package:medical_app/features/category/presentation/widgets/category_doctors/category_doctors_header.dart';
import 'package:medical_app/features/category/presentation/widgets/category_doctors/category_doctors_list.dart';
import 'package:medical_app/features/category/presentation/widgets/category_doctors/doctor_card.dart';
import 'package:medical_app/features/doctor/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:medical_app/features/doctor/domain/usecases/get_doctors_by_category_stream.dart';
import 'package:medical_app/features/doctor/domain/usecases/get_doctors_stream.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';

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
  State<CategoryDoctorsPage> createState() => _CategoryDoctorsPageState();
}

class _CategoryDoctorsPageState extends State<CategoryDoctorsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<DoctorData>? _doctors;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<List<DoctorEntity>>? _subscription;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    if (widget.initialDoctors != null) {
      _doctors = List<DoctorData>.from(widget.initialDoctors!);
      _isLoading = false;
      return;
    }

    Stream<List<DoctorEntity>>? stream = widget.doctorsStream;

    if (stream == null) {
      final categoryName = _effectiveCategoryName.trim();
      final categoryId = widget.category?.id?.trim();
      final filterParam = (categoryName.isNotEmpty &&
              categoryName.toLowerCase() != 'all doctors')
          ? categoryName
          : (categoryId != null && categoryId.isNotEmpty ? categoryId : null);

      if (filterParam != null) {
        final useCase = widget.getDoctorsByCategoryStream ??
            (getIt.isRegistered<GetDoctorsByCategoryStream>()
                ? getIt<GetDoctorsByCategoryStream>()
                : null);
        stream = useCase?.call(filterParam);
      } else {
        final useCase = widget.getDoctorsStream ??
            (getIt.isRegistered<GetDoctorsStream>()
                ? getIt<GetDoctorsStream>()
                : null);
        stream = useCase?.call();
      }
    }

    if (stream == null && getIt.isRegistered<DoctorRepository>()) {
      final repo = getIt<DoctorRepository>();
      final categoryName = _effectiveCategoryName.trim();
      final categoryId = widget.category?.id?.trim();
      final filterParam = (categoryName.isNotEmpty &&
              categoryName.toLowerCase() != 'all doctors')
          ? categoryName
          : (categoryId != null && categoryId.isNotEmpty ? categoryId : null);

      stream = filterParam != null
          ? repo.getDoctorsByCategoryStream(filterParam)
          : repo.getDoctorsStream();
    }

    if (stream != null) {
      _subscription = stream.listen(
        (entities) {
          if (mounted) {
            setState(() {
              _doctors = entities.map((e) => DoctorData.fromEntity(e)).toList();
              _isLoading = false;
              _errorMessage = null;
            });
          }
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
    if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
      return widget.categoryName!;
    }
    if (widget.category != null && widget.category!.name.isNotEmpty) {
      return widget.category!.name;
    }
    return '';
  }

  String get _effectiveTitle {
    if (widget.pageTitle != null && widget.pageTitle!.isNotEmpty) {
      return widget.pageTitle!;
    }
    final catName = _effectiveCategoryName;
    if (catName.isNotEmpty && catName.toLowerCase() != 'all doctors') {
      return catName;
    }
    return LocaleKeys.allDoctors.tr();
  }

  List<DoctorData> get _filteredDoctors {
    final baseDoctors = _doctors ?? <DoctorData>[];
    final selectedCategory = _effectiveCategoryName.trim();
    final hasCategoryFilter = selectedCategory.isNotEmpty &&
        selectedCategory.toLowerCase() != 'all doctors';

    final targetId = widget.category?.id?.trim();
    final target = selectedCategory.toLowerCase();

    final categoryFiltered = hasCategoryFilter
        ? baseDoctors.where((d) {
            final catId = (d.rawEntity?.categoryId ?? '').trim();
            final cat = (d.category ?? d.rawEntity?.categoryName ?? '').trim().toLowerCase();
            final spec = d.specialty.trim().toLowerCase();

            final matchesId = targetId != null &&
                targetId.isNotEmpty &&
                catId.isNotEmpty &&
                (catId == targetId || catId.toLowerCase() == targetId.toLowerCase());

            final matchesName = cat == target ||
                spec == target ||
                (target.length >= 3 &&
                    (cat.contains(target) ||
                        target.contains(cat) ||
                        spec.contains(target) ||
                        target.contains(spec)));

            return matchesId || matchesName;
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
      final index = _doctors!.indexWhere((d) => d.id == doctor.id);
      if (index != -1) {
        _doctors![index] = doctor.copyWith(isFavorite: !doctor.isFavorite);
      }
    });
  }

  FirebaseAuth? get _auth {
    if (widget.firebaseAuth != null) return widget.firebaseAuth;
    try {
      return getIt.isRegistered<FirebaseAuth>()
          ? getIt<FirebaseAuth>()
          : FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  UserRemoteDataSource? get _userRemoteDataSource {
    if (widget.userRemoteDataSource != null) return widget.userRemoteDataSource;
    try {
      return getIt.isRegistered<UserRemoteDataSource>()
          ? getIt<UserRemoteDataSource>()
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _navigateToEditDoctor(DoctorData doctor) async {
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
          final index = _doctors!.indexWhere((d) => d.id == updated.id);
          if (index != -1) {
            final oldFav = _doctors![index].isFavorite;
            _doctors![index] =
                DoctorData.fromEntity(updated).copyWith(isFavorite: oldFav);
          }
        }
      });
    }
  }

  void _navigateToDoctorDetails(DoctorData doctor) {
    Navigator.pushNamed(
      context,
      Routes.doctorDetails,
      arguments: doctor,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAdmin != null) {
      return _buildScaffold(context, isAdmin: widget.isAdmin!);
    }

    final firebaseAuth = _auth;
    final remoteDataSource = _userRemoteDataSource;

    if (firebaseAuth == null || remoteDataSource == null) {
      return _buildScaffold(context, isAdmin: false);
    }

    return StreamBuilder<User?>(
      stream: firebaseAuth.authStateChanges(),
      builder: (context, authSnapshot) {
        final currentUser = authSnapshot.data ?? firebaseAuth.currentUser;
        if (currentUser == null) {
          return _buildScaffold(context, isAdmin: false);
        }

        return StreamBuilder<UserModel?>(
          stream: remoteDataSource.getUserStream(currentUser.uid),
          builder: (context, userSnapshot) {
            final isAdmin = userSnapshot.data?.role == 'admin';
            return _buildScaffold(context, isAdmin: isAdmin);
          },
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, {required bool isAdmin}) {
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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
                  padding: EdgeInsets.symmetric(vertical: 32.h),
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
                  padding: EdgeInsets.symmetric(vertical: 48.h),
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
