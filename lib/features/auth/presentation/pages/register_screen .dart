import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:medical_app/features/auth/presentation/widgets/register_screen_body.dart';

class RigesterScreen extends StatelessWidget {
  const RigesterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (context) => getIt<AuthCubit>(),
        child: Scaffold(
          body: SingleChildScrollView(child: RegisterScreenBody()),
        ),
      ),
    );
  }
}
