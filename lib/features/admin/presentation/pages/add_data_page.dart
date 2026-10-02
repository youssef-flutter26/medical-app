import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/localization/locale_keys.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_data/admin_animated_card.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_data/admin_option_card.dart';

class AddDataPage extends StatefulWidget {
  const AddDataPage({super.key});

  @override
  State<AddDataPage> createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimations = List.generate(4, (index) {
      final start = index * 0.12;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnimations = List.generate(4, (index) {
      final start = index * 0.12;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          LocaleKeys.addData.tr(),
          style: AppTextStyles.inter16W500,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.manageHomeData.tr(),
                style: AppTextStyles.withColor(
                  AppTextStyles.inter20W600,
                  AppColors.darkTeal,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                LocaleKeys.chooseWhatYouWantToAdd.tr(),
                style: AppTextStyles.withColor(
                  AppTextStyles.inter14W400,
                  AppColors.gray500,
                ),
              ),
              SizedBox(height: 24.h),
              AdminAnimatedCard(
                fadeAnimation: _fadeAnimations[0],
                slideAnimation: _slideAnimations[0],
                child: AdminOptionCard(
                  title: LocaleKeys.banner.tr(),
                  subtitle: LocaleKeys.addPromotionalBanner.tr(),
                  icon: Icons.view_carousel_rounded,
                  iconColor: AppColors.lightTeal,
                  iconBgColor: AppColors.bannerBgStart,
                  onTap: () {
                    Navigator.pushNamed(context, Routes.addBanner);
                  },
                ),
              ),
              SizedBox(height: 14.h),
              AdminAnimatedCard(
                fadeAnimation: _fadeAnimations[1],
                slideAnimation: _slideAnimations[1],
                child: AdminOptionCard(
                  title: LocaleKeys.category.tr(),
                  subtitle: LocaleKeys.addMedicalCategory.tr(),
                  icon: Icons.category_rounded,
                  iconColor: AppColors.primary600,
                  iconBgColor: AppColors.primary600.withValues(alpha: 0.1),
                  onTap: () {
                    Navigator.pushNamed(context, Routes.addCategory);
                  },
                ),
              ),
              SizedBox(height: 14.h),
              AdminAnimatedCard(
                fadeAnimation: _fadeAnimations[2],
                slideAnimation: _slideAnimations[2],
                child: AdminOptionCard(
                  title: LocaleKeys.medicalCenter.tr(),
                  subtitle: LocaleKeys.addMedicalCenter.tr(),
                  icon: Icons.local_hospital_rounded,
                  iconColor: AppColors.red,
                  iconBgColor: AppColors.red.withValues(alpha: 0.1),
                  onTap: () {
                    Navigator.pushNamed(context, Routes.addMedicalCenter);
                  },
                ),
              ),
              SizedBox(height: 14.h),
              AdminAnimatedCard(
                fadeAnimation: _fadeAnimations[3],
                slideAnimation: _slideAnimations[3],
                child: AdminOptionCard(
                  title: LocaleKeys.doctor.tr(),
                  subtitle: LocaleKeys.addDoctor.tr(),
                  icon: Icons.medical_services_rounded,
                  iconColor: AppColors.amber,
                  iconBgColor: AppColors.amber.withValues(alpha: 0.14),
                  onTap: () {
                    Navigator.pushNamed(context, Routes.addDoctor);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef AddDataScreen = AddDataPage;
