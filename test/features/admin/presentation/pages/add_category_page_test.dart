import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/features/admin/presentation/pages/add_category/add_category_page.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_category/add_category_button.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_category/category_image_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_category/category_name_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestCategoryAssetLoader extends AssetLoader {
  const TestCategoryAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "addCategory": "Add Category",
      "categoryDetails": "Category Details",
      "addCategoryInformation":
          "Enter the details for the new medical category.",
      "categoryName": "Category Name",
      "enterCategoryName": "Enter category name",
      "categoryNameHint": "Dentist",
      "categoryNameCannotBeEmpty": "Category name cannot be empty",
      "imageName": "Image Name",
      "categoryImageHint": "dentist.png",
      "imageNameCannotBeEmpty": "Image name cannot be empty",
      "categoryAddedSuccessfully": "Category added successfully",
      "failedToAddCategory": "Failed to add category",
    };
  }
}

Widget createAddCategoryTestWidget({
  Future<void> Function(String name, String imageName)? onSubmit,
  bool pushRoute = false,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    assetLoader: const TestCategoryAssetLoader(),
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    child: AppScreenUtilScope(
      child: Builder(
        builder: (context) {
          if (!pushRoute) {
            return MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: AddCategoryPage(onSubmit: onSubmit),
            );
          }
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: Scaffold(
              body: Center(
                child: Builder(
                  builder: (ctx) => ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => AddCategoryPage(onSubmit: onSubmit),
                        ),
                      );
                    },
                    child: const Text('Open Form'),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('AddCategoryPage widget tests', () {
    testWidgets('renders all form fields, header, and submit button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createAddCategoryTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Add Category'), findsNWidgets(2)); // AppBar + Button
      expect(find.text('Category Details'), findsOneWidget);
      expect(
        find.text('Enter the details for the new medical category.'),
        findsOneWidget,
      );

      expect(find.byType(CategoryNameField), findsOneWidget);
      expect(find.text('Category Name'), findsOneWidget);
      expect(find.byKey(const Key('category_name_input')), findsOneWidget);

      expect(find.byType(CategoryImageField), findsOneWidget);
      expect(find.text('Image Name'), findsOneWidget);
      expect(find.byKey(const Key('category_image_input')), findsOneWidget);

      expect(find.byType(AddCategoryButton), findsOneWidget);
      expect(find.byKey(const Key('add_category_submit_button')), findsOneWidget);
    });

    testWidgets('validates required fields when submitted empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createAddCategoryTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_category_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Category name cannot be empty'), findsOneWidget);
      expect(find.text('Image name cannot be empty'), findsOneWidget);
    });

    testWidgets(
      'submits valid form with trimmed name, stripped prefix, and pops',
      (WidgetTester tester) async {
        String? submittedName;
        String? submittedImageName;

        await tester.pumpWidget(
          createAddCategoryTestWidget(
            pushRoute: true,
            onSubmit: (name, imageName) async {
              submittedName = name;
              submittedImageName = imageName;
            },
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Form'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('category_name_input')),
          '  Dentistry  ',
        );
        await tester.enterText(
          find.byKey(const Key('category_image_input')),
          'assets/images/dentist.png',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('add_category_submit_button')));
        await tester.pumpAndSettle();

        expect(submittedName, 'Dentistry');
        expect(submittedImageName, 'dentist.png');

        expect(find.text('Category added successfully'), findsOneWidget);
        expect(find.text('Open Form'), findsOneWidget);
      },
    );
  });
}
