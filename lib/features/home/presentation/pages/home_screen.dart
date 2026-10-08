import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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

import '../../../../core/error/result.dart';
import '../../../reviews/domain/entities/review_summary.dart';
import '../../../reviews/domain/repositories/review_repository.dart';
import 'medical_center_details_page.dart';

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

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  final Geocoding _geocoding = Geocoding();

  Stream<List<BannerEntity>>? _bannersStream;
  Stream<List<MedicalCenterEntity>>? _medicalCentersStream;
  Stream<List<CategoryEntity>>? _categoriesStream;

  StreamSubscription<List<MedicalCenterEntity>>?
  _medicalCentersSubscription;

  StreamSubscription<ServiceStatus>?
  _locationServiceSubscription;

  List<MedicalCenterEntity> _allMedicalCenters = [];
  List<MedicalCenterEntity> _nearbyMedicalCenters = [];

  bool _isNearbyLoading = true;
  String? _nearbyError;
  bool _isCalculatingNearby = false;
  bool? _lastLocationServiceStatus;

  String _currentLocation = 'Current Location';

  FirebaseAuth? get _auth {
    if (widget.auth != null) {
      return widget.auth;
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

  void _navigateToAllMedicalCenters() {
    Navigator.pushNamed(
      context,
      Routes.allMedicalCenters,
      arguments: _nearbyMedicalCenters,
    );
  }

  ReviewRepository? get _reviewRepository {
    try {
      return getIt.isRegistered<ReviewRepository>()
          ? getIt<ReviewRepository>()
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<MedicalCenterEntity>>
  _applyMedicalCenterReviewSummaries(List<MedicalCenterEntity> centers,) async {
    final repository = _reviewRepository;

    if (repository == null) {
      return centers;
    }

    try {
      final updatedCenters = await Future.wait(
        centers.map(
              (center) async {
            if (center.id == null ||
                center.id!.trim().isEmpty) {
              return center;
            }

            try {
              final result = await repository.getReviewSummary(
                targetId: center.id!,
                targetType: 'medicalCenter',
              );

              if (result is SuccessAPI<ReviewSummary>) {
                final summary = result.data;

                return center.copyWith(
                  rating: summary.rating,
                  reviewsCount: summary.reviewCount,
                );
              }
            } catch (e) {
              debugPrint(
                'HomeScreen: Failed to load reviews '
                    'for medical center ${center.id}: $e',
              );
            }

            return center;
          },
        ),
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () => centers,
      );

      return updatedCenters;
    } catch (_) {
      return centers;
    }
  }


  Future<void> _navigateToMedicalCenterDetails(BuildContext context,
      MedicalCenterEntity center,) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MedicalCenterDetailsPage(
              center: center,
            ),
      ),
    );

    if (!mounted) return;

    final updatedCenters =
    await _applyMedicalCenterReviewSummaries(
      _allMedicalCenters,
    );

    if (!mounted) return;

    final updatedById = <String, MedicalCenterEntity>{
      for (final item in updatedCenters)
        if (item.id != null && item.id!.isNotEmpty)
          item.id!: item,
    };

    setState(() {
      _allMedicalCenters = updatedCenters;
      _nearbyMedicalCenters = _nearbyMedicalCenters.map((item) {
        final updated =
        item.id == null ? null : updatedById[item.id!];

        if (updated == null) {
          return item;
        }

        return updated.copyWith(
          distance: item.distance,
        );
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initStreams();
    _listenToLocationService();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget,) {
    super.didUpdateWidget(oldWidget);

    if (widget.getBannersStream !=
        oldWidget.getBannersStream ||
        widget.getMedicalCentersStream !=
            oldWidget.getMedicalCentersStream ||
        widget.getCategoriesStream !=
            oldWidget.getCategoriesStream ||
        widget.firestore != oldWidget.firestore) {
      _initStreams();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state,) {
    if (state == AppLifecycleState.resumed) {
      _calculateNearbyMedicalCenters(
        _allMedicalCenters,
        force: true,
      );
    }
  }

  void _initStreams() {
    _medicalCentersSubscription?.cancel();

    final bannersUseCase =
        widget.getBannersStream ??
            (getIt.isRegistered<GetBannersStream>()
                ? getIt<GetBannersStream>()
                : (widget.firestore != null ||
                getIt.isRegistered<FirebaseFirestore>())
                ? GetBannersStream(
              HomeRepositoryImpl(
                HomeRemoteDataSourceImpl(
                  widget.firestore ??
                      getIt<FirebaseFirestore>(),
                ),
              ),
            )
                : null);

    _bannersStream = bannersUseCase?.call() ??
        Stream.value(
          const <BannerEntity>[],
        );

    final centersUseCase =
        widget.getMedicalCentersStream ??
            (getIt.isRegistered<GetMedicalCentersStream>()
                ? getIt<GetMedicalCentersStream>()
                : (widget.firestore != null ||
                getIt.isRegistered<FirebaseFirestore>())
                ? GetMedicalCentersStream(
              HomeRepositoryImpl(
                HomeRemoteDataSourceImpl(
                  widget.firestore ??
                      getIt<FirebaseFirestore>(),
                ),
              ),
            )
                : null);

    _medicalCentersStream = centersUseCase?.call() ??
        Stream.value(
          const <MedicalCenterEntity>[],
        );

    final categoriesUseCase =
        widget.getCategoriesStream ??
            (getIt.isRegistered<GetCategoriesStream>()
                ? getIt<GetCategoriesStream>()
                : (widget.firestore != null ||
                getIt.isRegistered<FirebaseFirestore>())
                ? GetCategoriesStream(
              HomeRepositoryImpl(
                HomeRemoteDataSourceImpl(
                  widget.firestore ??
                      getIt<FirebaseFirestore>(),
                ),
              ),
            )
                : null);

    _categoriesStream = categoriesUseCase?.call() ??
        Stream.value(
          const <CategoryEntity>[],
        );

    _medicalCentersSubscription =
        _medicalCentersStream!.listen(
              (centers) async {
            final centersList =
            List<MedicalCenterEntity>.from(centers);
            final updatedCenters =
            await _applyMedicalCenterReviewSummaries(
              centersList,
            );

            if (!mounted) return;

            _allMedicalCenters = updatedCenters;

            await _calculateNearbyMedicalCenters(
              _allMedicalCenters,
              force: true,
            );
          },
          onError: (error) {
            debugPrint(
              'HomeScreen: Medical centers error: $error',
            );

            if (!mounted) return;

            setState(() {
              _nearbyMedicalCenters = [];
              _isNearbyLoading = false;
              _nearbyError = error.toString();
            });
          },
        );
  }

  void _listenToLocationService() {
    _locationServiceSubscription?.cancel();

    _locationServiceSubscription =
        Geolocator.getServiceStatusStream().listen(
              (ServiceStatus status) {
            final isEnabled =
                status == ServiceStatus.enabled;

            debugPrint(
              'HomeScreen: Location service status changed: '
                  '$status',
            );

            if (_lastLocationServiceStatus ==
                isEnabled) {
              return;
            }

            _lastLocationServiceStatus = isEnabled;

            if (!mounted) return;

            if (!isEnabled) {
              _handleLocationDisabled();
            } else {
              _handleLocationEnabled();
            }
          },
          onError: (error) {
            debugPrint(
              'HomeScreen: Location service stream error: '
                  '$error',
            );
          },
        );
  }

  void _handleLocationDisabled() {
    if (!mounted) return;

    setState(() {
      _nearbyMedicalCenters = [];
      _isNearbyLoading = false;
      _nearbyError =
      'Location services are disabled.';
      _currentLocation = 'Location unavailable';
    });
  }

  Future<void> _handleLocationEnabled() async {
    if (!mounted) return;

    await _calculateNearbyMedicalCenters(
      _allMedicalCenters,
      force: true,
    );
  }

  Future<void> _updateCurrentLocationName(Position position,) async {
    try {
      final placemarks =
      await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        return;
      }

      final placemark = placemarks.first;

      final locality = placemark.locality;
      final subAdministrativeArea =
          placemark.subAdministrativeArea;
      final administrativeArea =
          placemark.administrativeArea;
      final country = placemark.country;

      String city = '';

      if (locality != null &&
          locality
              .trim()
              .isNotEmpty) {
        city = locality.trim();
      } else if (subAdministrativeArea != null &&
          subAdministrativeArea
              .trim()
              .isNotEmpty) {
        city = subAdministrativeArea.trim();
      } else if (administrativeArea != null &&
          administrativeArea
              .trim()
              .isNotEmpty) {
        city = administrativeArea.trim();
      }

      final cleanCountry =
          country?.trim() ?? '';

      final locationParts = <String>[
        if (city.isNotEmpty) city,
        if (cleanCountry.isNotEmpty) cleanCountry,
      ];

      final locationName =
      locationParts.join(', ');

      if (!mounted) return;

      setState(() {
        _currentLocation =
        locationName.isNotEmpty
            ? locationName
            : 'Current Location';
      });
    } catch (e) {
      debugPrint(
        'HomeScreen: Failed to get location name: $e',
      );
    }
  }

  Future<void> _calculateNearbyMedicalCenters(List<MedicalCenterEntity> centers,
      {
        bool force = false,
      }) async {
    if (!mounted) return;

    if (_isCalculatingNearby && !force) {
      return;
    }

    _isCalculatingNearby = true;

    final hasExistingCenters = _nearbyMedicalCenters.isNotEmpty;
    if (!hasExistingCenters && mounted) {
      setState(() {
        _isNearbyLoading = true;
        _nearbyError = null;
      });
    }

    try {
      final serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          if (_nearbyMedicalCenters.isEmpty) {
            _nearbyMedicalCenters = centers;
          }
          _isNearbyLoading = false;
          _nearbyError = null;
          _currentLocation = 'Location unavailable';
        });

        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission ==
          LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          if (_nearbyMedicalCenters.isEmpty) {
            _nearbyMedicalCenters = centers;
          }
          _isNearbyLoading = false;
          _nearbyError = null;
          _currentLocation = 'Location unavailable';
        });

        return;
      }

      // Check last known position for instant responsiveness
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null && mounted) {
        final quickCenters = _sortCentersByDistance(centers, position);
        setState(() {
          _nearbyMedicalCenters = quickCenters;
          _isNearbyLoading = false;
        });
      }

      // Fetch fresh position with 4-second timeout
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );

      await _updateCurrentLocationName(position);

      final calculatedCenters = _sortCentersByDistance(centers, position);

      if (!mounted) return;

      setState(() {
        _nearbyMedicalCenters = calculatedCenters;
        _isNearbyLoading = false;
        _nearbyError = null;
      });
    } catch (e) {
      debugPrint(
        'HomeScreen: Failed to calculate nearby '
            'medical centers: $e',
      );

      if (!mounted) return;

      setState(() {
        if (_nearbyMedicalCenters.isEmpty) {
          _nearbyMedicalCenters = centers;
        }
        _isNearbyLoading = false;
        _nearbyError = null;
      });
    } finally {
      _isCalculatingNearby = false;
    }
  }

  List<MedicalCenterEntity> _sortCentersByDistance(
    List<MedicalCenterEntity> centers,
    Position position,
  ) {
    final list = centers
        .where(
          (center) =>
              center.latitude != null && center.longitude != null,
        )
        .map(
          (center) {
            final distanceInMeters = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              center.latitude!,
              center.longitude!,
            );
            final distanceInKm = distanceInMeters / 1000.0;
            return center.copyWith(distance: distanceInKm);
          },
        )
        .toList();

    list.sort((a, b) => a.distance.compareTo(b.distance));
    return list;
  }

  void _navigateToEditBanner(BuildContext context,
      BannerEntity banner,) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddBannerScreen(
              initialBanner: banner,
            ),
      ),
    );
  }

  void _navigateToEditCategory(BuildContext context,
      CategoryEntity category,) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddCategoryPage(
              initialCategory: category,
            ),
      ),
    );
  }

  void _navigateToEditMedicalCenter(BuildContext context,
      MedicalCenterEntity center,) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicalCenterPage(
          initialMedicalCenter: center,
        ),
      ),
    );
  }

  void _navigateToCategoryDoctors(CategoryEntity category,) {
    Navigator.pushNamed(
      context,
      Routes.categoryDoctors,
      arguments: category,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      this,
    );

    _medicalCentersSubscription?.cancel();
    _locationServiceSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = _auth;
    final remoteDataSource =
        _userRemoteDataSource;

    if (firebaseAuth == null) {
      return _buildScaffold(
        context,
        showAdminFab: false,
        isAdmin: false,
      );
    }

    return StreamBuilder<User?>(
      stream:
      firebaseAuth.authStateChanges(),
      builder: (context,
          authSnapshot,) {
        final currentUser =
            authSnapshot.data ??
                firebaseAuth.currentUser;

        if (currentUser == null ||
            remoteDataSource == null) {
          return _buildScaffold(
            context,
            showAdminFab: false,
            isAdmin: false,
          );
        }

        return StreamBuilder<UserModel?>(
          stream:
          remoteDataSource.getUserStream(
            currentUser.uid,
          ),
          builder: (context,
              userSnapshot,) {
            final isAdmin =
                userSnapshot.data?.role ==
                    'admin';

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

  Widget _buildScaffold(BuildContext context, {
    required bool showAdminFab,
    bool isAdmin = false,
  }) {
    return Scaffold(
      backgroundColor: AppColors.white,
      floatingActionButton:
      showAdminFab
          ? const AdminFab()
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              HomeHeader(
                location: _currentLocation,
              ),

              SizedBox(height: 20.h),

              StreamBuilder<List<BannerEntity>>(
                stream: _bannersStream,
                builder: (context,
                    bannerSnapshot,) {
                  return BannerSection(
                    banners:
                    bannerSnapshot.data,
                    isAdmin: isAdmin,
                    onEditBanner:
                        (banner) =>
                        _navigateToEditBanner(
                          context,
                          banner,
                        ),
                  );
                },
              ),

              SizedBox(height: 22.h),

              StreamBuilder<
                  List<CategoryEntity>>(
                stream: _categoriesStream,
                builder: (context,
                    categorySnapshot,) {
                  if (categorySnapshot
                      .hasError) {
                    debugPrint(
                      'HomeScreen: Categories '
                          'stream error: '
                          '${categorySnapshot.error}',
                    );
                  }

                  return CategoriesSection(
                    categories:
                    categorySnapshot.data,
                    isLoading:
                    categorySnapshot
                        .connectionState ==
                        ConnectionState
                            .waiting &&
                        !categorySnapshot
                            .hasData,
                    errorMessage:
                    categorySnapshot.hasError
                        ? '${categorySnapshot.error}'
                        : null,
                    isAdmin: isAdmin,
                    onEditCategory:
                        (category) =>
                        _navigateToEditCategory(
                          context,
                          category,
                        ),
                    onCategoryTap:
                        (category) =>
                        _navigateToCategoryDoctors(
                          category,
                        ),
                    onSeeAllPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.category,
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 24.h),

              MedicalCentersSection(
                medicalCenters: _nearbyMedicalCenters,
                isLoading: _isNearbyLoading,
                errorMessage: _nearbyError,
                onSeeAll: _navigateToAllMedicalCenters,
                isAdmin: isAdmin,
                onEditCenter: (center) =>
                    _navigateToEditMedicalCenter(
                      context,
                      center,
                    ),
                onCenterTap: (center) =>
                    _navigateToMedicalCenterDetails(
                      context,
                      center,
                    ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
