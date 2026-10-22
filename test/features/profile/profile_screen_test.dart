import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/common/widgets/app_button.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/core/utils/app_assets.dart';
import 'package:medical_app/features/profile/presentation/widgets/logout_bottom_sheet.dart';
import 'package:medical_app/features/profile/presentation/widgets/profile_avatar_section.dart';
import 'package:medical_app/features/profile/presentation/widgets/profile_menu_item.dart';

void main() {
  group('Profile Widgets Tests', () {
    testWidgets('ProfileAvatarSection renders name, phone, and edit button',
        (WidgetTester tester) async {
      bool editTapped = false;

      await tester.pumpWidget(
        AppScreenUtilScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProfileAvatarSection(
                name: 'Daniel Martinez',
                subtitle: '+123 856479683',
                onEdit: () {
                  editTapped = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Daniel Martinez'), findsOneWidget);
      expect(find.text('+123 856479683'), findsOneWidget);
      expect(find.byType(SvgPicture), findsWidgets);

      final editFinder = find.byType(GestureDetector);
      expect(editFinder, findsOneWidget);
      await tester.tap(editFinder);
      expect(editTapped, isTrue);
    });

    testWidgets('ProfileMenuItem renders leading icon, title, and chevron',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        AppScreenUtilScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProfileMenuItem(
                leadingIcon: SvgPicture.asset(AppAssets.iconsSetting2),
                title: 'Settings',
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(SvgPicture), findsNWidgets(2)); // leading + chevron

      await tester.tap(find.text('Settings'));
      expect(tapped, isTrue);
    });

    testWidgets('LogoutBottomSheet renders buttons and handles cancel',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        AppScreenUtilScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      LogoutBottomSheet.show(
                        context,
                        onConfirmLogout: () async {},
                      );
                    },
                    child: const Text('Open Logout'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Logout'));
      await tester.pumpAndSettle();

      expect(find.byType(AppButton), findsNWidgets(2));
    });
  });
}
