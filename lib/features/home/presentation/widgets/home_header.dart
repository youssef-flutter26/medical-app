import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/features/home/presentation/widgets/home_location.dart';
import 'package:medical_app/features/home/presentation/widgets/home_search.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeLocation(),
        SizedBox(height: 18.h),
        const HomeSearch(),
      ],
    );
  }
}
