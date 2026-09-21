import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppScreenUtilScope extends StatelessWidget {
  const AppScreenUtilScope({super.key, required this.child});

  static const Size designSize = Size(442, 888);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => child!,
      child: child,
    );
  }
}
