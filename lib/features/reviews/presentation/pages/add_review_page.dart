import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';

import '../../domain/entities/review_entity.dart';
import '../cubit/review_cubit.dart';

class AddReviewPage extends StatefulWidget {
  const AddReviewPage({
    super.key,
    required this.targetId,
    required this.targetName,
    required this.targetType,
    this.existingReview,
  });

  final String targetId;
  final String targetName;
  final String targetType;
  final ReviewEntity? existingReview;

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  late final TextEditingController _commentController;

  double _rating = 5.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _rating = widget.existingReview?.rating ?? 5.0;

    _commentController = TextEditingController(
      text: widget.existingReview?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_isLoading) return;

    final user = getIt<FirebaseAuth>().currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first to submit a review.')),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    final review = ReviewEntity(
      id: widget.existingReview?.id ?? '${widget.targetId}_${user.uid}',
      targetId: widget.targetId,
      targetType: widget.targetType,
      userId: user.uid,
      userName: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : user.email ?? 'User',
      rating: _rating,
      comment: _commentController.text.trim(),
      createdAt: widget.existingReview?.createdAt ?? DateTime.now(),
    );

    final cubit = context.read<ReviewCubit>();

    final success = await cubit.submitReview(review: review);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cubit.state.errorMessage ?? 'Failed to submit review.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingReview != null;

    return Scaffold(
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
          isEdit ? 'Edit Review' : 'Write a Review',
          style: AppTextStyles.inter16W500,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.targetName,
                style: AppTextStyles.inter20W600.copyWith(
                  color: AppColors.darkTeal,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'How was your experience?',
                style: AppTextStyles.inter14W400.copyWith(
                  color: AppColors.gray500,
                ),
              ),
              SizedBox(height: 28.h),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final value = index + 1;

                    return IconButton(
                      onPressed: () {
                        setState(() {
                          _rating = value.toDouble();
                        });
                      },
                      icon: Icon(
                        value <= _rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: const Color(0xFFFBBF24),
                        size: 40.r,
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Your Review',
                style: AppTextStyles.inter14W500.copyWith(
                  color: AppColors.darkTeal,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _commentController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Write your experience...',
                  filled: true,
                  fillColor: AppColors.gray100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkTeal,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 22.r,
                          height: 22.r,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEdit ? 'Update Review' : 'Submit Review',
                          style: AppTextStyles.inter16W500.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
