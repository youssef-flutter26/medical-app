import 'package:flutter/material.dart';
import 'package:medical_app/core/common/pages/main_layout.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/features/admin/presentation/pages/add_banner_screen.dart';
import 'package:medical_app/features/admin/presentation/pages/add_category_screen.dart';
import 'package:medical_app/features/admin/presentation/pages/add_data_screen.dart';
import 'package:medical_app/features/admin/presentation/pages/add_doctor_screen.dart';
import 'package:medical_app/features/admin/presentation/pages/add_medical_center_screen.dart';
import 'package:medical_app/features/auth/presentation/pages/forget_password_screen.dart';
import 'package:medical_app/features/auth/presentation/pages/login_screen.dart';
import 'package:medical_app/features/auth/presentation/pages/register_screen .dart';
import 'package:medical_app/features/auth/presentation/widgets/fill_profile.dart';
import 'package:medical_app/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:medical_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:medical_app/features/splash/presentation/pages/splash_screen.dart';

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
          builder: (_) => const AddDataScreen(),
          settings: settings,
        );

      case Routes.addBanner:
        return MaterialPageRoute(
          builder: (_) => const AddBannerScreen(),
          settings: settings,
        );

      case Routes.addCategory:
        return MaterialPageRoute(
          builder: (_) => const AddCategoryScreen(),
          settings: settings,
        );

      case Routes.addMedicalCenter:
        return MaterialPageRoute(
          builder: (_) => const AddMedicalCenterScreen(),
          settings: settings,
        );

      case Routes.addDoctor:
        return MaterialPageRoute(
          builder: (_) => const AddDoctorScreen(),
          settings: settings,
        );

      case Routes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      default:
        return null;
    }
  }
}
