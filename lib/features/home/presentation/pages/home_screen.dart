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
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/admin/presentation/pages/add_banner_page.dart';
import 'package:medical_app/features/admin/presentation/pages/add_medical_center_page.dart';
import 'package:medical_app/features/admin/presentation/widgets/admin_fab.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
import 'package:medical_app/features/home/data/datasources/home_remote_data_source_impl.dart';
import 'package:medical_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:medical_app/features/home/domain/usecases/get_banners_stream.dart';
import 'package:medical_app/features/home/domain/usecases/get_medical_centers_stream.dart';
import 'package:medical_app/features/home/presentation/widgets/home_banner.dart';
import 'package:medical_app/features/home/presentation/widgets/home_banner_slider.dart';
import 'package:medical_app/features/home/presentation/widgets/home_categories.dart';
import 'package:medical_app/features/home/presentation/widgets/home_location.dart';
import 'package:medical_app/features/home/presentation/widgets/home_search.dart';
import 'package:medical_app/features/home/presentation/widgets/nearby_medical_centers.dart';

class HomeScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final UserRemoteDataSource? userRemoteDataSource;
  final FirebaseFirestore? firestore;
  final GetBannersStream? getBannersStream;
  final GetMedicalCentersStream? getMedicalCentersStream;

  const HomeScreen({
    super.key,
    this.auth,
    this.userRemoteDataSource,
    this.firestore,
    this.getBannersStream,
    this.getMedicalCentersStream,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<List<BannerEntity>>? _bannersStream;
  Stream<List<MedicalCenterEntity>>? _medicalCentersStream;

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
              const HomeLocation(),
              SizedBox(height: 18.h),
              const HomeSearch(),
              SizedBox(height: 20.h),
              StreamBuilder<List<BannerEntity>>(
                stream: _bannersStream,
                builder: (context, bannerSnapshot) {
                  final banners = bannerSnapshot.data;
                  if (banners == null || banners.isEmpty) {
                    return const HomeBanner();
                  }

                  return HomeBannerSlider(
                    banners: banners,
                    isAdmin: isAdmin,
                    onEditBanner: (banner) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddBannerScreen(initialBanner: banner),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 22.h),
              HomeCategories(
                onSeeAllPressed: () {
                  Navigator.pushNamed(context, Routes.category);
                },
              ),
              SizedBox(height: 24.h),
              StreamBuilder<List<MedicalCenterEntity>>(
                stream: _medicalCentersStream,
                builder: (context, centerSnapshot) {
                  // 1. Error state - Do NOT hide errors
                  if (centerSnapshot.hasError) {
                    final errorMsg = '${centerSnapshot.error}';
                    debugPrint(
                      'HomeScreen: Medical centers stream error: $errorMsg',
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.nearbyMedicalCenters.tr(),
                          style: AppTextStyles.inter16W500.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          alignment: Alignment.center,
                          child: Text(
                            'Error loading medical centers: $errorMsg',
                            style: AppTextStyles.withColor(
                              AppTextStyles.inter14W400,
                              Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }

                  // 2. Loading state
                  if (centerSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      !centerSnapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.nearbyMedicalCenters.tr(),
                          style: AppTextStyles.inter16W500.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          height: 218.h,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.darkTeal,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // 3. Success with data & empty data
                  final medicalCenters =
                      centerSnapshot.data ?? const <MedicalCenterEntity>[];

                  // Temporarily log as requested
                  // ignore: avoid_print
                  print('MEDICAL CENTERS COUNT: ${medicalCenters.length}');
                  if (medicalCenters.isNotEmpty) {
                    final first = medicalCenters.first;
                    // ignore: avoid_print
                    print(
                      'FIRST MEDICAL CENTER: id=${first.id}, name="${first.name}", rating=${first.rating}, reviewsCount=${first.reviewsCount}, distance=${first.distance}, duration=${first.duration}, type="${first.type}", imagePath="${first.imagePath}"',
                    );
                  }

                  return NearbyMedicalCenters(
                    isAdmin: isAdmin,
                    onEditCenter: (centerData) {
                      final entity = medicalCenters.firstWhere(
                        (c) =>
                            (centerData.id != null && c.id == centerData.id) ||
                            (c.name == centerData.name &&
                                c.address == centerData.address),
                        orElse: () => MedicalCenterEntity(
                          id: centerData.id,
                          name: centerData.name,
                          address: centerData.address,
                          rating: centerData.rating,
                          reviewsCount: centerData.reviewCount,
                          distance: double.tryParse(RegExp(r'[0-9]+(?:\.[0-9]+)?').firstMatch(centerData.distance)?.group(0) ?? '') ?? 0.0,
                          duration: int.tryParse(RegExp(r'[0-9]+').firstMatch(centerData.duration ?? '')?.group(0) ?? '') ?? 0,
                          type: centerData.type ?? centerData.category,
                          imagePath: centerData.imagePath ?? '',
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddMedicalCenterPage(
                            initialMedicalCenter: entity,
                          ),
                        ),
                      );
                    },
                    medicalCenters: medicalCenters
                        .map(
                          (c) => MedicalCenterData(
                            id: c.id,
                            name: c.name,
                            category: c.type,
                            address: c.address,
                            rating: c.rating,
                            reviewCount: c.reviewsCount,
                            distance: c.formattedDistance,
                            duration: c.formattedDuration,
                            type: c.type,
                            imagePath: c.imagePath,
                          ),
                        )
                        .toList(),
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
