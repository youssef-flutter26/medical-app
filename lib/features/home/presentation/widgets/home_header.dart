import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/features/home/presentation/widgets/home_location.dart';
import 'package:medical_app/features/home/presentation/widgets/home_search.dart';

class HomeHeader extends StatelessWidget {
  final String location;
  final VoidCallback? onSearchTap;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClear;

  const HomeHeader({
    super.key,
    this.location = 'Current Location',
    this.onSearchTap,
    this.searchController,
    this.onSearchChanged,
    this.onSearchClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeLocation(
          location: location,
        ),
        SizedBox(height: 18.h),
        HomeSearch(
          controller: searchController,
          onChanged: onSearchChanged,
          onClear: onSearchClear,
          onTap: onSearchTap,
        ),
      ],
    );
  }
}