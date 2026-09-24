import 'package:flutter/material.dart';

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
                    title: const Text('Male'),
                    onTap: () {
                      genderController.text = 'Male';
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.female, color: Colors.pink),
                    title: const Text('Female'),
                    onTap: () {
                      genderController.text = 'Female';
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },

      child: Icon(Icons.keyboard_arrow_down),
    );
  }
}
