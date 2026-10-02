import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';

class AdminFab extends StatefulWidget {
  final VoidCallback? onPressed;

  const AdminFab({
    super.key,
    this.onPressed,
  });

  @override
  State<AdminFab> createState() => _AdminFabState();
}

class _AdminFabState extends State<AdminFab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.90 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        width: 56.r,
        height: 56.r,
        decoration: BoxDecoration(
          color: AppColors.darkTeal,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkTeal.withValues(alpha: _isPressed ? 0.2 : 0.35),
              blurRadius: _isPressed ? 8 : 16,
              offset: Offset(0, _isPressed ? 3 : 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed ??
                () {
                  Navigator.pushNamed(context, Routes.adminDataSelection);
                },
            onHighlightChanged: (isHighlighted) {
              setState(() {
                _isPressed = isHighlighted;
              });
            },
            borderRadius: BorderRadius.circular(18.r),
            splashColor: AppColors.white.withValues(alpha: 0.15),
            highlightColor: Colors.transparent,
            child: Center(
              child: Icon(
                Icons.add_rounded,
                color: AppColors.white,
                size: 30.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
