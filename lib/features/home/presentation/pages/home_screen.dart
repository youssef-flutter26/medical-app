import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/features/admin/presentation/widgets/admin_fab.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
import 'package:medical_app/features/home/presentation/widgets/home_banner.dart';
import 'package:medical_app/features/home/presentation/widgets/home_categories.dart';
import 'package:medical_app/features/home/presentation/widgets/home_location.dart';
import 'package:medical_app/features/home/presentation/widgets/home_search.dart';
import 'package:medical_app/features/home/presentation/widgets/nearby_medical_centers.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth? auth;
  final UserRemoteDataSource? userRemoteDataSource;
  final FirebaseFirestore? firestore;

  const HomeScreen({
    super.key,
    this.auth,
    this.userRemoteDataSource,
    this.firestore,
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

  FirebaseFirestore? get _firestore {
    if (firestore != null) return firestore;
    try {
      return getIt.isRegistered<FirebaseFirestore>()
          ? getIt<FirebaseFirestore>()
          : FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = _auth;
    final remoteDataSource = _userRemoteDataSource;

    if (firebaseAuth == null) {
      return _buildScaffold(context, showAdminFab: false);
    }

    return StreamBuilder<User?>(
      stream: firebaseAuth.authStateChanges(),
      builder: (context, authSnapshot) {
        final currentUser = authSnapshot.data ?? firebaseAuth.currentUser;

        if (currentUser == null || remoteDataSource == null) {
          return _buildScaffold(context, showAdminFab: false);
        }

        return StreamBuilder<UserModel?>(
          stream: remoteDataSource.getUserStream(currentUser.uid),
          builder: (context, userSnapshot) {
            final isAdmin = userSnapshot.data?.role == 'admin';
            return _buildScaffold(context, showAdminFab: isAdmin);
          },
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, {required bool showAdminFab}) {
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
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore?.collection('banners').snapshots(),
                builder: (context, bannerSnapshot) {
                  final docs = bannerSnapshot.data?.docs;
                  if (docs == null || docs.isEmpty) {
                    return const HomeBanner();
                  }

                  if (docs.length == 1) {
                    final data = docs.first.data();
                    return HomeBanner(
                      title: data['title'] as String?,
                      subtitle: data['description'] as String?,
                      imagePath: (data['imagePath'] as String?) ??
                          (data['imageUrl'] as String?),
                    );
                  }

                  return SizedBox(
                    height: 156.h,
                    child: PageView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: HomeBanner(
                            title: data['title'] as String?,
                            subtitle: data['description'] as String?,
                            imagePath: (data['imagePath'] as String?) ??
                                (data['imageUrl'] as String?),
                          ),
                        );
                      },
                    ),
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
