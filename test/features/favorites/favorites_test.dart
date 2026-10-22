import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:medical_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:medical_app/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:medical_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:medical_app/features/favorites/presentation/widgets/favorite_doctor_card.dart';
import 'package:medical_app/features/favorites/presentation/widgets/favorite_hospital_card.dart';
import 'package:medical_app/features/favorites/presentation/widgets/favorites_empty_state.dart';
import 'package:medical_app/features/favorites/presentation/widgets/remove_favorite_bottom_sheet.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';
import 'package:medical_app/features/home/domain/entities/medical_center_entity.dart';
import 'package:medical_app/features/home/domain/repositories/doctor_repository.dart';
import 'package:medical_app/features/home/domain/repositories/home_repository.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/domain/entities/banner_entity.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesTestAssetLoader extends AssetLoader {
  const FavoritesTestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "favorites": "Favorites",
      "doctors": "Doctors",
      "hospitals": "Hospitals",
      "removeFromFavorites": "Remove from Favorites?",
      "yesRemove": "Yes, Remove",
      "cancel": "Cancel",
      "noFavoriteDoctors": "No favorite doctors yet",
      "noFavoriteHospitals": "No favorite hospitals yet",
      "noFavoritesDescription": "Items you favorite will appear here for easy access.",
      "reviews": "Reviews",
    };
  }
}

class FakeDoctorRepository implements DoctorRepository {
  final StreamController<List<DoctorEntity>> controller =
      StreamController<List<DoctorEntity>>.broadcast();
  List<DoctorEntity> doctors = [];

  @override
  Stream<List<DoctorEntity>> getDoctorsStream() => controller.stream;

  @override
  Future<Result<void>> addDoctor(DoctorEntity doctor) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> updateDoctor(DoctorEntity doctor) async =>
      const SuccessAPI(null);

  @override
  Stream<List<DoctorEntity>> getDoctorsByCategoryStream(String categoryId) =>
      controller.stream;

  @override
  Future<Result<DoctorEntity>> getDoctorById(String doctorId) async {
    final d = doctors.firstWhere((e) => e.id == doctorId);
    return SuccessAPI(d);
  }
}

class FakeHomeRepository implements HomeRepository {
  final StreamController<List<MedicalCenterEntity>> controller =
      StreamController<List<MedicalCenterEntity>>.broadcast();
  List<MedicalCenterEntity> centers = [];

  @override
  Stream<List<MedicalCenterEntity>> getMedicalCentersStream() =>
      controller.stream;

  @override
  Future<Result<void>> addMedicalCenter(MedicalCenterEntity center) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> updateMedicalCenter(MedicalCenterEntity center) async =>
      const SuccessAPI(null);

  @override
  Stream<List<BannerEntity>> getBannersStream() => const Stream.empty();

  @override
  Stream<List<CategoryEntity>> getCategoriesStream() => const Stream.empty();

  @override
  Future<Result<void>> addBanner(BannerEntity banner) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> updateBanner(BannerEntity banner) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> addCategory(CategoryEntity category) async =>
      const SuccessAPI(null);

  @override
  Future<Result<void>> updateCategory(CategoryEntity category) async =>
      const SuccessAPI(null);
}

class FakeFavoriteRepository implements FavoriteRepository {
  final Set<String> doctorIds = {};
  final Set<String> centerIds = {};
  final StreamController<Set<String>> doctorStream =
      StreamController<Set<String>>.broadcast();
  final StreamController<Set<String>> centerStream =
      StreamController<Set<String>>.broadcast();

  @override
  Future<Set<String>> getInitialFavoriteDoctorIds(String userId) async =>
      Set.from(doctorIds);

  @override
  Future<Set<String>> getInitialFavoriteMedicalCenterIds(String userId) async =>
      Set.from(centerIds);

  @override
  Stream<Set<String>> getFavoriteDoctorIdsStream(String userId) =>
      doctorStream.stream;

  @override
  Stream<Set<String>> getFavoriteMedicalCenterIdsStream(String userId) =>
      centerStream.stream;

  @override
  Future<void> addDoctorFavorite(String userId, String doctorId) async {
    doctorIds.add(doctorId);
    doctorStream.add(Set.from(doctorIds));
  }

  @override
  Future<void> removeDoctorFavorite(String userId, String doctorId) async {
    doctorIds.remove(doctorId);
    doctorStream.add(Set.from(doctorIds));
  }

  @override
  Future<void> addMedicalCenterFavorite(String userId, String centerId) async {
    centerIds.add(centerId);
    centerStream.add(Set.from(centerIds));
  }

  @override
  Future<void> removeMedicalCenterFavorite(
      String userId, String centerId) async {
    centerIds.remove(centerId);
    centerStream.add(Set.from(centerIds));
  }
}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => null;

  @override
  Stream<User?> authStateChanges() => const Stream.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('FavoritesCubit unit tests', () {
    late FakeFavoriteRepository favoriteRepo;
    late FakeDoctorRepository doctorRepo;
    late FakeHomeRepository homeRepo;
    late FakeFirebaseAuth auth;
    late FavoritesCubit cubit;

    final testDoctor = DoctorEntity(
      id: 'doc-1',
      name: 'Dr. David Patel',
      specialty: 'Cardiologist',
      categoryId: 'cat-1',
      categoryName: 'Cardiology',
      address: 'Cardiology Center, USA',
      rating: 5.0,
      reviewsCount: 1872,
      availableTime: '9am - 5pm',
      imagePath: '',
    );

    final testCenter = MedicalCenterEntity(
      id: 'center-1',
      name: 'Sunrise Health Clinic',
      address: '123 Oak Street, CA 98765',
      rating: 5.0,
      reviewsCount: 128,
      distance: 2.5,
      type: 'Clinic',
      imagePath: '',
    );

    setUp(() {
      favoriteRepo = FakeFavoriteRepository();
      doctorRepo = FakeDoctorRepository();
      homeRepo = FakeHomeRepository();
      auth = FakeFirebaseAuth();

      cubit = FavoritesCubit(
        favoriteRepository: favoriteRepo,
        doctorRepository: doctorRepo,
        homeRepository: homeRepo,
        firebaseAuth: auth,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has empty favorite doctors and hospitals', () {
      expect(cubit.state.favoriteDoctors, isEmpty);
      expect(cubit.state.favoriteMedicalCenters, isEmpty);
      expect(cubit.state.selectedTab, 0);
    });

    test('toggling doctor favorite adds and then removes', () async {
      doctorRepo.doctors = [testDoctor];
      cubit.init();
      doctorRepo.controller.add([testDoctor]);

      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.isDoctorFavorite('doc-1'), isFalse);

      await cubit.toggleDoctorFavorite('doc-1');
      expect(cubit.isDoctorFavorite('doc-1'), isTrue);
      expect(cubit.state.favoriteDoctors.length, 1);
      expect(cubit.state.favoriteDoctors.first.name, 'Dr. David Patel');

      await cubit.toggleDoctorFavorite('doc-1');
      expect(cubit.isDoctorFavorite('doc-1'), isFalse);
      expect(cubit.state.favoriteDoctors, isEmpty);
    });

    test('toggling hospital favorite adds and then removes', () async {
      homeRepo.centers = [testCenter];
      cubit.init();
      homeRepo.controller.add([testCenter]);

      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.isMedicalCenterFavorite('center-1'), isFalse);

      await cubit.toggleMedicalCenterFavorite('center-1');
      expect(cubit.isMedicalCenterFavorite('center-1'), isTrue);
      expect(cubit.state.favoriteMedicalCenters.length, 1);
      expect(cubit.state.favoriteMedicalCenters.first.name,
          'Sunrise Health Clinic');

      await cubit.removeMedicalCenterFavorite('center-1');
      expect(cubit.isMedicalCenterFavorite('center-1'), isFalse);
      expect(cubit.state.favoriteMedicalCenters, isEmpty);
    });

    test('tab selection switches tabs', () {
      expect(cubit.state.selectedTab, 0);
      cubit.setTab(1);
      expect(cubit.state.selectedTab, 1);
      cubit.setTab(0);
      expect(cubit.state.selectedTab, 0);
    });
  });

  group('Favorites UI Widget tests', () {
    Widget createWidgetUnderTest({
      required FavoritesCubit cubit,
    }) {
      return EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: const FavoritesTestAssetLoader(),
        startLocale: const Locale('en'),
        child: AppScreenUtilScope(
          child: Builder(
            builder: (context) => MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: BlocProvider<FavoritesCubit>.value(
                value: cubit,
                child: const FavoritesPage(),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders Favorites title, tabs and empty state when empty',
        (tester) async {
      final favoriteRepo = FakeFavoriteRepository();
      final doctorRepo = FakeDoctorRepository();
      final homeRepo = FakeHomeRepository();
      final auth = FakeFirebaseAuth();

      final cubit = FavoritesCubit(
        favoriteRepository: favoriteRepo,
        doctorRepository: doctorRepo,
        homeRepository: homeRepo,
        firebaseAuth: auth,
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Doctors'), findsOneWidget);
      expect(find.text('Hospitals'), findsOneWidget);
      expect(find.byType(FavoritesEmptyState), findsOneWidget);

      cubit.close();
    });

    testWidgets('renders favorited doctor card when doctor is in favorites',
        (tester) async {
      final favoriteRepo = FakeFavoriteRepository();
      final doctorRepo = FakeDoctorRepository();
      final homeRepo = FakeHomeRepository();
      final auth = FakeFirebaseAuth();

      final testDoctor = DoctorEntity(
        id: 'doc-1',
        name: 'Dr. David Patel',
        specialty: 'Cardiologist',
        categoryId: 'cat-1',
        categoryName: 'Cardiology',
        address: 'Cardiology Center, USA',
        rating: 5.0,
        reviewsCount: 1872,
        availableTime: '9am - 5pm',
        imagePath: '',
      );

      final cubit = FavoritesCubit(
        favoriteRepository: favoriteRepo,
        doctorRepository: doctorRepo,
        homeRepository: homeRepo,
        firebaseAuth: auth,
      );

      cubit.emit(FavoritesState(
        allDoctors: [testDoctor],
        favoriteDoctorIds: {'doc-1'},
        selectedTab: 0,
      ));

      await tester.pumpWidget(createWidgetUnderTest(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.byType(FavoriteDoctorCard), findsOneWidget);
      expect(find.text('Dr. David Patel'), findsOneWidget);
      expect(find.text('Cardiologist'), findsOneWidget);

      cubit.close();
    });

    testWidgets(
        'renders favorited hospital card when hospital is in favorites on tab 1',
        (tester) async {
      final favoriteRepo = FakeFavoriteRepository();
      final doctorRepo = FakeDoctorRepository();
      final homeRepo = FakeHomeRepository();
      final auth = FakeFirebaseAuth();

      final testCenter = MedicalCenterEntity(
        id: 'center-1',
        name: 'Sunrise Health Clinic',
        address: '123 Oak Street, CA 98765',
        rating: 5.0,
        reviewsCount: 128,
        distance: 2.5,
        type: 'Hospital',
        imagePath: '',
      );

      final cubit = FavoritesCubit(
        favoriteRepository: favoriteRepo,
        doctorRepository: doctorRepo,
        homeRepository: homeRepo,
        firebaseAuth: auth,
      );

      cubit.emit(FavoritesState(
        allMedicalCenters: [testCenter],
        favoriteMedicalCenterIds: {'center-1'},
        selectedTab: 1,
      ));

      await tester.pumpWidget(createWidgetUnderTest(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.byType(FavoriteHospitalCard), findsOneWidget);
      expect(find.text('Sunrise Health Clinic'), findsOneWidget);

      cubit.close();
    });

    testWidgets('tapping heart opens RemoveFavoriteBottomSheet',
        (tester) async {
      final favoriteRepo = FakeFavoriteRepository();
      final doctorRepo = FakeDoctorRepository();
      final homeRepo = FakeHomeRepository();
      final auth = FakeFirebaseAuth();

      final testDoctor = DoctorEntity(
        id: 'doc-1',
        name: 'Dr. David Patel',
        specialty: 'Cardiologist',
        categoryId: 'cat-1',
        categoryName: 'Cardiology',
        address: 'Cardiology Center, USA',
        rating: 5.0,
        reviewsCount: 1872,
        availableTime: '9am - 5pm',
        imagePath: '',
      );

      final cubit = FavoritesCubit(
        favoriteRepository: favoriteRepo,
        doctorRepository: doctorRepo,
        homeRepository: homeRepo,
        firebaseAuth: auth,
      );

      cubit.emit(FavoritesState(
        allDoctors: [testDoctor],
        favoriteDoctorIds: {'doc-1'},
        selectedTab: 0,
      ));

      await tester.pumpWidget(createWidgetUnderTest(cubit: cubit));
      await tester.pumpAndSettle();

      // Find the heart icon in FavoriteDoctorCard
      final heartFinder = find.byIcon(Icons.favorite_rounded);
      expect(heartFinder, findsOneWidget);

      await tester.tap(heartFinder);
      await tester.pumpAndSettle();

      expect(find.byType(RemoveFavoriteBottomSheet), findsOneWidget);
      expect(find.text('Remove from Favorites?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Yes, Remove'), findsOneWidget);

      // Tap Cancel to dismiss
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(RemoveFavoriteBottomSheet), findsNothing);

      cubit.close();
    });
  });
}
