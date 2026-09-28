import 'package:flutter/material.dart';
import 'package:medical_app/core/theme/app_colors.dart';

class AdminFab extends StatelessWidget {
  final VoidCallback? onPressed;

  const AdminFab({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.darkTeal,
      child: const Icon(
        Icons.add,
        color: AppColors.white,
      ),
    );
  }
}
