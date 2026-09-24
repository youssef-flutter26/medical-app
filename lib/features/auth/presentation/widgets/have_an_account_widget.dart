import 'package:flutter/material.dart';
import 'package:medical_app/core/routing/routes.dart';

class HaveAnAccountWidget extends StatelessWidget {
  const HaveAnAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account?'),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.login);
          },
          child: const Text('Sign in', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
