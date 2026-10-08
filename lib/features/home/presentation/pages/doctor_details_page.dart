import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';

import '../../../appointment/presention/pages/book_appointment_page.dart';
import '../../../reviews/domain/entities/review_entity.dart';
import '../../../reviews/presentation/cubit/review_cubit.dart';
import '../../../reviews/presentation/cubit/review_state.dart';
import '../../../reviews/presentation/pages/add_review_page.dart';
import '../widgets/doctor_card.dart';

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
  State<DoctorDetailsPage> createState() =>
      _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  late bool _isFavorite;

  late final ReviewCubit _reviewCubit;

  DoctorEntity? _doctor;
  DoctorData? _doctorData;

  @override
  void initState() {
    super.initState();

    _doctor = widget.doctor;
    _doctorData = widget.doctorData;

    _isFavorite = widget.doctorData?.isFavorite ?? false;

    _reviewCubit = getIt<ReviewCubit>();

    _loadReviews();
  }

  @override
  void dispose() {
    _reviewCubit.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DoctorDetailsPage oldWidget,) {
    super.didUpdateWidget(oldWidget);

    if (widget.doctor != oldWidget.doctor) {
      _doctor = widget.doctor;

      _loadReviews();
    }

    if (widget.doctorData != oldWidget.doctorData) {
      _doctorData = widget.doctorData;
    }
  }

  Future<void> _loadReviews() async {
    final doctorId = _doctor?.id;

    if (doctorId == null || doctorId.isEmpty) {
      return;
    }

    await _reviewCubit.loadReviews(
      targetId: doctorId,
      targetType: 'doctor',
    );

    final user = _auth?.currentUser;

    if (user != null) {
      await _reviewCubit.loadMyReview(
        targetId: doctorId,
        userId: user.uid,
        targetType: 'doctor',
      );
    }
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

  Future<void> _onEditDoctor() async {
    final currentDoc =
        _doctor ?? _doctorData?.toEntity();

    if (currentDoc == null) {
      return;
    }

    final updated = await Navigator.push<DoctorEntity>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddDoctorPage(
              initialDoctor: currentDoc,
            ),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _doctor = updated;

        _doctorData = DoctorData.fromEntity(
          updated,
        ).copyWith(
          isFavorite: _isFavorite,
        );
      });

      _loadReviews();
    }
  }

  String get _name =>
      _doctor?.name ??
          _doctorData?.name ??
          'Doctor';

  String get _specialty =>
      _doctor?.specialty ??
          _doctorData?.specialty ??
          _doctor?.categoryName ??
          _doctorData?.category ??
          'Specialist';

  String get _address {
    final addr =
        _doctor?.address ??
            _doctorData?.location ??
            '';

    if (addr.isNotEmpty) {
      return addr;
    }

    return 'Medical Center, USA';
  }

  String get _imagePath =>
      _doctor?.imagePath ??
          _doctorData?.imagePath ??
          '';

  Widget _buildDoctorImage() {
    final path = _imagePath.trim();

    final bgColor =
        _doctorData?.backgroundColor ??
            const Color(0xFFFDE8E8);

    if (path.isNotEmpty) {
      if (path.startsWith('http://') ||
          path.startsWith('https://')) {
        return Image.network(
          path,
          width: 110.w,
          height: 110.h,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
              _buildAvatarPlaceholder(
                bgColor,
              ),
        );
      }

      return Image.asset(
        path,
        width: 110.w,
        height: 110.h,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) =>
            _buildAvatarPlaceholder(
              bgColor,
            ),
      );
    }

    return _buildAvatarPlaceholder(
      bgColor,
    );
  }

  Widget _buildAvatarPlaceholder(Color bgColor,) {
    return Container(
      width: 110.w,
      height: 110.h,
      color: bgColor,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 56.r,
          color: AppColors.darkTeal
              .withValues(alpha: 0.45),
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
        padding: EdgeInsets.symmetric(
          vertical: 14.h,
          horizontal: 8.w,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius:
          BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.gray100,
            width: 1.w,
          ),
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
                color: iconColor
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20.r,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style:
              AppTextStyles.inter16W500.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTeal,
              ),
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style:
              AppTextStyles.inter12W400.copyWith(
                fontSize: 11.sp,
                color: AppColors.gray500,
              ),
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _dayName(String day) {
    switch (day.toLowerCase()) {
      case 'sunday':
        return 'Sunday';
      case 'monday':
        return 'Monday';
      case 'tuesday':
        return 'Tuesday';
      case 'wednesday':
        return 'Wednesday';
      case 'thursday':
        return 'Thursday';
      case 'friday':
        return 'Friday';
      case 'saturday':
        return 'Saturday';
      default:
        return day;
    }
  }

  String _formatScheduleTime(String time) {
    final parts = time.split(':');

    if (parts.length != 2) {
      return time;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return time;
    }

    final timeOfDay = TimeOfDay(
      hour: hour,
      minute: minute,
    );

    final displayHour =
    timeOfDay.hourOfPeriod == 0
        ? 12
        : timeOfDay.hourOfPeriod;

    final displayMinute =
    timeOfDay.minute
        .toString()
        .padLeft(2, '0');

    final period =
    timeOfDay.period == DayPeriod.am
        ? 'AM'
        : 'PM';

    return '$displayHour:$displayMinute $period';
  }

  Widget _buildWorkingHours() {
    final doctor = _doctor;

    if (doctor == null ||
        doctor.schedule.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius:
          BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.gray100,
          ),
        ),
        child: Text(
          'Working hours are not available.',
          style:
          AppTextStyles.inter12W400.copyWith(
            color: AppColors.gray500,
          ),
        ),
      );
    }

    final enabledDays = doctor.schedule
        .where((item) => item.enabled)
        .toList();

    if (enabledDays.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius:
          BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.gray100,
          ),
        ),
        child: Text(
          'This doctor has no working hours.',
          style:
          AppTextStyles.inter12W400.copyWith(
            color: AppColors.gray500,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.gray100,
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0;
          i < enabledDays.length;
          i++) ...[
            Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: AppColors.darkTeal
                        .withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: AppColors.darkTeal,
                    size: 19.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _dayName(
                      enabledDays[i].day,
                    ),
                    style: AppTextStyles
                        .inter14W500
                        .copyWith(
                      fontWeight:
                      FontWeight.w600,
                      color:
                      AppColors.gray700,
                    ),
                  ),
                ),
                Text(
                  '${_formatScheduleTime(enabledDays[i].startTime)}'
                      ' - '
                      '${_formatScheduleTime(enabledDays[i].endTime)}',
                  style: AppTextStyles
                      .inter12W400
                      .copyWith(
                    fontSize: 12.sp,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    AppColors.darkTeal,
                  ),
                ),
              ],
            ),
            if (i != enabledDays.length - 1)
              Padding(
                padding:
                EdgeInsets.symmetric(
                  vertical: 10.h,
                ),
                child: Divider(
                  height: 1,
                  color: AppColors.gray100,
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _formatRating(double rating) {
    if (rating == 0) {
      return '—';
    }

    if (rating % 1 == 0) {
      return rating.toInt().toString();
    }

    final fixed = rating.toStringAsFixed(2);

    if (fixed.endsWith('0')) {
      return rating.toStringAsFixed(1);
    }

    return fixed;
  }

  String _formatReviews(int count) {
    if (count >= 1000) {
      final thousands = count ~/ 1000;

      final remainder = (count % 1000)
          .toString()
          .padLeft(3, '0');

      return '$thousands,$remainder';
    }

    return count.toString();
  }

  Widget _buildReviewsSection(ReviewState state,) {
    final reviews = state.reviews;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Reviews',
                style:
                AppTextStyles.inter16W500
                    .copyWith(
                  fontSize: 16.sp,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  AppColors.darkTeal,
                ),
              ),
            ),
            if (reviews.isNotEmpty)
              Text(
                '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
                style: AppTextStyles
                    .inter12W400
                    .copyWith(
                  color:
                  AppColors.gray500,
                ),
              ),
          ],
        ),

        SizedBox(height: 12.h),

        if (state.status ==
            ReviewStatus.loading &&
            reviews.isEmpty)
          Container(
            width: double.infinity,
            padding:
            EdgeInsets.all(24.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
              BorderRadius.circular(
                16.r,
              ),
              border: Border.all(
                color: AppColors.gray100,
              ),
            ),
            child: const Center(
              child:
              CircularProgressIndicator(),
            ),
          )
        else
          if (state.status ==
              ReviewStatus.failure &&
              reviews.isEmpty)
            Container(
              width: double.infinity,
              padding:
              EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                BorderRadius.circular(
                  16.r,
                ),
                border: Border.all(
                  color: AppColors.gray100,
                ),
              ),
              child: Text(
                state.errorMessage ??
                    'Failed to load doctor reviews.',
                style: AppTextStyles
                    .inter12W400
                    .copyWith(
                  color:
                  AppColors.gray500,
                ),
              ),
            )
          else
            if (reviews.isEmpty)
              Container(
                width: double.infinity,
                padding:
                EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                  BorderRadius.circular(
                    16.r,
                  ),
                  border: Border.all(
                    color: AppColors.gray100,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons
                          .rate_review_outlined,
                      size: 38.r,
                      color:
                      AppColors.gray400,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'No doctor reviews yet.',
                      style: AppTextStyles
                          .inter14W500
                          .copyWith(
                        color:
                        AppColors.gray600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Be the first to review this doctor.',
                      textAlign:
                      TextAlign.center,
                      style: AppTextStyles
                          .inter12W400
                          .copyWith(
                        color:
                        AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  for (int i = 0;
                  i < reviews.length;
                  i++) ...[
                    _buildReviewCard(
                      reviews[i],
                    ),
                    if (i !=
                        reviews.length - 1)
                      SizedBox(height: 10.h),
                  ],
                ],
              ),
      ],
    );
  }

  Widget _buildReviewCard(ReviewEntity review,) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.gray100,
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.darkTeal
                      .withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color:
                  AppColors.darkTeal,
                  size: 21.r,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      review.userName.isEmpty
                          ? 'User'
                          : review.userName,
                      style: AppTextStyles
                          .inter14W500
                          .copyWith(
                        fontWeight:
                        FontWeight.w700,
                        color:
                        AppColors.gray700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      _formatReviewDate(
                        review.createdAt,
                      ),
                      style: AppTextStyles
                          .inter12W400
                          .copyWith(
                        color:
                        AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    color:
                    const Color(
                      0xFFFBBF24,
                    ),
                    size: 18.r,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    _formatRating(
                      review.rating,
                    ),
                    style: AppTextStyles
                        .inter12W400
                        .copyWith(
                      fontWeight:
                      FontWeight.w700,
                      color:
                      AppColors.gray700,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Text(
            review.comment,
            style: AppTextStyles
                .inter12W400
                .copyWith(
              fontSize: 13.sp,
              color:
              AppColors.gray600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatReviewDate(DateTime date,) {
    final now = DateTime.now();
    final difference =
    now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    return DateFormat(
      'dd MMM yyyy',
    ).format(date);
  }

  Future<void> _openReviewPage(ReviewState state,) async {
    final doctor = _doctor;

    if (doctor == null ||
        doctor.id == null ||
        doctor.id!.isEmpty) {
      return;
    }

    final user = _auth?.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login first.',
          ),
        ),
      );

      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(
              value: _reviewCubit,
              child: AddReviewPage(
                targetId: doctor.id!,
                targetName: doctor.name,
                targetType: 'doctor',
                existingReview: state.myReview,
              ),
            ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      await _loadReviews();
    }
  }

  Widget _buildReviewButton(ReviewState state,) {
    final hasMyReview =
        state.myReview != null;

    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton.icon(
        onPressed: () =>
            _openReviewPage(state),
        icon: Icon(
          hasMyReview
              ? Icons.edit_rounded
              : Icons
              .rate_review_outlined,
          size: 19.r,
        ),
        label: Text(
          hasMyReview
              ? 'Edit Your Review'
              : 'Write a Review',
          style: AppTextStyles
              .inter14W500
              .copyWith(
            fontWeight:
            FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor:
          AppColors.darkTeal,
          side: BorderSide(
            color:
            AppColors.darkTeal,
            width: 1.w,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              14.r,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAdmin != null) {
      return BlocProvider.value(
        value: _reviewCubit,
        child: _buildScaffold(
          context,
          isAdmin:
          widget.isAdmin!,
        ),
      );
    }

    final firebaseAuth = _auth;
    final remoteDataSource =
        _userRemoteDataSource;

    if (firebaseAuth == null ||
        remoteDataSource == null) {
      return BlocProvider.value(
        value: _reviewCubit,
        child: _buildScaffold(
          context,
          isAdmin: false,
        ),
      );
    }

    return BlocProvider.value(
      value: _reviewCubit,
      child: StreamBuilder<User?>(
        stream:
        firebaseAuth.authStateChanges(),
        builder: (context,
            authSnapshot,) {
          final currentUser =
              authSnapshot.data ??
                  firebaseAuth.currentUser;

          if (currentUser == null) {
            return _buildScaffold(
              context,
              isAdmin: false,
            );
          }

          return StreamBuilder<UserModel?>(
            stream: remoteDataSource
                .getUserStream(
              currentUser.uid,
            ),
            builder: (context,
                userSnapshot,) {
              final isAdmin =
                  userSnapshot.data?.role ==
                      'admin';

              return _buildScaffold(
                context,
                isAdmin: isAdmin,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, {
    required bool isAdmin,
  }) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor:
        AppColors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppAssets.iconsBackIcon,
            width: 24.w,
            height: 24.h,
            colorFilter:
            const ColorFilter.mode(
              AppColors.darkTeal,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () =>
              Navigator.pop(context),
        ),
        title: Text(
          LocaleKeys.doctorDetails.tr(),
          style: AppTextStyles
              .inter18W700
              .copyWith(
            fontSize: 18.sp,
            fontWeight:
            FontWeight.w700,
            color:
            AppColors.darkTeal,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isAdmin)
            IconButton(
              key: const Key(
                'doctor_details_edit_button',
              ),
              icon: Icon(
                Icons.edit_rounded,
                color:
                AppColors.darkTeal,
                size: 22.r,
              ),
              onPressed:
              _onEditDoctor,
            ),
          IconButton(
            icon: Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons
                  .favorite_border_rounded,
              color: _isFavorite
                  ? Colors.red
                  : AppColors.gray500,
              size: 24.r,
            ),
            onPressed: () {
              setState(() {
                _isFavorite =
                !_isFavorite;
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
              child: BlocBuilder<
                  ReviewCubit,
                  ReviewState>(
                builder: (context,
                    reviewState,) {
                  final rating =
                      reviewState.averageRating;

                  final reviewsCount =
                      reviewState.reviewsCount;

                  return SingleChildScrollView(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Container(
                          padding:
                          EdgeInsets.all(16.r),
                          decoration:
                          BoxDecoration(
                            gradient:
                            const LinearGradient(
                              colors: [
                                AppColors
                                    .bannerBgStart,
                                AppColors
                                    .bannerBgEnd,
                              ],
                              begin:
                              Alignment
                                  .topLeft,
                              end: Alignment
                                  .bottomRight,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              20.r,
                            ),
                            border:
                            Border.all(
                              color: AppColors
                                  .lightTeal
                                  .withValues(
                                alpha: 0.15,
                              ),
                              width: 1.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors
                                    .darkTeal
                                    .withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius:
                                16.r,
                                spreadRadius:
                                1.r,
                                offset: Offset(
                                  0,
                                  6.h,
                                ),
                              ),
                              BoxShadow(
                                color:
                                const Color(
                                  0x06000000,
                                ),
                                blurRadius:
                                8.r,
                                offset: Offset(
                                  0,
                                  2.h,
                                ),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  16.r,
                                ),
                                child:
                                _buildDoctorImage(),
                              ),
                              SizedBox(
                                width: 16.w,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child:
                                          Text(
                                            _name,
                                            style: AppTextStyles
                                                .inter18W700
                                                .copyWith(
                                              fontSize:
                                              18.sp,
                                              fontWeight:
                                              FontWeight
                                                  .w700,
                                              color:
                                              AppColors
                                                  .darkTeal,
                                            ),
                                            maxLines:
                                            2,
                                            overflow:
                                            TextOverflow
                                                .ellipsis,
                                          ),
                                        ),
                                        if (isAdmin) ...[
                                          SizedBox(
                                            width:
                                            4.w,
                                          ),
                                          Material(
                                            color: Colors
                                                .transparent,
                                            child:
                                            InkWell(
                                              key:
                                              const Key(
                                                'doctor_card_edit_button',
                                              ),
                                              onTap:
                                              _onEditDoctor,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                12.r,
                                              ),
                                              child:
                                              Container(
                                                padding:
                                                EdgeInsets
                                                    .all(
                                                  4.r,
                                                ),
                                                decoration:
                                                BoxDecoration(
                                                  color: AppColors
                                                      .darkTeal
                                                      .withValues(
                                                    alpha:
                                                    0.1,
                                                  ),
                                                  shape:
                                                  BoxShape.circle,
                                                ),
                                                child:
                                                Icon(
                                                  Icons
                                                      .edit_rounded,
                                                  color:
                                                  AppColors.darkTeal,
                                                  size:
                                                  14.r,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(
                                      height: 6.h,
                                    ),
                                    Text(
                                      _specialty,
                                      style: AppTextStyles
                                          .inter14W500
                                          .copyWith(
                                        fontSize:
                                        13.sp,
                                        color:
                                        AppColors
                                            .gray600,
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                      ),
                                      maxLines:
                                      1,
                                      overflow:
                                      TextOverflow
                                          .ellipsis,
                                    ),
                                    SizedBox(
                                      height: 8.h,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .location_on_outlined,
                                          size: 15.r,
                                          color:
                                          AppColors
                                              .gray500,
                                        ),
                                        SizedBox(
                                          width: 4.w,
                                        ),
                                        Expanded(
                                          child:
                                          Text(
                                            _address,
                                            style: AppTextStyles
                                                .inter12W400
                                                .copyWith(
                                              fontSize:
                                              12.sp,
                                              color:
                                              AppColors
                                                  .gray600,
                                            ),
                                            maxLines:
                                            2,
                                            overflow:
                                            TextOverflow
                                                .ellipsis,
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

                        Row(
                          children: [
                            _buildStatCard(
                              icon:
                              Icons.star_rounded,
                              iconColor:
                              const Color(
                                0xFFFBBF24,
                              ),
                              value:
                              _formatRating(
                                rating,
                              ),
                              label:
                              'Rating',
                            ),
                            SizedBox(
                                width: 12.w),
                            _buildStatCard(
                              icon: Icons
                                  .chat_bubble_outline_rounded,
                              iconColor:
                              const Color(
                                0xFF3B82F6,
                              ),
                              value:
                              _formatReviews(
                                reviewsCount,
                              ),
                              label:
                              LocaleKeys
                                  .reviews
                                  .tr(),
                            ),
                          ],
                        ),

                        SizedBox(height: 22.h),

                        Text(
                          'Working Hours',
                          style: AppTextStyles
                              .inter16W500
                              .copyWith(
                            fontSize: 16.sp,
                            fontWeight:
                            FontWeight.w700,
                            color:
                            AppColors.darkTeal,
                          ),
                        ),

                        SizedBox(height: 10.h),

                        _buildWorkingHours(),

                        SizedBox(height: 24.h),

                        _buildReviewButton(
                          reviewState,
                        ),

                        SizedBox(height: 24.h),

                        _buildReviewsSection(
                          reviewState,
                        ),

                        SizedBox(height: 24.h),
                      ],
                    ),
                  );
                },
              ),
            ),

            Container(
              padding:
              EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color:
                    const Color(
                      0x0C000000,
                    ),
                    blurRadius: 12.r,
                    offset:
                    Offset(0, -4.h),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () {
                    final doctor = _doctor;

                    if (doctor == null) {
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookAppointmentPage(
                              doctor: doctor,
                            ),
                      ),
                    );
                  },
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.darkTeal,
                    foregroundColor:
                    AppColors.white,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14.r,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    LocaleKeys.appointment
                        .tr(),
                    style: AppTextStyles
                        .inter16W500
                        .copyWith(
                      fontSize: 16.sp,
                      fontWeight:
                      FontWeight.w700,
                      color:
                      AppColors.white,
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