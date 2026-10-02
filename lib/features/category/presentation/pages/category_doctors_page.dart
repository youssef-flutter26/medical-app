import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/category/presentation/widgets/category_doctors/category_doctors_header.dart';
import 'package:medical_app/features/category/presentation/widgets/category_doctors/category_doctors_list.dart';
import 'package:medical_app/features/category/presentation/widgets/category_doctors/doctor_card.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';

class CategoryDoctorsPage extends StatefulWidget {
  final String? categoryName;
  final CategoryEntity? category;
  final String? pageTitle;
  final List<DoctorData>? initialDoctors;
  final int? resultsCount;

  const CategoryDoctorsPage({
    super.key,
    this.categoryName,
    this.category,
    this.pageTitle,
    this.initialDoctors,
    this.resultsCount,
  });

  @override
  State<CategoryDoctorsPage> createState() => _CategoryDoctorsPageState();
}

class _CategoryDoctorsPageState extends State<CategoryDoctorsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late List<DoctorData> _doctors;

  static const List<DoctorData> _defaultDoctors = [
    DoctorData(
      id: '1',
      name: 'Dr. David Patel',
      specialty: 'Cardiologist',
      category: 'Cardiology',
      location: 'Cardiology Center, USA',
      rating: 5.0,
      reviewCount: 1872,
      backgroundColor: Color(0xFFFCE7F3),
    ),
    DoctorData(
      id: '2',
      name: 'Dr. Jessica Turner',
      specialty: 'Gynecologist',
      category: 'Gynecology',
      location: "Women's Clinic,Seattle,USA",
      rating: 4.9,
      reviewCount: 127,
      backgroundColor: Color(0xFFFFEDD5),
    ),
    DoctorData(
      id: '3',
      name: 'Dr. Michael Johnson',
      specialty: 'Orthopedic Surgery',
      category: 'Orthopedics',
      location: 'Maple Associates, NY,USA',
      rating: 4.7,
      reviewCount: 5223,
      backgroundColor: Color(0xFFCCFBF1),
    ),
    DoctorData(
      id: '4',
      name: 'Dr. Emily Walker',
      specialty: 'Pediatrics',
      category: 'Pediatrics',
      location: 'Serenity Pediatrics Clinic',
      rating: 5.0,
      reviewCount: 405,
      backgroundColor: Color(0xFFF1F5F9),
    ),
    DoctorData(
      id: '5',
      name: 'Dr. Emily Walker',
      specialty: 'Pediatrics',
      category: 'Pediatrics',
      location: 'Serenity Pediatrics Clinic',
      rating: 4.8,
      reviewCount: 310,
      backgroundColor: Color(0xFFFCE7F3),
    ),
    DoctorData(
      id: '6',
      name: 'Dr. Robert Chen',
      specialty: 'Pulmonologist',
      category: 'Pulmonology',
      location: 'Chest & Lung Clinic, USA',
      rating: 4.8,
      reviewCount: 420,
      backgroundColor: Color(0xFFEFF6FF),
    ),
    DoctorData(
      id: '7',
      name: 'Dr. Sarah Jenkins',
      specialty: 'Neurologist',
      category: 'Neurology',
      location: 'Neurological Institute, NY, USA',
      rating: 4.9,
      reviewCount: 890,
      backgroundColor: Color(0xFFFFFBEB),
    ),
    DoctorData(
      id: '8',
      name: 'Dr. Alexander Hayes',
      specialty: 'General Practitioner',
      category: 'General',
      location: 'City General Hospital, USA',
      rating: 4.6,
      reviewCount: 654,
      backgroundColor: Color(0xFFFAF5FF),
    ),
    DoctorData(
      id: '9',
      name: 'Dr. Maria Santos',
      specialty: 'Dentist',
      category: 'Dentistry',
      location: 'Bright Smile Dental Clinic',
      rating: 4.9,
      reviewCount: 1420,
      backgroundColor: Color(0xFFF0FDF4),
    ),
    DoctorData(
      id: '10',
      name: 'Dr. Linda Martinez',
      specialty: 'Gastroenterologist',
      category: 'Gastro',
      location: 'Digestive Health Clinic, USA',
      rating: 4.8,
      reviewCount: 520,
      backgroundColor: Color(0xFFECFDF5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _doctors = widget.initialDoctors != null
        ? List<DoctorData>.from(widget.initialDoctors!)
        : List<DoctorData>.from(_defaultDoctors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _effectiveCategoryName {
    if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
      return widget.categoryName!;
    }
    if (widget.category != null && widget.category!.name.isNotEmpty) {
      return widget.category!.name;
    }
    return '';
  }

  String get _effectiveTitle {
    if (widget.pageTitle != null && widget.pageTitle!.isNotEmpty) {
      return widget.pageTitle!;
    }
    return LocaleKeys.allDoctors.tr();
  }

  List<DoctorData> get _filteredDoctors {
    final selectedCategory = _effectiveCategoryName;
    final hasCategoryFilter = selectedCategory.isNotEmpty &&
        selectedCategory.toLowerCase() != 'all doctors';

    final categoryFiltered = hasCategoryFilter
        ? _doctors.where((d) {
            final cat = d.category?.toLowerCase() ?? '';
            final spec = d.specialty.toLowerCase();
            final target = selectedCategory.toLowerCase();
            return cat == target ||
                spec.contains(target) ||
                target.contains(cat);
          }).toList()
        : _doctors;

    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return categoryFiltered;
    }

    return categoryFiltered.where((d) {
      return d.name.toLowerCase().contains(query) ||
          d.specialty.toLowerCase().contains(query) ||
          d.location.toLowerCase().contains(query);
    }).toList();
  }

  int get _effectiveResultsCount {
    if (widget.resultsCount != null) {
      return widget.resultsCount!;
    }
    final selectedCategory = _effectiveCategoryName;
    final hasCategoryFilter = selectedCategory.isNotEmpty &&
        selectedCategory.toLowerCase() != 'all doctors';

    if (hasCategoryFilter || _searchQuery.trim().isNotEmpty) {
      return _filteredDoctors.length;
    }
    return 532;
  }

  void _toggleFavorite(DoctorData doctor) {
    setState(() {
      final index = _doctors.indexWhere((d) => d.id == doctor.id);
      if (index != -1) {
        _doctors[index] = doctor.copyWith(isFavorite: !doctor.isFavorite);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _filteredDoctors;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
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
          _effectiveTitle,
          style: AppTextStyles.inter18W700.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTeal,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryDoctorsHeader(
                searchController: _searchController,
                resultsCount: _effectiveResultsCount,
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onClearSearch: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),
              SizedBox(height: 16.h),
              CategoryDoctorsList(
                doctors: doctors,
                onFavoriteTap: _toggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
