import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/features/admin/presentation/pages/add_doctor_page.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/add_doctor_button.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_category_dropdown.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_experience_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_image_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_name_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_rating_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_doctor/doctor_reviews_field.dart';
import 'package:medical_app/features/doctor/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestDoctorAssetLoader extends AssetLoader {
  const TestDoctorAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "addDoctor": "Add Doctor",
      "doctorDetails": "Doctor Details",
      "addDoctorInformation": "Enter the details for the new doctor.",
      "doctorName": "Doctor Name",
      "enterDoctorName": "Enter doctor name",
      "doctorNameCannotBeEmpty": "Doctor name cannot be empty",
      "category": "Category",
      "selectCategory": "Select Category",
      "categoryCannotBeEmpty": "Please select a category",
      "noCategoriesAvailable": "No categories available",
      "pleaseAddCategoryFirst":
          "Please add a category first before adding a doctor.",
      "experience": "Experience (Years)",
      "enterExperience": "Enter years of experience",
      "experienceCannotBeEmpty": "Experience cannot be empty",
      "invalidExperience": "Please enter a valid number of years",
      "rating": "Rating",
      "ratingHint": "4.8",
      "ratingCannotBeEmpty": "Rating cannot be empty",
      "invalidRating": "Please enter a rating between 0 and 5",
      "reviewsCount": "Reviews Count",
      "reviewsCountHint": "120",
      "reviewsCountCannotBeEmpty": "Reviews count cannot be empty",
      "invalidReviewsCount": "Please enter a valid number of reviews",
      "imageName": "Image Name",
      "doctorImageHint": "doctor1.png",
      "imageNameCannotBeEmpty": "Image name cannot be empty",
      "doctorAddedSuccessfully": "Doctor added successfully",
      "failedToAddDoctor": "Failed to add doctor",
      "notAuthorizedAdmin": "You must be an administrator to add doctors.",
      "years": "years",
    };
  }
}

Widget createAddDoctorTestWidget({
  List<CategoryEntity>? initialCategories,
  Stream<List<CategoryEntity>>? categoriesStream,
  Future<void> Function(DoctorEntity doctor)? onSubmit,
  bool pushRoute = false,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    assetLoader: const TestDoctorAssetLoader(),
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
              home: AddDoctorPage(
                initialCategories: initialCategories,
                categoriesStream: categoriesStream,
                onSubmit: onSubmit,
              ),
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
                          builder: (_) => AddDoctorPage(
                            initialCategories: initialCategories,
                            categoriesStream: categoriesStream,
                            onSubmit: onSubmit,
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Add Doctor'),
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

  group('AddDoctorPage widget tests', () {
    final sampleCategories = [
      const CategoryEntity(id: 'cat1', name: 'Cardiology'),
      const CategoryEntity(id: 'cat2', name: 'Neurology'),
      const CategoryEntity(id: 'cat3', name: 'Pediatrics'),
    ];

    testWidgets('renders all form fields, header, and submit button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createAddDoctorTestWidget(
        initialCategories: sampleCategories,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Add Doctor'), findsNWidgets(2)); // AppBar + Button
      expect(find.text('Doctor Details'), findsOneWidget);
      expect(
        find.text('Enter the details for the new doctor.'),
        findsOneWidget,
      );

      expect(find.byType(DoctorNameField), findsOneWidget);
      expect(find.byType(DoctorCategoryDropdown), findsOneWidget);
      expect(find.byType(DoctorExperienceField), findsOneWidget);
      expect(find.byType(DoctorRatingField), findsOneWidget);
      expect(find.byType(DoctorReviewsField), findsOneWidget);
      expect(find.byType(DoctorImageField), findsOneWidget);
      expect(find.byType(AddDoctorButton), findsOneWidget);
    });

    testWidgets(
        'shows warning message and disables button when no categories exist', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createAddDoctorTestWidget(
        initialCategories: <CategoryEntity>[],
      ));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('doctor_category_empty_warning')),
        findsOneWidget,
      );
      expect(find.text('No categories available'), findsOneWidget);
      expect(
        find.text('Please add a category first before adding a doctor.'),
        findsOneWidget,
      );

      // Button is disabled, tapping does not submit
      final submitFinder = find.byKey(const Key('add_doctor_submit_button'));
      await tester.tap(submitFinder);
      await tester.pump();

      // Form validation errors should not appear because button is disabled
      expect(find.text('Doctor name cannot be empty'), findsNothing);
    });

    testWidgets('validates required fields when submitted empty', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createAddDoctorTestWidget(
        initialCategories: sampleCategories,
      ));
      await tester.pumpAndSettle();

      // Scroll to button and tap submit
      final submitFinder = find.byKey(const Key('add_doctor_submit_button'));
      await tester.ensureVisible(submitFinder);
      await tester.pumpAndSettle();
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      expect(find.text('Doctor name cannot be empty'), findsOneWidget);
      expect(find.text('Experience cannot be empty'), findsOneWidget);
      expect(find.text('Rating cannot be empty'), findsOneWidget);
      expect(find.text('Reviews count cannot be empty'), findsOneWidget);
      expect(find.text('Image name cannot be empty'), findsOneWidget);
    });

    testWidgets('submits doctor data successfully and derives specialty from category', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      DoctorEntity? savedDoctor;
      await tester.pumpWidget(createAddDoctorTestWidget(
        initialCategories: sampleCategories,
        onSubmit: (doctor) async {
          savedDoctor = doctor;
        },
      ));
      await tester.pumpAndSettle();

      // Enter fields
      await tester.enterText(
        find.byKey(const Key('doctor_name_input')),
        'Dr. John Smith',
      );

      // Select category from dropdown
      await tester.tap(find.byKey(const Key('doctor_category_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cardiology').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('doctor_experience_input')),
        '12',
      );
      await tester.enterText(
        find.byKey(const Key('doctor_rating_input')),
        '4.9',
      );
      await tester.enterText(
        find.byKey(const Key('doctor_reviews_count_input')),
        '350',
      );
      await tester.enterText(
        find.byKey(const Key('doctor_image_name_input')),
        'doctor1.png',
      );

      // Submit
      final submitFinder = find.byKey(const Key('add_doctor_submit_button'));
      await tester.ensureVisible(submitFinder);
      await tester.pumpAndSettle();
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      expect(savedDoctor, isNotNull);
      expect(savedDoctor!.name, 'Dr. John Smith');
      // Specialty is automatically derived from the selected category
      expect(savedDoctor!.specialty, 'Cardiology');
      expect(savedDoctor!.categoryId, 'cat1');
      expect(savedDoctor!.categoryName, 'Cardiology');
      expect(savedDoctor!.experience, 12);
      expect(savedDoctor!.rating, 4.9);
      expect(savedDoctor!.reviewsCount, 350);
      expect(savedDoctor!.imagePath, 'assets/images/doctor1.png');
    });

    testWidgets('reflects dynamic category stream updates', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = StreamController<List<CategoryEntity>>.broadcast();

      await tester.pumpWidget(createAddDoctorTestWidget(
        categoriesStream: controller.stream,
      ));
      await tester.pump();

      // Initially empty before stream emits
      controller.add(<CategoryEntity>[]);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('doctor_category_empty_warning')), findsOneWidget);

      // Stream emits new categories dynamically
      controller.add(sampleCategories);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('doctor_category_empty_warning')), findsNothing);
      expect(find.byKey(const Key('doctor_category_dropdown')), findsOneWidget);

      await controller.close();
    });
  });
}
