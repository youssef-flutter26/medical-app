import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/admin/presentation/pages/add_medical_center_page.dart';
import 'package:medical_app/features/home/presentation/widgets/category_app_bar.dart';
import 'package:medical_app/features/home/presentation/widgets/category_search_field.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/usecases/get_medical_centers_stream.dart';
import 'package:medical_app/features/home/presentation/widgets/medical_center_details_sheet.dart';
import 'package:medical_app/features/home/presentation/widgets/medical_center_item.dart';

class NearbyMedicalCentersPage extends StatefulWidget {
  final GetMedicalCentersStream? getMedicalCentersStream;
  final Stream<List<MedicalCenterEntity>>? medicalCentersStream;
  final bool isAdmin;
  final ValueChanged<MedicalCenterEntity>? onCenterTap;

  const NearbyMedicalCentersPage({
    super.key,
    this.getMedicalCentersStream,
    this.medicalCentersStream,
    this.isAdmin = false,
    this.onCenterTap,
  });

  @override
  State<NearbyMedicalCentersPage> createState() =>
      _NearbyMedicalCentersPageState();
}

class _NearbyMedicalCentersPageState extends State<NearbyMedicalCentersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Stream<List<MedicalCenterEntity>>? _stream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    if (widget.medicalCentersStream != null) {
      _stream = widget.medicalCentersStream;
    } else if (widget.getMedicalCentersStream != null) {
      _stream = widget.getMedicalCentersStream!();
    } else if (getIt.isRegistered<GetMedicalCentersStream>()) {
      _stream = getIt<GetMedicalCentersStream>()();
    } else {
      _stream = Stream.value(const <MedicalCenterEntity>[]);
    }
  }

  @override
  void didUpdateWidget(covariant NearbyMedicalCentersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.medicalCentersStream != oldWidget.medicalCentersStream ||
        widget.getMedicalCentersStream != oldWidget.getMedicalCentersStream) {
      _initStream();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleCenterTap(MedicalCenterEntity center) {
    if (widget.onCenterTap != null) {
      widget.onCenterTap!(center);
      return;
    }
    showMedicalCenterDetailsSheet(
      context,
      center,
      isAdmin: widget.isAdmin,
      onEdit: () => _navigateToEdit(center),
    );
  }

  void _navigateToEdit(MedicalCenterEntity center) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicalCenterPage(
          initialMedicalCenter: center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CategoryAppBar(
        title: LocaleKeys.nearbyMedicalCenters.tr(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategorySearchField(
                controller: _searchController,
                hintText: 'Search medical centers...',
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
              StreamBuilder<List<MedicalCenterEntity>>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 48.h),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: AppColors.darkTeal,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      alignment: Alignment.center,
                      child: Text(
                        '${snapshot.error}',
                        style: AppTextStyles.withColor(
                          AppTextStyles.inter14W400,
                          Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final allCenters =
                      snapshot.data ?? const <MedicalCenterEntity>[];
                  if (allCenters.isEmpty) {
                    return _buildEmptyState();
                  }

                  final query = _searchQuery.trim().toLowerCase();
                  final filteredCenters = query.isEmpty
                      ? allCenters
                      : allCenters.where((center) {
                          final nameMatches =
                              center.name.toLowerCase().contains(query);
                          final addressMatches =
                              center.address.toLowerCase().contains(query);
                          final typeMatches =
                              center.type.toLowerCase().contains(query);
                          return nameMatches || addressMatches || typeMatches;
                        }).toList();

                  if (filteredCenters.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredCenters.length,
                    separatorBuilder: (_, _) => SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final center = filteredCenters[index];
                      return MedicalCenterItem(
                        name: center.name,
                        address: center.address,
                        rating: center.rating,
                        reviewCount: center.reviewsCount,
                        distance: center.formattedDistance,
                        duration: center.formattedDuration,
                        type: center.type,
                        imagePath: center.imagePath,
                        imageUrl: center.imagePath.startsWith('http')
                            ? center.imagePath
                            : null,
                        isAdmin: widget.isAdmin,
                        isFullWidth: true,
                        onTap: () => _handleCenterTap(center),
                        onEdit: widget.isAdmin
                            ? () => _navigateToEdit(center)
                            : null,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.r,
              height: 64.r,
              decoration: const BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.local_hospital_outlined,
                size: 32.r,
                color: AppColors.gray400,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              LocaleKeys.contentNotFound.tr(),
              style: AppTextStyles.withColor(
                AppTextStyles.inter16W500,
                AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
