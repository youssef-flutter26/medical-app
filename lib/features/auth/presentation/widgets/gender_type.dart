import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical_app/core/localization/locale_keys.dart';

class GenderType extends StatelessWidget {
  const GenderType({super.key, required this.genderController});

  final TextEditingController genderController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.male, color: Colors.blue),
                    title: Text(LocaleKeys.male.tr()),
                    onTap: () {
                      genderController.text = LocaleKeys.male.tr();
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.female, color: Colors.pink),
                    title: Text(LocaleKeys.female.tr()),
                    onTap: () {
                      genderController.text = LocaleKeys.female.tr();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: const Icon(Icons.keyboard_arrow_down),
    );
  }
}
