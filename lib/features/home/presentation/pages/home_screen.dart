import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/features/admin/presentation/pages/add_banner_page.dart';
import 'package:medical_app/features/admin/presentation/pages/add_category_page.dart';
import 'package:medical_app/features/admin/presentation/pages/add_medical_center_page.dart';
import 'package:medical_app/features/admin/presentation/widgets/admin_fab.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
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
import 'package:medical_app/features/home/presentation/widgets/medical_centers_section.dart';


class HomeScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final UserRemoteDataSource? userRemoteDataSource;
  final FirebaseFirestore? firestore;
  final GetBannersStream? getBannersStream;
  final GetMedicalCentersStream? getMedicalCentersStream;
  final GetCategoriesStream? getCategoriesStream;
  const HomeScreen({
    super.key,
    this.auth,
    this.userRemoteDataSource,
    this.firestore,
    this.getBannersStream,
    this.getMedicalCentersStream,
    this.getCategoriesStream,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<List<BannerEntity>>? _bannersStream;
  Stream<List<MedicalCenterEntity>>? _medicalCentersStream;
  Stream<List<CategoryEntity>>? _categoriesStream;


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
    _initStreams();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.getBannersStream != oldWidget.getBannersStream ||
        widget.getMedicalCentersStream != oldWidget.getMedicalCentersStream ||
        widget.getCategoriesStream != oldWidget.getCategoriesStream ||
        widget.firestore != oldWidget.firestore) {
      _initStreams();
    }
  }

  void _initStreams() {
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

    _bannersStream = bannersUseCase?.call() ??
        Stream.value(const <BannerEntity>[]);

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

    _medicalCentersStream = centersUseCase?.call() ??
        Stream.value(const <MedicalCenterEntity>[]);

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

    _categoriesStream = categoriesUseCase?.call() ??
        Stream.value(const <CategoryEntity>[]);

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
              const HomeHeader(),
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

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
