import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/home/presentation/pages/home_screen.dart';
import 'package:medical_app/features/profile/presentation/pages/profile_screen.dart';

import '../../../features/location/presentation/pages/location_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [ 
    const HomeScreen(),
    LocationScreen(),
    // AppointmentScreen(),
    Center(child: Text(LocaleKeys.appointment.tr())),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.gray600,
        unselectedItemColor: AppColors.gray400,
        selectedIconTheme: const IconThemeData(color: AppColors.gray600),
        unselectedIconTheme: const IconThemeData(color: AppColors.gray400),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppAssets.iconsHome,
              colorFilter: const ColorFilter.mode(
                AppColors.gray400,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                AppAssets.iconsHome2,
              ),
            ),
            label: LocaleKeys.home.tr(),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppAssets.iconsLocation,
              colorFilter: const ColorFilter.mode(
                AppColors.gray400,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                AppAssets.iconsLocation2,
              ),
            ),
            label: LocaleKeys.location.tr(),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppAssets.iconsCalendar,
              colorFilter: const ColorFilter.mode(
                AppColors.gray400,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                AppAssets.iconsCalendar2,
              ),
            ),
            label: LocaleKeys.appointment.tr(),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppAssets.iconsProfile,
              colorFilter: const ColorFilter.mode(
                AppColors.gray400,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                AppAssets.iconsProfile2,
              ),
            ),
            label: LocaleKeys.profile.tr(),
          ),
        ],
      ),
    );
  }
}
