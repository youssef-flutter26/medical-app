import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/features/admin/presentation/pages/add_medical_center_screen.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';
import 'package:medical_app/features/home/domain/usecases/add_medical_center.dart';
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
      "durationCannotBeEmpty": "Duration cannot be empty",
      "imageNameCannotBeEmpty": "Image name cannot be empty",
    };
  }
}

class FakeMedicalCenterRepository implements HomeRepository {
  bool shouldSucceed = true;
  MedicalCenterEntity? savedCenter;

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
}

Widget createAddMedicalCenterScreenTestWidget({
  required AddMedicalCenter addMedicalCenter,
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
      expect(repo.savedCenter!.distance, '2.5 km');
      expect(repo.savedCenter!.duration, '40 min');
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
  });
}
