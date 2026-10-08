import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';

import '../../../reviews/domain/entities/review_entity.dart';
import '../../../reviews/presentation/cubit/review_cubit.dart';
import '../../../reviews/presentation/cubit/review_state.dart';
import '../../../reviews/presentation/pages/add_review_page.dart';

class MedicalCenterDetailsPage extends StatefulWidget {
  const MedicalCenterDetailsPage({super.key, required this.center});

  final MedicalCenterEntity center;

  @override
  State<MedicalCenterDetailsPage> createState() =>
      _MedicalCenterDetailsPageState();
}

class _MedicalCenterDetailsPageState extends State<MedicalCenterDetailsPage> {
  late final ReviewCubit _reviewCubit;

  @override
  void initState() {
    super.initState();

    _reviewCubit = getIt<ReviewCubit>();

    final centerId = widget.center.id;

    if (centerId == null || centerId.isEmpty) {
      return;
    }

    _reviewCubit.loadReviews(targetId: centerId, targetType: 'medicalCenter');

    final user = getIt<FirebaseAuth>().currentUser;

    if (user != null) {
      _reviewCubit.loadMyReview(
        targetId: centerId,
        targetType: 'medicalCenter',
        userId: user.uid,
      );
    }
  }

  @override
  void dispose() {
    _reviewCubit.close();
    super.dispose();
  }

  Future<void> _openReviewPage() async {
    final centerId = widget.center.id;

    if (centerId == null || centerId.isEmpty) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _reviewCubit,
          child: AddReviewPage(
            targetId: centerId,
            targetName: widget.center.name,
            targetType: 'medicalCenter',
            existingReview: _reviewCubit.state.myReview,
          ),
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _reviewCubit.loadReviews(
      targetId: centerId,
      targetType: 'medicalCenter',
    );

    final user = getIt<FirebaseAuth>().currentUser;

    if (user != null) {
      await _reviewCubit.loadMyReview(
        targetId: centerId,
        targetType: 'medicalCenter',
        userId: user.uid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _reviewCubit,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Medical Center Details',
            style: AppTextStyles.inter16W500,
          ),
        ),
        body: BlocBuilder<ReviewCubit, ReviewState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(),
                  SizedBox(height: 18.h),
                  Text(
                    widget.center.name,
                    style: AppTextStyles.inter20W600.copyWith(
                      color: AppColors.darkTeal,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.center.type,
                    style: AppTextStyles.inter14W400.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  _buildInfoCard(
                    icon: Icons.location_on_outlined,
                    title: 'Address',
                    value: widget.center.address,
                  ),
                  if (widget.center.latitude != null &&
                      widget.center.longitude != null)
                    _buildInfoCard(
                      icon: Icons.map_outlined,
                      title: 'Coordinates',
                      value:
                          '${widget.center.latitude}, '
                          '${widget.center.longitude}',
                    ),
                  _buildInfoCard(
                    icon: Icons.near_me_outlined,
                    title: 'Distance',
                    value: widget.center.formattedDistance,
                  ),
                  SizedBox(height: 22.h),
                  _buildRatingSection(state),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reviews',
                        style: AppTextStyles.inter18W700.copyWith(
                          color: AppColors.darkTeal,
                        ),
                      ),
                      Text(
                        '${state.reviewsCount}',
                        style: AppTextStyles.inter14W500.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  if (state.status == ReviewStatus.loading)
                    const Center(child: CircularProgressIndicator())
                  else if (state.reviews.isEmpty)
                    _buildEmptyReviews()
                  else
                    ...state.reviews.map(_buildReviewCard),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: _openReviewPage,
                      icon: Icon(
                        state.myReview == null
                            ? Icons.rate_review_outlined
                            : Icons.edit_outlined,
                      ),
                      label: Text(
                        state.myReview == null
                            ? 'Write a Review'
                            : 'Edit Your Review',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkTeal,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImage() {
    final path = widget.center.imagePath.trim();

    if (path.isEmpty) {
      return _imagePlaceholder();
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Image.network(
          path,
          width: double.infinity,
          height: 220.h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _imagePlaceholder();
          },
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: Image.asset(
        path,
        width: double.infinity,
        height: 220.h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imagePlaceholder();
        },
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 220.h,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Icon(
        Icons.local_hospital_outlined,
        size: 70.r,
        color: AppColors.gray400,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.darkTeal, size: 24.r),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.inter12W400.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: AppTextStyles.inter14W500.copyWith(
                    color: AppColors.gray700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(ReviewState state) {
    final rating = state.averageRating;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Text(
            rating == 0 ? '0.0' : rating.toStringAsFixed(1),
            style: AppTextStyles.inter20W600.copyWith(
              color: AppColors.darkTeal,
            ),
          ),
          SizedBox(width: 12.w),
          const Icon(Icons.star_rounded, color: Color(0xFFFBBF24)),
          SizedBox(width: 8.w),
          Text(
            '${state.reviewsCount} reviews',
            style: AppTextStyles.inter14W400.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 42.r,
            color: AppColors.gray400,
          ),
          SizedBox(height: 10.h),
          Text(
            'No reviews yet.',
            style: AppTextStyles.inter14W500.copyWith(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewEntity review) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.gray100,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U',
                  style: AppTextStyles.inter14W500.copyWith(
                    color: AppColors.darkTeal,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  review.userName,
                  style: AppTextStyles.inter14W500.copyWith(
                    color: AppColors.gray700,
                  ),
                ),
              ),
              Text(
                review.rating.toStringAsFixed(1),
                style: AppTextStyles.inter12W400.copyWith(
                  color: AppColors.gray500,
                ),
              ),
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: Color(0xFFFBBF24),
              ),
            ],
          ),
          if (review.comment.trim().isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              review.comment,
              style: AppTextStyles.inter14W400.copyWith(
                color: AppColors.gray600,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
