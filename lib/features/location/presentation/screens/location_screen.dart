import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/core/localization/locale_keys.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(LocaleKeys.location.tr())));
  }
}
