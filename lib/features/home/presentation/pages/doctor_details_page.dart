import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/admin/presentation/pages/add_doctor_page.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
import 'package:medical_app/features/home/presentation/widgets/doctor_card.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';

class DoctorDetailsPage extends StatefulWidget {
  final DoctorEntity? doctor;
  final DoctorData? doctorData;
  final bool? isAdmin;
  final FirebaseAuth? firebaseAuth;
  final UserRemoteDataSource? userRemoteDataSource;

  const DoctorDetailsPage({
    super.key,
    this.doctor,
    this.doctorData,
    this.isAdmin,
    this.firebaseAuth,
    this.userRemoteDataSource,
  });

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  late bool _isFavorite;
  DoctorEntity? _doctor;
  DoctorData? _doctorData;

  @override
  void initState() {
    super.initState();
    _doctor = widget.doctor;
    _doctorData = widget.doctorData;
    _isFavorite = widget.doctorData?.isFavorite ?? false;
  }

  @override
  void didUpdateWidget(covariant DoctorDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.doctor != oldWidget.doctor) {
      _doctor = widget.doctor;
    }
    if (widget.doctorData != oldWidget.doctorData) {
      _doctorData = widget.doctorData;
    }
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

  Future<void> _onEditDoctor() async {
    final currentDoc = _doctor ?? _doctorData?.toEntity();
    if (currentDoc == null) return;
    final updated = await Navigator.push<DoctorEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => AddDoctorPage(initialDoctor: currentDoc),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        _doctor = updated;
        _doctorData =
            DoctorData.fromEntity(updated).copyWith(isFavorite: _isFavorite);
      });
    }
  }

  String get _name =>
      _doctor?.name ?? _doctorData?.name ?? 'Doctor';

  String get _specialty =>
      _doctor?.specialty ??
      _doctorData?.specialty ??
      _doctor?.categoryName ??
      _doctorData?.category ??
      'Specialist';

  String get _address {
    final addr = _doctor?.address ?? _doctorData?.location ?? '';
    if (addr.isNotEmpty) return addr;
    return 'Medical Center, USA';
  }

  double get _rating =>
      _doctor?.rating ?? _doctorData?.rating ?? 5.0;

  int get _reviewsCount =>
      _doctor?.reviewsCount ?? _doctorData?.reviewCount ?? 0;

  String get _availableTime {
    final time = _doctor?.availableTime ??
        _doctorData?.availableTime ??
        '';
    if (time.trim().isNotEmpty) return time.trim();
    return 'Mon - Sat: 09:00 AM - 05:00 PM';
  }

  String get _imagePath =>
      _doctor?.imagePath ?? _doctorData?.imagePath ?? '';

  String get _formattedRating {
    if (_rating % 1 == 0) {
      return _rating.toInt().toString();
    }
    final fixed = _rating.toStringAsFixed(2);
    if (fixed.endsWith('0')) {
      return _rating.toStringAsFixed(1);
    }
    return fixed;
  }

  String get _formattedReviews {
    if (_reviewsCount >= 1000) {
      final thousands = _reviewsCount ~/ 1000;
      final remainder = (_reviewsCount % 1000).toString().padLeft(3, '0');
      return '$thousands,$remainder';
    }
    return _reviewsCount.toString();
  }

  Widget _buildDoctorImage() {
    final path = _imagePath.trim();
    final bgColor =
        _doctorData?.backgroundColor ?? const Color(0xFFFDE8E8);

    if (path.isNotEmpty) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return Image.network(
          path,
          width: 110.w,
          height: 110.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildAvatarPlaceholder(bgColor),
        );
      }
      return Image.asset(
        path,
        width: 110.w,
        height: 110.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
              _buildAvatarPlaceholder(bgColor),
      );
    }
    return _buildAvatarPlaceholder(bgColor);
  }

  Widget _buildAvatarPlaceholder(Color bgColor) {
    return Container(
      width: 110.w,
      height: 110.h,
      color: bgColor,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 56.r,
          color: AppColors.darkTeal.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.gray100, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: const Color(0x06000000),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20.r),
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: AppTextStyles.inter16W500.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTeal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: AppTextStyles.inter12W400.copyWith(
                fontSize: 11.sp,
                color: AppColors.gray500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColors.white,
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
          LocaleKeys.doctorDetails.tr(),
          style: AppTextStyles.inter18W700.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTeal,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isAdmin)
            IconButton(
              key: const Key('doctor_details_edit_button'),
              icon: Icon(
                Icons.edit_rounded,
                color: AppColors.darkTeal,
                size: 22.r,
              ),
              onPressed: _onEditDoctor,
            ),
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? Colors.red : AppColors.gray500,
              size: 24.r,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Profile Card
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.bannerBgStart,
                            AppColors.bannerBgEnd,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.lightTeal.withValues(alpha: 0.15),
                          width: 1.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkTeal.withValues(alpha: 0.08),
                            blurRadius: 16.r,
                            spreadRadius: 1.r,
                            offset: Offset(0, 6.h),
                          ),
                          BoxShadow(
                            color: const Color(0x06000000),
                            blurRadius: 8.r,
                            spreadRadius: 0,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: _buildDoctorImage(),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _name,
                                        style: AppTextStyles.inter18W700.copyWith(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkTeal,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isAdmin) ...[
                                      SizedBox(width: 4.w),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          key: const Key('doctor_card_edit_button'),
                                          onTap: _onEditDoctor,
                                          borderRadius: BorderRadius.circular(12.r),
                                          child: Container(
                                            padding: EdgeInsets.all(4.r),
                                            decoration: BoxDecoration(
                                              color: AppColors.darkTeal.withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.edit_rounded,
                                              color: AppColors.darkTeal,
                                              size: 14.r,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  _specialty,
                                  style: AppTextStyles.inter14W500.copyWith(
                                    fontSize: 13.sp,
                                    color: AppColors.gray600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 15.r,
                                      color: AppColors.gray500,
                                    ),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Text(
                                        _address,
                                        style: AppTextStyles.inter12W400.copyWith(
                                          fontSize: 12.sp,
                                          color: AppColors.gray600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // Quick Stats Row
                    Row(
                      children: [
                        _buildStatCard(
                          icon: Icons.star_rounded,
                          iconColor: const Color(0xFFFBBF24),
                          value: _formattedRating,
                          label: 'Rating',
                        ),
                        SizedBox(width: 12.w),
                        _buildStatCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          value: _formattedReviews,
                          label: LocaleKeys.reviews.tr(),
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h),

                    // Working Hours / Schedule Section
                    Text(
                      'Working Hours',
                      style: AppTextStyles.inter16W500.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTeal,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.gray100, width: 1.w),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: AppColors.darkTeal.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.access_time_rounded,
                              color: AppColors.darkTeal,
                              size: 20.r,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Schedule',
                                  style: AppTextStyles.inter14W500.copyWith(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkTeal,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  _availableTime,
                                  style: AppTextStyles.inter12W400.copyWith(
                                    fontSize: 12.sp,
                                    color: AppColors.gray500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            // Bottom Book Appointment Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0C000000),
                    blurRadius: 12.r,
                    offset: Offset(0, -4.h),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Appointment with $_name requested.'),
                        backgroundColor: AppColors.darkTeal,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkTeal,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    LocaleKeys.appointment.tr(),
                    style: AppTextStyles.inter16W500.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
