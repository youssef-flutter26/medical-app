import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.splashDuration = const Duration(seconds: 2),
    this.auth,
  });

  final Duration splashDuration;
  final FirebaseAuth? auth;

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
    _timer = Timer(widget.splashDuration, _handleStartupDecision);
  }

  Future<void> _handleStartupDecision() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding =
        prefs.getBool('hasSeenOnboarding') ??
        prefs.getBool('isOnboardingSeen') ??
        prefs.getBool('onboarding_seen') ??
        false;

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, Routes.onboarding);
      return;
    }

    User? currentUser;
    try {
      final auth = widget.auth ?? FirebaseAuth.instance;
      currentUser = auth.currentUser;
    } catch (_) {
      currentUser = null;
    }

    if (currentUser != null) {
      Navigator.pushReplacementNamed(context, Routes.mainLayout);
    } else {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
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
