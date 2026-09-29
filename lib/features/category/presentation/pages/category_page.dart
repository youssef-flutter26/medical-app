import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/features/category/presentation/widgets/category_app_bar.dart';
import 'package:medical_app/features/category/presentation/widgets/category_grid_view.dart';
import 'package:medical_app/features/category/presentation/widgets/category_search_field.dart';
import 'package:medical_app/features/home/presentation/widgets/home_categories.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({
    super.key,
    this.onCategoryTap,
  });

  final ValueChanged<String>? onCategoryTap;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<CategoryData> _getAllCategories() => [
        CategoryData(
          title: LocaleKeys.dentistry.tr(),
          icon: Icons.cleaning_services_rounded,
          backgroundColor: const Color(0xFFF0FDF4),
          iconColor: const Color(0xFF16A34A),
        ),
        CategoryData(
          title: LocaleKeys.cardiology.tr(),
          icon: Icons.favorite_rounded,
          backgroundColor: const Color(0xFFFEF2F2),
          iconColor: const Color(0xFFDC2626),
        ),
        CategoryData(
          title: LocaleKeys.pulmonology.tr(),
          icon: Icons.air_rounded,
          backgroundColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
        ),
        CategoryData(
          title: LocaleKeys.general.tr(),
          icon: Icons.local_hospital_rounded,
          backgroundColor: const Color(0xFFFAF5FF),
          iconColor: const Color(0xFF9333EA),
        ),
        CategoryData(
          title: LocaleKeys.neurology.tr(),
          icon: Icons.psychology_rounded,
          backgroundColor: const Color(0xFFFFFBEB),
          iconColor: const Color(0xFFD97706),
        ),
        CategoryData(
          title: LocaleKeys.gastro.tr(),
          icon: Icons.medication_liquid_rounded,
          backgroundColor: const Color(0xFFECFDF5),
          iconColor: const Color(0xFF059669),
        ),
        CategoryData(
          title: LocaleKeys.laboratory.tr(),
          icon: Icons.biotech_rounded,
          backgroundColor: const Color(0xFFF0F9FF),
          iconColor: const Color(0xFF0284C7),
        ),
        CategoryData(
          title: LocaleKeys.vaccination.tr(),
          icon: Icons.vaccines_rounded,
          backgroundColor: const Color(0xFFFFF1F2),
          iconColor: const Color(0xFFE11D48),
        ),
      ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = _getAllCategories();
    final filteredCategories = _searchQuery.trim().isEmpty
        ? allCategories
        : allCategories
            .where(
              (c) => c.title
                  .toLowerCase()
                  .contains(_searchQuery.trim().toLowerCase()),
            )
            .toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CategoryAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategorySearchField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),
              SizedBox(height: 20.h),
              CategoryGridView(
                categories: filteredCategories,
                onCategoryTap: widget.onCategoryTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef CategoryScreen = CategoryPage;
