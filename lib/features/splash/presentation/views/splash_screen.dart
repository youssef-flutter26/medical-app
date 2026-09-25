import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/utils/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.splashDuration = const Duration(seconds: 2),
  });

  final Duration splashDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(
      widget.splashDuration,
      _navigateToOnboarding,
    );
  }

  void _navigateToOnboarding() {
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      Routes.onboarding,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 1.sw,
        height: 1.sh,
        child: Image.asset(
          AppAssets.imagesSplash,
          width: 1.sw,
          height: 1.sh,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}