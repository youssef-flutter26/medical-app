import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/admin/presentation/pages/add_banner_page.dart';
import 'package:medical_app/features/admin/presentation/pages/add_category_page.dart';
import 'package:medical_app/features/admin/presentation/pages/add_doctor_page.dart';
import 'package:medical_app/features/admin/presentation/pages/add_medical_center_page.dart';
import 'package:medical_app/features/admin/presentation/widgets/admin_fab.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
import 'package:medical_app/features/category/presentation/widgets/category_doctors/doctor_card.dart';
import 'package:medical_app/features/doctor/data/datasources/doctor_remote_data_source_impl.dart';
import 'package:medical_app/features/doctor/data/repositories/doctor_repository_impl.dart';
import 'package:medical_app/features/doctor/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/doctor/domain/usecases/get_doctors_stream.dart';
import 'package:medical_app/features/home/data/datasources/home_remote_data_source_impl.dart';
import 'package:medical_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/usecases/get_banners_stream.dart';
import 'package:medical_app/features/home/domain/usecases/get_categories_stream.dart';
import 'package:medical_app/features/home/domain/usecases/get_medical_centers_stream.dart';
import 'package:medical_app/features/home/presentation/widgets/banner_section.dart';
import 'package:medical_app/features/home/presentation/widgets/categories_section.dart';
import 'package:medical_app/features/home/presentation/widgets/home_header.dart';
import 'package:medical_app/features/home/presentation/widgets/home_search_results.dart';
import 'package:medical_app/features/home/presentation/widgets/medical_centers_section.dart';


class HomeScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final UserRemoteDataSource? userRemoteDataSource;
  final FirebaseFirestore? firestore;
  final GetBannersStream? getBannersStream;
  final GetMedicalCentersStream? getMedicalCentersStream;
  final GetCategoriesStream? getCategoriesStream;
  final GetDoctorsStream? getDoctorsStream;
  final TextEditingController? searchController;

  const HomeScreen({
    super.key,
    this.auth,
    this.userRemoteDataSource,
    this.firestore,
    this.getBannersStream,
    this.getMedicalCentersStream,
    this.getCategoriesStream,
    this.getDoctorsStream,
    this.searchController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<List<BannerEntity>>? _bannersStream;
  Stream<List<MedicalCenterEntity>>? _medicalCentersStream;
  Stream<List<CategoryEntity>>? _categoriesStream;

  final List<StreamSubscription> _subscriptions = [];
  final List<StreamController> _controllers = [];

  List<BannerEntity>? _banners;
  List<MedicalCenterEntity>? _medicalCenters;
  List<CategoryEntity>? _categories;
  List<DoctorEntity>? _doctors;

  late TextEditingController _searchController = _createSearchController();
  bool _isInternalController = false;
  String _searchQuery = '';

  TextEditingController _createSearchController() {
    if (widget.searchController != null) {
      _isInternalController = false;
      return widget.searchController!;
    }
    _isInternalController = true;
    final controller = TextEditingController();
    return controller;
  }

  FirebaseAuth? get _auth {
    if (widget.auth != null) return widget.auth;
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

  @override
  void initState() {
    super.initState();
    _initSearchController();
    _initStreams();
  }

  void _initSearchController() {
    if (widget.searchController != null) {
      _searchController = widget.searchController!;
      _isInternalController = false;
    } else {
      _searchController = TextEditingController();
      _isInternalController = true;
    }
    _searchQuery = _searchController.text;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void reassemble() {
    super.reassemble();
    try {
      _searchController.text;
    } catch (_) {
      _initSearchController();
    }
  }

  void _onSearchChanged() {
    if (mounted && _searchQuery != _searchController.text) {
      setState(() {
        _searchQuery = _searchController.text;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    if (_isInternalController) {
      _searchController.dispose();
    }
    _clearStreams();
    super.dispose();
  }

  void _clearStreams() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    for (final ctrl in _controllers) {
      ctrl.close();
    }
    _controllers.clear();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchController != oldWidget.searchController) {
      _searchController.removeListener(_onSearchChanged);
      if (_isInternalController) {
        _searchController.dispose();
      }
      _initSearchController();
    }
    if (widget.getBannersStream != oldWidget.getBannersStream ||
        widget.getMedicalCentersStream != oldWidget.getMedicalCentersStream ||
        widget.getCategoriesStream != oldWidget.getCategoriesStream ||
        widget.getDoctorsStream != oldWidget.getDoctorsStream ||
        widget.firestore != oldWidget.firestore) {
      _initStreams();
    }
  }

  void _initStreams() {
    _clearStreams();

    final bannersUseCase = widget.getBannersStream ??
        (getIt.isRegistered<GetBannersStream>()
            ? getIt<GetBannersStream>()
            : (widget.firestore != null || getIt.isRegistered<FirebaseFirestore>())
                ? GetBannersStream(
                    HomeRepositoryImpl(
                      HomeRemoteDataSourceImpl(
                        widget.firestore ?? getIt<FirebaseFirestore>(),
                      ),
                    ),
                  )
                : null);

    _bannersStream = _createSharedStream<BannerEntity>(
      source: bannersUseCase?.call(),
      onUpdate: (data) => _banners = data,
    );

    final centersUseCase = widget.getMedicalCentersStream ??
        (getIt.isRegistered<GetMedicalCentersStream>()
            ? getIt<GetMedicalCentersStream>()
            : (widget.firestore != null || getIt.isRegistered<FirebaseFirestore>())
                ? GetMedicalCentersStream(
                    HomeRepositoryImpl(
                      HomeRemoteDataSourceImpl(
                        widget.firestore ?? getIt<FirebaseFirestore>(),
                      ),
                    ),
                  )
                : null);

    _medicalCentersStream = _createSharedStream<MedicalCenterEntity>(
      source: centersUseCase?.call(),
      onUpdate: (data) => _medicalCenters = data,
    );

    final categoriesUseCase = widget.getCategoriesStream ??
        (getIt.isRegistered<GetCategoriesStream>()
            ? getIt<GetCategoriesStream>()
            : (widget.firestore != null || getIt.isRegistered<FirebaseFirestore>())
                ? GetCategoriesStream(
                    HomeRepositoryImpl(
                      HomeRemoteDataSourceImpl(
                        widget.firestore ?? getIt<FirebaseFirestore>(),
                      ),
                    ),
                  )
                : null);

    _categoriesStream = _createSharedStream<CategoryEntity>(
      source: categoriesUseCase?.call(),
      onUpdate: (data) => _categories = data,
    );

    final doctorsUseCase = widget.getDoctorsStream ??
        (getIt.isRegistered<GetDoctorsStream>()
            ? getIt<GetDoctorsStream>()
            : (widget.firestore != null || getIt.isRegistered<FirebaseFirestore>())
                ? GetDoctorsStream(
                    DoctorRepositoryImpl(
                      DoctorRemoteDataSourceImpl(
                        widget.firestore ?? getIt<FirebaseFirestore>(),
                      ),
                    ),
                  )
                : null);

    _createSharedStream<DoctorEntity>(
      source: doctorsUseCase?.call(),
      onUpdate: (data) => _doctors = data,
    );
  }

  Stream<List<T>> _createSharedStream<T>({
    required Stream<List<T>>? source,
    required void Function(List<T>) onUpdate,
  }) {
    if (source == null) {
      final ctrl = StreamController<List<T>>.broadcast();
      _controllers.add(ctrl);
      scheduleMicrotask(() {
        if (!ctrl.isClosed) {
          ctrl.add(<T>[]);
        }
      });
      return ctrl.stream;
    }

    List<T>? latest;
    late StreamController<List<T>> controller;

    final sub = source.listen(
      (data) {
        latest = data;
        onUpdate(data);
        if (mounted) setState(() {});
        if (!controller.isClosed) {
          controller.add(data);
        }
      },
      onError: (e, s) {
        if (!controller.isClosed) {
          controller.addError(e, s);
        }
      },
      onDone: () {
        if (!controller.isClosed) {
          controller.close();
        }
      },
    );
    _subscriptions.add(sub);

    controller = StreamController<List<T>>.broadcast(
      onListen: () {
        if (latest != null && !controller.isClosed) {
          final cached = latest!;
          scheduleMicrotask(() {
            if (!controller.isClosed) {
              controller.add(cached);
            }
          });
        }
      },
    );
    _controllers.add(controller);

    return controller.stream;
  }

  void _navigateToEditBanner(BuildContext context, BannerEntity banner) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddBannerScreen(initialBanner: banner),
      ),
    );
  }

  void _navigateToEditCategory(BuildContext context, CategoryEntity category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCategoryPage(initialCategory: category),
      ),
    );
  }

  void _navigateToEditMedicalCenter(
    BuildContext context,
    MedicalCenterEntity center,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicalCenterPage(
          initialMedicalCenter: center,
        ),
      ),
    );
  }

  void _navigateToEditDoctor(BuildContext context, DoctorEntity doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddDoctorPage(initialDoctor: doctor),
      ),
    );
  }

  void _navigateToCategoryDoctors(
    BuildContext context,
    CategoryEntity category,
  ) {
    Navigator.pushNamed(
      context,
      Routes.categoryDoctors,
      arguments: category,
    );
  }

  Widget _buildSearchResults(BuildContext context, bool isAdmin) {
    final query = _searchQuery.trim().toLowerCase();

    // 1. Doctors matching (by name, specialty, categoryName, address)
    final matchingDoctors = (_doctors ?? const <DoctorEntity>[]).where((doctor) {
      final nameMatches = doctor.name.toLowerCase().contains(query);
      final specMatches = doctor.specialty.toLowerCase().contains(query);
      final catMatches = doctor.categoryName.toLowerCase().contains(query);
      final addressMatches = doctor.address.toLowerCase().contains(query);
      return nameMatches || specMatches || catMatches || addressMatches;
    }).toList();

    // 2. Categories matching (by name, id)
    final matchingCategories = (_categories ?? const <CategoryEntity>[]).where((category) {
      final nameMatches = category.name.toLowerCase().contains(query);
      final idMatches = (category.id ?? '').toLowerCase().contains(query);
      return nameMatches || idMatches;
    }).toList();

    // 3. Medical Centers matching (by name, address, type, and section queries)
    final isNearbySectionQuery = 'nearby medical centers'.contains(query) ||
        'medical centers'.contains(query) ||
        'nearby'.contains(query) ||
        'hospital'.contains(query) ||
        'clinic'.contains(query);

    final matchingCenters = (_medicalCenters ?? const <MedicalCenterEntity>[]).where((center) {
      if (isNearbySectionQuery) return true;
      final nameMatches = center.name.toLowerCase().contains(query);
      final addressMatches = center.address.toLowerCase().contains(query);
      final typeMatches = center.type.toLowerCase().contains(query);
      return nameMatches || addressMatches || typeMatches;
    }).toList();

    // 4. Banners matching (by title, description)
    final matchingBanners = (_banners ?? const <BannerEntity>[]).where((banner) {
      final titleMatches = banner.title.toLowerCase().contains(query);
      final descMatches = banner.description.toLowerCase().contains(query);
      return titleMatches || descMatches;
    }).toList();

    final isLoading = _doctors == null &&
        _categories == null &&
        _medicalCenters == null &&
        _banners == null;

    return HomeSearchResults(
      searchQuery: _searchQuery.trim(),
      isLoading: isLoading,
      isAdmin: isAdmin,
      doctors: matchingDoctors,
      categories: matchingCategories,
      medicalCenters: matchingCenters,
      banners: matchingBanners,
      onDoctorTap: (doctor) {
        final doctorData = DoctorData.fromEntity(doctor);
        Navigator.pushNamed(
          context,
          Routes.doctorDetails,
          arguments: doctorData,
        );
      },
      onCategoryTap: (category) {
        _navigateToCategoryDoctors(context, category);
      },
      onMedicalCenterTap: (center) {
        if (isAdmin) {
          _navigateToEditMedicalCenter(context, center);
        } else {
          _showMedicalCenterDetails(context, center);
        }
      },
      onDoctorEdit:
          isAdmin ? (doctor) => _navigateToEditDoctor(context, doctor) : null,
      onCategoryEdit:
          isAdmin ? (category) => _navigateToEditCategory(context, category) : null,
      onMedicalCenterEdit:
          isAdmin ? (center) => _navigateToEditMedicalCenter(context, center) : null,
    );
  }

  void _showMedicalCenterDetails(
    BuildContext context,
    MedicalCenterEntity center,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: AppColors.white,
      builder: (ctx) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.gray400.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    center.name,
                    style: AppTextStyles.inter16W500.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTeal,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.lightTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    center.type,
                    style: AppTextStyles.inter12W500.copyWith(
                      color: AppColors.lightTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16.r, color: AppColors.gray500),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    center.address,
                    style: AppTextStyles.inter14W400.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.star_rounded, size: 18.r, color: AppColors.amber),
                SizedBox(width: 4.w),
                Text(
                  center.rating.toStringAsFixed(1),
                  style: AppTextStyles.inter14W500.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTeal,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  '(${center.reviewsCount} ${LocaleKeys.reviews.tr()})',
                  style: AppTextStyles.inter12W400.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.directions_walk_rounded, size: 16.r, color: AppColors.gray500),
                SizedBox(width: 4.w),
                Text(
                  center.formattedDistance,
                  style: AppTextStyles.inter12W500.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = _auth;
    final remoteDataSource = _userRemoteDataSource;

    if (firebaseAuth == null) {
      return _buildScaffold(context, showAdminFab: false, isAdmin: false);
    }

    return StreamBuilder<User?>(
      stream: firebaseAuth.authStateChanges(),
      builder: (context, authSnapshot) {
        final currentUser = authSnapshot.data ?? firebaseAuth.currentUser;

        if (currentUser == null || remoteDataSource == null) {
          return _buildScaffold(context, showAdminFab: false, isAdmin: false);
        }

        return StreamBuilder<UserModel?>(
          stream: remoteDataSource.getUserStream(currentUser.uid),
          builder: (context, userSnapshot) {
            final isAdmin = userSnapshot.data?.role == 'admin';
            return _buildScaffold(
              context,
              showAdminFab: isAdmin,
              isAdmin: isAdmin,
            );
          },
        );
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context, {
    required bool showAdminFab,
    bool isAdmin = false,
  }) {
    return Scaffold(
      backgroundColor: AppColors.white,
      floatingActionButton: showAdminFab ? const AdminFab() : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                searchController: _searchController,
                onSearchChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                onSearchClear: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),
              if (_searchQuery.trim().isNotEmpty) ...[
                SizedBox(height: 20.h),
                _buildSearchResults(context, isAdmin),
              ] else ...[
                SizedBox(height: 20.h),
                StreamBuilder<List<BannerEntity>>(
                  stream: _bannersStream,
                  builder: (context, bannerSnapshot) {
                    return BannerSection(
                      banners: bannerSnapshot.data,
                      isAdmin: isAdmin,
                      onEditBanner: (banner) =>
                          _navigateToEditBanner(context, banner),
                    );
                  },
                ),
                SizedBox(height: 22.h),
                StreamBuilder<List<CategoryEntity>>(
                  stream: _categoriesStream,
                  builder: (context, categorySnapshot) {
                    if (categorySnapshot.hasError) {
                      debugPrint(
                        'HomeScreen: Categories stream error: ${categorySnapshot.error}',
                      );
                    }
                    return CategoriesSection(
                      categories: categorySnapshot.data,
                      isLoading: categorySnapshot.connectionState ==
                              ConnectionState.waiting &&
                          !categorySnapshot.hasData,
                      errorMessage: categorySnapshot.hasError
                          ? '${categorySnapshot.error}'
                          : null,
                      isAdmin: isAdmin,
                      onEditCategory: (category) =>
                          _navigateToEditCategory(context, category),
                      onCategoryTap: (category) =>
                          _navigateToCategoryDoctors(context, category),
                      onSeeAllPressed: () {
                        Navigator.pushNamed(context, Routes.category);
                      },
                    );
                  },
                ),
                SizedBox(height: 24.h),
                StreamBuilder<List<MedicalCenterEntity>>(
                  stream: _medicalCentersStream,
                  builder: (context, centerSnapshot) {
                    if (centerSnapshot.hasError) {
                      debugPrint(
                        'HomeScreen: Medical centers stream error: ${centerSnapshot.error}',
                      );
                    }
                    return MedicalCentersSection(
                      medicalCenters: centerSnapshot.data,
                      isLoading: centerSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          !centerSnapshot.hasData,
                      errorMessage: centerSnapshot.hasError
                          ? '${centerSnapshot.error}'
                          : null,
                      isAdmin: isAdmin,
                      onEditCenter: (center) =>
                          _navigateToEditMedicalCenter(context, center),
                    );
                  },
                ),
              ],
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
