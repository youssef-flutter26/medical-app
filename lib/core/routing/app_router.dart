import 'package:flutter/material.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/features/auth/presentation/pages/login_screen.dart';
import 'package:medical_app/features/auth/presentation/widgets/fill_profile.dart';
import 'package:medical_app/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:medical_app/features/splash/presentation/views/splash_screen.dart';

import '../../features/auth/presentation/pages/forget_password_screen.dart';
import '../../features/auth/presentation/pages/register_screen .dart';

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
          builder: (_) =>
              FillProfile(
                name: name,
                email: email,
              ),
          settings: settings,
        );

      default:
        return null;
    }
  }
}