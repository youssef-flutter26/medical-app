import 'package:flutter/material.dart';
import 'package:medical_app/core/common/pages/main_layout.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/features/admin/presentation/pages/add_banner_page.dart';
import 'package:medical_app/features/admin/presentation/pages/add_category_page.dart';
import 'package:medical_app/features/admin/presentation/pages/add_data_page.dart';
import 'package:medical_app/features/admin/presentation/pages/add_doctor_page.dart';
import 'package:medical_app/features/admin/presentation/pages/add_medical_center_page.dart';
import 'package:medical_app/features/auth/presentation/pages/forget_password_screen.dart';
import 'package:medical_app/features/auth/presentation/pages/login_screen.dart';
import 'package:medical_app/features/auth/presentation/pages/register_screen .dart';
import 'package:medical_app/features/auth/presentation/widgets/fill_profile.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/usecases/get_categories_stream.dart';
import 'package:medical_app/features/home/presentation/pages/all_medical_centers_page.dart';
import 'package:medical_app/features/home/presentation/pages/category_doctors_page.dart';
import 'package:medical_app/features/home/presentation/pages/category_page.dart';
import 'package:medical_app/features/home/presentation/pages/doctor_details_page.dart';
import 'package:medical_app/features/home/presentation/widgets/doctor_card.dart';
import 'package:medical_app/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:medical_app/features/splash/presentation/pages/splash_screen.dart';

import '../../features/home/presentation/pages/medical_center_details_page.dart';

class AppRouter {
  Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case Routes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      case Routes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case Routes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case Routes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );

      case Routes.fillProfile:
        final arguments = settings.arguments;

        String name = '';
        String email = '';

        if (arguments is Map<String, dynamic>) {
          name = arguments['name'] as String? ?? '';
          email = arguments['email'] as String? ?? '';
        }

        return MaterialPageRoute(
          builder: (_) => FillProfile(name: name, email: email),
          settings: settings,
        );

      case Routes.mainLayout:
        return MaterialPageRoute(
          builder: (_) => const MainLayout(),
          settings: settings,
        );

      case Routes.adminDataSelection:
        return MaterialPageRoute(
          builder: (_) => const AddDataPage(),
          settings: settings,
        );

      case Routes.addBanner:
        final initialBanner = settings.arguments is BannerEntity
            ? settings.arguments as BannerEntity
            : null;
        return MaterialPageRoute(
          builder: (_) => AddBannerPage(initialBanner: initialBanner),
          settings: settings,
        );

      case Routes.addCategory:
        final initialCategory = settings.arguments is CategoryEntity
            ? settings.arguments as CategoryEntity
            : null;
        return MaterialPageRoute(
          builder: (_) => AddCategoryPage(initialCategory: initialCategory),
          settings: settings,
        );

      case Routes.addMedicalCenter:
        final initialMedicalCenter = settings.arguments is MedicalCenterEntity
            ? settings.arguments as MedicalCenterEntity
            : null;
        return MaterialPageRoute(
          builder: (_) => AddMedicalCenterPage(
            initialMedicalCenter: initialMedicalCenter,
          ),
          settings: settings,
        );

      case Routes.medicalCenterDetails:
        final medicalCenter =
        settings.arguments is MedicalCenterEntity
            ? settings.arguments as MedicalCenterEntity
            : null;

        if (medicalCenter == null) {
          return null;
        }

        return MaterialPageRoute(
          builder: (_) =>
              MedicalCenterDetailsPage(
                center: medicalCenter,
              ),
          settings: settings,
        );

      case Routes.category:
        Stream<List<CategoryEntity>>? categoriesStream;
        GetCategoriesStream? getCategoriesStream;
        if (settings.arguments is Stream<List<CategoryEntity>>) {
          categoriesStream = settings.arguments as Stream<List<CategoryEntity>>;
        } else if (settings.arguments is GetCategoriesStream) {
          getCategoriesStream = settings.arguments as GetCategoriesStream;
        }
        return MaterialPageRoute(
          builder: (_) => CategoryPage(
            categoriesStream: categoriesStream,
            getCategoriesStream: getCategoriesStream,
          ),
          settings: settings,
        );

      case Routes.categoryDoctors:
        final categoryEntity = settings.arguments is CategoryEntity
            ? settings.arguments as CategoryEntity
            : null;
        final categoryName = settings.arguments is String
            ? settings.arguments as String
            : categoryEntity?.name;
        return MaterialPageRoute(
          builder: (_) => CategoryDoctorsPage(
            category: categoryEntity,
            categoryName: categoryName,
          ),
          settings: settings,
        );

      case Routes.doctorDetails:
        final doctorArg = settings.arguments;
        DoctorEntity? doctorEntity;
        DoctorData? doctorData;

        if (doctorArg is DoctorEntity) {
          doctorEntity = doctorArg;
        } else if (doctorArg is DoctorData) {
          doctorData = doctorArg;
          doctorEntity = doctorArg.toEntity();
        }

        return MaterialPageRoute(
          builder: (_) => DoctorDetailsPage(
            doctor: doctorEntity,
            doctorData: doctorData,
          ),
          settings: settings,
        );

      case Routes.addDoctor:
        final doctorArg = settings.arguments;
        DoctorEntity? initialDoctor;
        if (doctorArg is DoctorEntity) {
          initialDoctor = doctorArg;
        } else if (doctorArg is DoctorData) {
          initialDoctor = doctorArg.toEntity();
        }
        return MaterialPageRoute(
          builder: (_) => AddDoctorPage(initialDoctor: initialDoctor),
          settings: settings,
        );
      case Routes.allMedicalCenters:
        final medicalCenters =
        settings.arguments is List<MedicalCenterEntity>
            ? settings.arguments as List<MedicalCenterEntity>
            : <MedicalCenterEntity>[];


        return MaterialPageRoute(
          builder: (_) =>
              AllMedicalCentersPage(
                medicalCenters: medicalCenters,
              ),
          settings: settings,
        );




      default:
        return null;
    }
  }
}
