import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';
import '../widgets/favorite_doctor_card.dart';
import '../widgets/favorite_hospital_card.dart';
import '../widgets/favorites_empty_state.dart';
import '../widgets/favorites_tab_bar.dart';
import '../widgets/remove_favorite_bottom_sheet.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  Future<void> _handleDoctorRemoval(
    BuildContext context,
    DoctorEntity doctor,
  ) async {
    final confirmed = await RemoveFavoriteBottomSheet.show(
      context,
      doctor: doctor,
    );

    if (confirmed == true && context.mounted) {
      if (doctor.id != null && doctor.id!.isNotEmpty) {
        context.read<FavoritesCubit>().removeDoctorFavorite(doctor.id!);
      }
    }
  }

  Future<void> _handleMedicalCenterRemoval(
    BuildContext context,
    MedicalCenterEntity center,
  ) async {
    final confirmed = await RemoveFavoriteBottomSheet.show(
      context,
      medicalCenter: center,
    );

    if (confirmed == true && context.mounted) {
      if (center.id != null && center.id!.isNotEmpty) {
        context.read<FavoritesCubit>().removeMedicalCenterFavorite(center.id!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
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
          LocaleKeys.favorites.tr(),
          style: AppTextStyles.inter18W700.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTeal,
          ),
        ),
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          final cubit = context.read<FavoritesCubit>();

          return Column(
            children: [
              FavoritesTabBar(
                selectedIndex: state.selectedTab,
                onTabSelected: (index) => cubit.setTab(index),
              ),
              Expanded(
                child: state.isLoading &&
                        state.allDoctors.isEmpty &&
                        state.allMedicalCenters.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.darkTeal,
                        ),
                      )
                    : state.selectedTab == 0
                        ? _buildDoctorsList(context, state)
                        : _buildHospitalsList(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDoctorsList(BuildContext context, FavoritesState state) {
    final favoriteDoctors = state.favoriteDoctors;

    if (favoriteDoctors.isEmpty) {
      return const FavoritesEmptyState(isDoctor: true);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: favoriteDoctors.length,
      itemBuilder: (context, index) {
        final doctor = favoriteDoctors[index];
        return FavoriteDoctorCard(
          doctor: doctor,
          index: index,
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.doctorDetails,
              arguments: doctor,
            );
          },
          onFavoriteTap: () => _handleDoctorRemoval(context, doctor),
        );
      },
    );
  }

  Widget _buildHospitalsList(BuildContext context, FavoritesState state) {
    final favoriteCenters = state.favoriteMedicalCenters;

    if (favoriteCenters.isEmpty) {
      return const FavoritesEmptyState(isDoctor: false);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: favoriteCenters.length,
      itemBuilder: (context, index) {
        final center = favoriteCenters[index];
        return FavoriteHospitalCard(
          center: center,
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.medicalCenterDetails,
              arguments: center,
            );
          },
          onFavoriteTap: () => _handleMedicalCenterRemoval(context, center),
        );
      },
    );
  }
}
