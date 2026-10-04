import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/features/home/presentation/widgets/home_location.dart';
import 'package:medical_app/features/home/presentation/widgets/home_search.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onSearchTap;
  const HomeHeader({super.key, this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeLocation(),
        SizedBox(height: 18.h),
        HomeSearch(
          onTap: onSearchTap ??
              () {
                Navigator.pushNamed(context, Routes.categoryDoctors);
              },
        ),
      ],
    );
  }
}
