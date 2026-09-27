import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/core/localization/locale_keys.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(LocaleKeys.home.tr())));
  }
}
