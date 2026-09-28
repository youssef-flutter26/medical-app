import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/features/admin/domain/entities/banner_entity.dart';
import 'package:medical_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:medical_app/features/admin/domain/usecases/add_banner.dart';
import 'package:medical_app/features/admin/presentation/pages/add_banner_screen.dart';
import 'package:medical_app/features/admin/presentation/widgets/add_banner_button.dart';
import 'package:medical_app/features/admin/presentation/widgets/banner_description_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/banner_header_section.dart';
import 'package:medical_app/features/admin/presentation/widgets/banner_image_name_field.dart';
import 'package:medical_app/features/admin/presentation/widgets/banner_title_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestAdminAssetLoader extends AssetLoader {
  const TestAdminAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "addBanner": "Add Banner",
      "bannerDetails": "Banner Details",
      "addBannerInformation":
          "Add the information that will appear on the Home banner.",
      "bannerTitle": "Banner Title",
      "enterBannerTitle": "Enter banner title",
      "description": "Description",
      "enterBannerDescription": "Enter banner description",
      "imageName": "Image Name",
      "enterImageName": "Enter image file name",
      "titleCannotBeEmpty": "Title cannot be empty",
      "descriptionCannotBeEmpty": "Description cannot be empty",
      "imageNameCannotBeEmpty": "Image name cannot be empty",
      "bannerAddedSuccessfully": "Banner added successfully",
      "failedToAddBanner": "Failed to add banner",
    };
  }
}

class FakeAdminRepository implements AdminRepository {
  bool shouldSucceed = true;
  final List<BannerEntity> savedBanners = [];

  BannerEntity? get savedBanner =>
      savedBanners.isNotEmpty ? savedBanners.last : null;

  @override
  Future<Result<void>> addBanner(BannerEntity banner) async {
    savedBanners.add(banner);
    if (shouldSucceed) {
      return const SuccessAPI(null);
    } else {
      return ErrorAPI(FirebaseFailure('Failed to add banner'));
    }
  }
}

Widget createAddBannerScreenTestWidget({
  required AddBanner addBanner,
  bool pushRoute = false,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    assetLoader: const TestAdminAssetLoader(),
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
              home: AddBannerScreen(addBanner: addBanner),
            );
          }

          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: Builder(
              builder: (innerContext) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      innerContext,
                      MaterialPageRoute(
                        builder: (_) => AddBannerScreen(addBanner: addBanner),
                      ),
                    );
                  },
                  child: const Text('Open Add Banner'),
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
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
      'Renders all fields: Header, Title, Description, Image Name, and Add Banner button',
      (WidgetTester tester) async {
    final repo = FakeAdminRepository();
    final usecase = AddBanner(repo);

    await tester.pumpWidget(createAddBannerScreenTestWidget(addBanner: usecase));
    await tester.pumpAndSettle();

    expect(find.byType(BannerHeaderSection), findsOneWidget);
    expect(find.byType(BannerTitleField), findsOneWidget);
    expect(find.byType(BannerDescriptionField), findsOneWidget);
    expect(find.byType(BannerImageNameField), findsOneWidget);
    expect(find.byType(AddBannerButton), findsOneWidget);

    expect(find.text('Banner Details'), findsOneWidget);
    expect(find.text('Banner Title'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Image Name'), findsOneWidget);
  });

  testWidgets(
      'Validates required fields when Add Banner is pressed with empty fields',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = FakeAdminRepository();
    final usecase = AddBanner(repo);

    await tester.pumpWidget(createAddBannerScreenTestWidget(addBanner: usecase));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add_banner_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Title cannot be empty'), findsOneWidget);
    expect(find.text('Description cannot be empty'), findsOneWidget);
    expect(find.text('Image name cannot be empty'), findsOneWidget);
    expect(repo.savedBanner, isNull);
  });

  testWidgets('Saves banner successfully and auto-constructs asset imagePath',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = FakeAdminRepository();
    final usecase = AddBanner(repo);

    await tester.pumpWidget(
      createAddBannerScreenTestWidget(addBanner: usecase, pushRoute: true),
    );
    await tester.pumpAndSettle();

    // Push the AddBannerScreen
    await tester.tap(find.text('Open Add Banner'));
    await tester.pumpAndSettle();

    expect(find.byType(AddBannerScreen), findsOneWidget);

    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(3));

    // 1. Admin enters banner1.png
    await tester.enterText(textFields.at(0), 'Meet Doctors Online');
    await tester.enterText(textFields.at(1), 'Book an appointment with your doctor');
    await tester.enterText(textFields.at(2), 'banner1.png');

    await tester.tap(find.byKey(const Key('add_banner_submit_button')));
    await tester.pumpAndSettle();

    // 2. Firestore stores assets/images/banner1.png
    expect(repo.savedBanner, isNotNull);
    expect(repo.savedBanner?.title, 'Meet Doctors Online');
    expect(repo.savedBanner?.description, 'Book an appointment with your doctor');
    expect(repo.savedBanner?.imagePath, 'assets/images/banner1.png');

    // Verify navigated back to previous screen
    expect(find.byType(AddBannerScreen), findsNothing);
    expect(find.text('Open Add Banner'), findsOneWidget);
    expect(find.text('Banner added successfully'), findsOneWidget);
  });

  testWidgets('A second banner can be added with a different image name',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = FakeAdminRepository();
    final usecase = AddBanner(repo);

    await tester.pumpWidget(
      createAddBannerScreenTestWidget(addBanner: usecase, pushRoute: true),
    );
    await tester.pumpAndSettle();

    // Add first banner
    await tester.tap(find.text('Open Add Banner'));
    await tester.pumpAndSettle();

    var textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'First Banner');
    await tester.enterText(textFields.at(1), 'First Description');
    await tester.enterText(textFields.at(2), 'banner1.png');
    await tester.tap(find.byKey(const Key('add_banner_submit_button')));
    await tester.pumpAndSettle();

    // Add second banner
    await tester.tap(find.text('Open Add Banner'));
    await tester.pumpAndSettle();

    textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'Second Banner');
    await tester.enterText(textFields.at(1), 'Second Description');
    await tester.enterText(textFields.at(2), 'banner2.png');
    await tester.tap(find.byKey(const Key('add_banner_submit_button')));
    await tester.pumpAndSettle();

    expect(repo.savedBanners.length, 2);
    expect(repo.savedBanners[0].imagePath, 'assets/images/banner1.png');
    expect(repo.savedBanners[1].imagePath, 'assets/images/banner2.png');
  });

  testWidgets('Shows error message and stays on screen when saving banner fails',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = FakeAdminRepository();
    repo.shouldSucceed = false;
    final usecase = AddBanner(repo);

    await tester.pumpWidget(createAddBannerScreenTestWidget(addBanner: usecase));
    await tester.pumpAndSettle();

    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'Promo Fail');
    await tester.enterText(textFields.at(1), 'Will fail to save');
    await tester.enterText(textFields.at(2), 'banner1.png');

    await tester.tap(find.byKey(const Key('add_banner_submit_button')));
    await tester.pumpAndSettle();

    // Verify stays on screen
    expect(find.byType(AddBannerScreen), findsOneWidget);
    // Verify error message is shown
    expect(find.text('Failed to add banner'), findsOneWidget);
  });
}
