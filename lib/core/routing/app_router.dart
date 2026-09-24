import 'package:flutter/material.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/features/auth/presentation/pages/login_screen.dart';
import 'package:medical_app/features/auth/presentation/pages/register_screen%20.dart';
import 'package:medical_app/features/auth/presentation/widgets/fill_profile.dart';
import 'package:medical_app/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:medical_app/features/splash/presentation/views/splash_screen.dart';

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
      case Routes.fillProfile:
        return MaterialPageRoute(
          builder: (_) => const FillProfile(),
          settings: settings,
        );
      case Routes.register:
        return MaterialPageRoute(
          builder: (_) => const RigesterScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
