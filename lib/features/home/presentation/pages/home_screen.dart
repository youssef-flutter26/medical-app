import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/admin/presentation/pages/add_banner_screen.dart';
import 'package:medical_app/features/admin/presentation/widgets/admin_fab.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
import 'package:medical_app/features/home/data/datasources/home_remote_data_source_impl.dart';
import 'package:medical_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:medical_app/features/home/domain/usecases/get_banners_stream.dart';
import 'package:medical_app/features/home/presentation/widgets/home_banner.dart';
import 'package:medical_app/features/home/presentation/widgets/home_banner_slider.dart';
import 'package:medical_app/features/home/presentation/widgets/home_categories.dart';
import 'package:medical_app/features/home/presentation/widgets/home_location.dart';
import 'package:medical_app/features/home/presentation/widgets/home_search.dart';
import 'package:medical_app/features/home/presentation/widgets/nearby_medical_centers.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth? auth;
  final UserRemoteDataSource? userRemoteDataSource;
  final FirebaseFirestore? firestore;
  final GetBannersStream? getBannersStream;

  const HomeScreen({
    super.key,
    this.auth,
    this.userRemoteDataSource,
    this.firestore,
    this.getBannersStream,
  });

  FirebaseAuth? get _auth {
    if (auth != null) return auth;
    try {
      return getIt.isRegistered<FirebaseAuth>()
          ? getIt<FirebaseAuth>()
          : FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  UserRemoteDataSource? get _userRemoteDataSource {
    if (userRemoteDataSource != null) return userRemoteDataSource;
    try {
      return getIt.isRegistered<UserRemoteDataSource>()
          ? getIt<UserRemoteDataSource>()
          : null;
    } catch (_) {
      return null;
    }
  }

  GetBannersStream? get _getBannersStream {
    if (getBannersStream != null) return getBannersStream;
    try {
      if (getIt.isRegistered<GetBannersStream>()) {
        return getIt<GetBannersStream>();
      }
      if (firestore != null || getIt.isRegistered<FirebaseFirestore>()) {
        final fs = firestore ?? getIt<FirebaseFirestore>();
        return GetBannersStream(
          HomeRepositoryImpl(HomeRemoteDataSourceImpl(fs)),
        );
      }
      return null;
    } catch (_) {
      return null;
    }
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
                stream: _getBannersStream?.call() ??
                    Stream.value(const <BannerEntity>[]),
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
              const HomeCategories(),
              SizedBox(height: 24.h),
              const NearbyMedicalCenters(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
