import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/features/admin/presentation/pages/add_medical_center_page.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';
import 'package:medical_app/features/home/domain/usecases/add_medical_center.dart';
import 'package:medical_app/features/home/domain/usecases/update_medical_center.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestMedicalCenterAssetLoader extends AssetLoader {
  const TestMedicalCenterAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "addMedicalCenter": "Add Medical Center",
      "medicalCenterDetails": "Medical Center Details",
      "addMedicalCenterInformation":
          "Add the information for this medical center.",
      "medicalCenterName": "Medical Center Name",
      "enterMedicalCenterName": "Enter medical center name",
      "address": "Address",
      "enterAddress": "Enter address",
      "rating": "Rating",
      "enterRating": "Enter rating",
      "reviewsCount": "Reviews Count",
      "enterReviewsCount": "Enter reviews count",
      "distance": "Distance",
      "enterDistance": "Enter distance",
      "duration": "Duration",
      "enterDuration": "Enter duration",
      "type": "Type",
      "hospital": "Hospital",
      "clinic": "Clinic",
      "imageName": "Image Name",
      "enterImageName": "Enter image file name",
      "medicalCenterAddedSuccessfully": "Medical center added successfully",
      "failedToAddMedicalCenter": "Failed to add medical center",
      "nameCannotBeEmpty": "Name cannot be empty",
      "addressCannotBeEmpty": "Address cannot be empty",
      "ratingCannotBeEmpty": "Rating cannot be empty",
      "invalidRating": "Rating must be between 0.0 and 5.0",
      "reviewsCountCannotBeEmpty": "Reviews count cannot be empty",
      "invalidReviewsCount": "Reviews count must be a whole number",
      "distanceCannotBeEmpty": "Distance cannot be empty",
      "invalidDistance": "Distance must be a valid number",
      "durationCannotBeEmpty": "Duration cannot be empty",
      "invalidDuration": "Duration must be a whole number",
      "imageNameCannotBeEmpty": "Image name cannot be empty",
      "reviews": "Reviews",
      "km": "km",
      "min": "min",
      "ratingHint": "4.5",
      "reviewsCountHint": "58",
      "distanceHint": "2.5",
      "durationHint": "40",
      "imageNameHint": "clinic1.png",
      "editMedicalCenter": "Edit Medical Center",
      "updateMedicalCenter": "Update Medical Center",
      "editMedicalCenterInformation":
          "Modify the information for this medical center.",
      "medicalCenterUpdatedSuccessfully":
          "Medical center updated successfully",
      "failedToUpdateMedicalCenter": "Failed to update medical center",
    };
  }
}

class FakeMedicalCenterRepository implements HomeRepository {
  bool shouldSucceed = true;
  MedicalCenterEntity? savedCenter;

  MedicalCenterEntity? updatedCenter;

  @override
  Stream<List<BannerEntity>> getBannersStream() => const Stream.empty();

  @override
  Future<Result<void>> addBanner(BannerEntity banner) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> updateBanner(BannerEntity banner) async =>
      const SuccessAPI(null);

  @override
  Stream<List<MedicalCenterEntity>> getMedicalCentersStream() =>
      const Stream.empty();

  @override
  Future<Result<void>> addMedicalCenter(MedicalCenterEntity center) async {
    savedCenter = center;
    if (shouldSucceed) {
      return const SuccessAPI(null);
    } else {
      return ErrorAPI(FirebaseFailure('Failed to add medical center'));
    }
  }

  @override
  Future<Result<void>> updateMedicalCenter(MedicalCenterEntity center) async {
    updatedCenter = center;
    if (shouldSucceed) {
      return const SuccessAPI(null);
    } else {
      return ErrorAPI(FirebaseFailure('Failed to update medical center'));
    }
  }
}

Widget createAddMedicalCenterScreenTestWidget({
  AddMedicalCenter? addMedicalCenter,
  UpdateMedicalCenter? updateMedicalCenter,
  MedicalCenterEntity? initialMedicalCenter,
  bool pushRoute = false,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    assetLoader: const TestMedicalCenterAssetLoader(),
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
              home: AddMedicalCenterScreen(
                addMedicalCenter: addMedicalCenter,
                updateMedicalCenter: updateMedicalCenter,
                initialMedicalCenter: initialMedicalCenter,
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
                          builder: (_) => AddMedicalCenterScreen(
                            addMedicalCenter: addMedicalCenter,
                            updateMedicalCenter: updateMedicalCenter,
                            initialMedicalCenter: initialMedicalCenter,
                          ),
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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('AddMedicalCenterScreen widget tests', () {
    testWidgets('renders all form fields and submit button', (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeMedicalCenterRepository();
      final usecase = AddMedicalCenter(repo);

      await tester.pumpWidget(
        createAddMedicalCenterScreenTestWidget(addMedicalCenter: usecase),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Medical Center'), findsWidgets);
      expect(find.byKey(const Key('medical_center_name_field')), findsOneWidget);
      expect(
        find.byKey(const Key('medical_center_address_field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('medical_center_rating_field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('medical_center_reviews_count_field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('medical_center_distance_field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('medical_center_duration_field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('medical_center_type_dropdown')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('medical_center_image_name_field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('medical_center_submit_button')),
        findsOneWidget,
      );
    });

    testWidgets('validates required fields when submitted empty',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeMedicalCenterRepository();
      final usecase = AddMedicalCenter(repo);

      await tester.pumpWidget(
        createAddMedicalCenterScreenTestWidget(addMedicalCenter: usecase),
      );
      await tester.pumpAndSettle();

      // Tap submit button without entering anything
      await tester.tap(find.byKey(const Key('add_medical_center_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Name cannot be empty'), findsOneWidget);
      expect(find.text('Address cannot be empty'), findsOneWidget);
      expect(find.text('Rating cannot be empty'), findsOneWidget);
      expect(find.text('Reviews count cannot be empty'), findsOneWidget);
      expect(find.text('Distance cannot be empty'), findsOneWidget);
      expect(find.text('Duration cannot be empty'), findsOneWidget);
      expect(find.text('Image name cannot be empty'), findsOneWidget);

      expect(repo.savedCenter, isNull);
    });

    testWidgets('validates rating range between 0.0 and 5.0', (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeMedicalCenterRepository();
      final usecase = AddMedicalCenter(repo);

      await tester.pumpWidget(
        createAddMedicalCenterScreenTestWidget(addMedicalCenter: usecase),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('medical_center_rating_input')),
        '5.5',
      );
      await tester.tap(find.byKey(const Key('add_medical_center_submit_button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Rating must be between 0.0 and 5.0'),
        findsOneWidget,
      );
    });

    testWidgets('validates reviews count as whole integer', (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeMedicalCenterRepository();
      final usecase = AddMedicalCenter(repo);

      await tester.pumpWidget(
        createAddMedicalCenterScreenTestWidget(addMedicalCenter: usecase),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('medical_center_reviews_count_input')),
        '58.5',
      );
      await tester.tap(find.byKey(const Key('add_medical_center_submit_button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Reviews count must be a whole number'),
        findsOneWidget,
      );
    });

    testWidgets(
        'submits valid form with number conversion, image prefix, and pops',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeMedicalCenterRepository();
      final usecase = AddMedicalCenter(repo);

      await tester.pumpWidget(
        createAddMedicalCenterScreenTestWidget(
          addMedicalCenter: usecase,
          pushRoute: true,
        ),
      );
      await tester.pumpAndSettle();

      // Open screen
      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      // Fill in all inputs
      await tester.enterText(
        find.byKey(const Key('medical_center_name_input')),
        'Sunrise Health Clinic',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_address_input')),
        '123 Oak Street, CA 98765',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_rating_input')),
        '4.9',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_reviews_count_input')),
        '58',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_distance_input')),
        '2.5 km',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_duration_input')),
        '40 min',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_image_name_input')),
        'clinic1.png',
      );

      // Submit
      await tester.tap(find.byKey(const Key('add_medical_center_submit_button')));
      await tester.pumpAndSettle();

      // Verify repository received proper numeric values and auto-prefixed imagePath
      expect(repo.savedCenter, isNotNull);
      expect(repo.savedCenter!.name, 'Sunrise Health Clinic');
      expect(repo.savedCenter!.address, '123 Oak Street, CA 98765');
      expect(repo.savedCenter!.rating, 4.9);
      expect(repo.savedCenter!.rating, isA<double>());
      expect(repo.savedCenter!.reviewsCount, 58);
      expect(repo.savedCenter!.reviewsCount, isA<int>());
      expect(repo.savedCenter!.distance, 2.5);
      expect(repo.savedCenter!.duration, 40);
      expect(repo.savedCenter!.type, 'Hospital');
      expect(repo.savedCenter!.imagePath, 'assets/images/clinic1.png');

      // Verify success snackbar and route popped back
      expect(find.text('Medical center added successfully'), findsOneWidget);
      expect(find.text('Open Form'), findsOneWidget);
    });

    testWidgets('shows error snackbar when save fails', (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeMedicalCenterRepository()..shouldSucceed = false;
      final usecase = AddMedicalCenter(repo);

      await tester.pumpWidget(
        createAddMedicalCenterScreenTestWidget(addMedicalCenter: usecase),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('medical_center_name_input')),
        'Test Clinic',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_address_input')),
        'Test Address',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_rating_input')),
        '4.5',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_reviews_count_input')),
        '10',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_distance_input')),
        '1 km',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_duration_input')),
        '10 min',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_image_name_input')),
        'clinic1.png',
      );

      await tester.tap(find.byKey(const Key('add_medical_center_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Failed to add medical center'), findsOneWidget);
    });

    testWidgets('rating input updates visual stars and star tap updates input',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeMedicalCenterRepository();
      final usecase = AddMedicalCenter(repo);

      await tester.pumpWidget(
        createAddMedicalCenterScreenTestWidget(addMedicalCenter: usecase),
      );
      await tester.pumpAndSettle();

      // Enter rating 3.5 -> 4 amber stars, 1 gray star (normal rounding: 3.5 rounds to 4)
      await tester.enterText(
        find.byKey(const Key('medical_center_rating_input')),
        '3.5',
      );
      await tester.pumpAndSettle();

      final starsFinder = find.byIcon(Icons.star_rounded);
      expect(starsFinder, findsNWidgets(5));

      int amberCount = 0;
      int grayCount = 0;
      for (final element in starsFinder.evaluate()) {
        final icon = element.widget as Icon;
        if (icon.color == AppColors.amber) {
          amberCount++;
        } else {
          grayCount++;
        }
      }
      expect(amberCount, 4);
      expect(grayCount, 1);

      // Enter rating 3.4 -> 3 amber stars, 2 gray stars
      await tester.enterText(
        find.byKey(const Key('medical_center_rating_input')),
        '3.4',
      );
      await tester.pumpAndSettle();

      amberCount = 0;
      grayCount = 0;
      for (final element in starsFinder.evaluate()) {
        final icon = element.widget as Icon;
        if (icon.color == AppColors.amber) {
          amberCount++;
        } else {
          grayCount++;
        }
      }
      expect(amberCount, 3);
      expect(grayCount, 2);

      // Tap the 5th star -> sets rating input to 5.0
      await tester.tap(starsFinder.at(4));
      await tester.pumpAndSettle();

      final ratingInput = tester.widget<TextFormField>(
        find.byKey(const Key('medical_center_rating_input')),
      );
      expect(ratingInput.controller?.text, '5.0');

      int allAmberCount = 0;
      for (final element in starsFinder.evaluate()) {
        final icon = element.widget as Icon;
        if (icon.color == AppColors.amber) {
          allAmberCount++;
        }
      }
      expect(allAmberCount, 5);
    });

    testWidgets('allows selecting Clinic and entering numeric-only distance/duration',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeMedicalCenterRepository();
      final usecase = AddMedicalCenter(repo);

      await tester.pumpWidget(
        createAddMedicalCenterScreenTestWidget(
          addMedicalCenter: usecase,
          pushRoute: true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('medical_center_name_input')),
        'Modern Medical Center',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_address_input')),
        '456 Avenue, NY',
      );

      // Select Clinic
      await tester.tap(find.byKey(const Key('medical_center_type_option_Clinic')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('medical_center_rating_input')),
        '4.8',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_reviews_count_input')),
        '120',
      );
      // Pure numeric distance without typing 'km' manually
      await tester.enterText(
        find.byKey(const Key('medical_center_distance_input')),
        '3.2',
      );
      // Pure numeric duration without typing 'min' manually
      await tester.enterText(
        find.byKey(const Key('medical_center_duration_input')),
        '25',
      );
      await tester.enterText(
        find.byKey(const Key('medical_center_image_name_input')),
        'clinic2.png',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_medical_center_submit_button')));
      await tester.pumpAndSettle();

      expect(repo.savedCenter, isNotNull);
      expect(repo.savedCenter!.name, 'Modern Medical Center');
      expect(repo.savedCenter!.type, 'Clinic');
      expect(repo.savedCenter!.rating, 4.8);
      expect(repo.savedCenter!.reviewsCount, 120);
      expect(repo.savedCenter!.distance, 3.2);
      expect(repo.savedCenter!.duration, 25);
      expect(repo.savedCenter!.imagePath, 'assets/images/clinic2.png');
    });

    testWidgets('renders pre-filled fields in edit mode and updates existing document',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeMedicalCenterRepository();
      final updateUsecase = UpdateMedicalCenter(repo);

      const existingCenter = MedicalCenterEntity(
        id: 'doc_123',
        name: 'Existing Clinic',
        address: '100 Main St',
        rating: 4.5,
        reviewsCount: 30,
        distance: 1.5,
        duration: 20,
        type: 'Clinic',
        imagePath: 'assets/images/clinic1.png',
      );

      await tester.pumpWidget(
        createAddMedicalCenterScreenTestWidget(
          updateMedicalCenter: updateUsecase,
          initialMedicalCenter: existingCenter,
          pushRoute: true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      // Check AppBar and Header
      expect(find.text('Edit Medical Center'), findsWidgets);
      expect(find.text('Update Medical Center'), findsOneWidget);

      // Check pre-filled values
      expect(find.text('Existing Clinic'), findsOneWidget);
      expect(find.text('100 Main St'), findsOneWidget);
      final ratingInput = tester.widget<TextFormField>(
        find.byKey(const Key('medical_center_rating_input')),
      );
      expect(ratingInput.controller?.text, '4.5');
      expect(find.text('30'), findsOneWidget);
      expect(find.text('1.5'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      final imageInput = tester.widget<TextFormField>(
        find.byKey(const Key('medical_center_image_name_input')),
      );
      expect(imageInput.controller?.text, 'clinic1.png');

      // Modify name
      await tester.enterText(
        find.byKey(const Key('medical_center_name_input')),
        'Updated Clinic Name',
      );
      await tester.pumpAndSettle();

      // Submit update
      await tester.tap(find.byKey(const Key('add_medical_center_submit_button')));
      await tester.pumpAndSettle();

      expect(repo.updatedCenter, isNotNull);
      expect(repo.updatedCenter!.id, 'doc_123');
      expect(repo.updatedCenter!.name, 'Updated Clinic Name');
      expect(repo.updatedCenter!.address, '100 Main St');
      expect(repo.updatedCenter!.rating, 4.5);
      expect(repo.updatedCenter!.reviewsCount, 30);
      expect(repo.updatedCenter!.distance, 1.5);
      expect(repo.updatedCenter!.duration, 20);
      expect(repo.updatedCenter!.type, 'Clinic');
      expect(repo.updatedCenter!.imagePath, 'assets/images/clinic1.png');
      expect(find.text('Medical center updated successfully'), findsOneWidget);
    });

    testWidgets('shows error snackbar when update fails in edit mode',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeMedicalCenterRepository()..shouldSucceed = false;
      final updateUsecase = UpdateMedicalCenter(repo);

      const existingCenter = MedicalCenterEntity(
        id: 'doc_fail',
        name: 'Fail Clinic',
        address: '100 Fail St',
        rating: 4.0,
        reviewsCount: 10,
        distance: 2.0,
        duration: 15,
        type: 'Hospital',
        imagePath: 'assets/images/clinic1.png',
      );

      await tester.pumpWidget(
        createAddMedicalCenterScreenTestWidget(
          updateMedicalCenter: updateUsecase,
          initialMedicalCenter: existingCenter,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_medical_center_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Failed to update medical center'), findsOneWidget);
    });
  });
}

