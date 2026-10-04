import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/error/firebase_failure.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/data/models/google_login_result.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
import 'package:medical_app/features/auth/domain/entities/user_entity.dart';
import 'package:medical_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:medical_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:medical_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:medical_app/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAssetLoader extends AssetLoader {
  const _FakeAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "profile": "Profile",
      "user": "User",
      "nickname": "Nickname",
      "dateOfBirth": "Date of Birth",
      "gender": "Gender",
      "logOut": "Log out",
      "logOutConfirmation": "Are you sure you want to log out?",
      "cancel": "Cancel",
    };
  }
}

class _FakeAuthRepository implements AuthRepository {
  bool logoutCalled = false;
  bool shouldFailLogout = false;

  @override
  Future<Result<void>> logout() async {
    logoutCalled = true;
    if (shouldFailLogout) {
      return ErrorAPI(FirebaseFailure('Logout failed'));
    }
    return const SuccessAPI(null);
  }

  @override
  Future<Result<UserEntity>> login({required String email, required String password}) async =>
      throw UnimplementedError();

  @override
  Future<Result<GoogleLoginResult>> loginWithGoogle() async =>
      throw UnimplementedError();

  @override
  Future<Result<UserEntity>> signup({required String email, required String password, required String name}) async =>
      throw UnimplementedError();

  @override
  Future<Result<void>> sendEmailVerification() async =>
      throw UnimplementedError();

  @override
  Future<Result<bool>> checkEmailVerified() async =>
      throw UnimplementedError();

  @override
  Future<Result<bool>> isNameTaken({required String name}) async =>
      throw UnimplementedError();

  @override
  Future<Result<void>> saveUserProfile({
    required String name,
    required String nickname,
    required String email,
    required String birthDate,
    required String gender,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async =>
      throw UnimplementedError();

  @override
  Future<Result<UserEntity?>> getUserProfile(String uid) async =>
      throw UnimplementedError();
}

class _FakeUserRemoteDataSource implements UserRemoteDataSource {
  final UserModel? userModel;
  final StreamController<UserModel?> _controller = StreamController<UserModel?>.broadcast();

  _FakeUserRemoteDataSource([this.userModel]) {
    if (userModel != null) {
      _controller.add(userModel);
    }
  }

  @override
  Stream<UserModel?> getUserStream(String uid) {
    return Stream.value(userModel);
  }

  @override
  Future<UserModel?> getUser(String uid) async => userModel;

  @override
  Future<void> saveUser(UserModel user) async {}

  @override
  Future<void> updateUser(UserModel user) async {}
}

const _testUserModel = UserModel(
  id: 'test_user_123',
  name: 'John Doe',
  email: 'john.doe@example.com',
  nickname: 'Johnny',
  birthDate: '1995-05-15',
  gender: 'Male',
  role: 'user',
);

const _testAdminModel = UserModel(
  id: 'admin_user_456',
  name: 'Dr. Admin',
  email: 'admin@medicalapp.com',
  nickname: 'Chief',
  birthDate: '1980-01-01',
  gender: 'Female',
  role: 'admin',
);

Widget createProfileScreenTestWidget({
  required _FakeAuthRepository authRepository,
  UserModel? userModel = _testUserModel,
  NavigatorObserver? navigatorObserver,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    assetLoader: const _FakeAssetLoader(),
    child: Builder(
      builder: (context) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            navigatorObservers: [
              if (navigatorObserver != null) navigatorObserver,
            ],
            routes: {
              Routes.login: (ctx) => const Scaffold(body: Text('Login Screen')),
              Routes.profile: (ctx) => ProfileScreen(
                    authRepository: authRepository,
                    userModelStream: Stream.value(userModel),
                  ),
            },
            home: ProfileScreen(
              authRepository: authRepository,
              userModelStream: Stream.value(userModel),
            ),
          ),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('ProfileScreen widget tests', () {
    testWidgets('renders user profile information correctly', (tester) async {
      final fakeRepo = _FakeAuthRepository();

      await tester.pumpWidget(createProfileScreenTestWidget(
        authRepository: fakeRepo,
        userModel: _testUserModel,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileHeader), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
      expect(find.text('Johnny'), findsOneWidget);
      expect(find.text('1995-05-15'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.byType(ProfileMenuItem), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
    });

    testWidgets('displays Admin badge when user has admin role', (tester) async {
      final fakeRepo = _FakeAuthRepository();

      await tester.pumpWidget(createProfileScreenTestWidget(
        authRepository: fakeRepo,
        userModel: _testAdminModel,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Admin'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('tapping Logout shows confirmation dialog and cancelling does nothing',
        (tester) async {
      final fakeRepo = _FakeAuthRepository();

      await tester.pumpWidget(createProfileScreenTestWidget(
        authRepository: fakeRepo,
        userModel: _testUserModel,
      ));
      await tester.pumpAndSettle();

      // Tap logout menu item
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Are you sure you want to log out?'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(fakeRepo.logoutCalled, isFalse);
    });

    testWidgets('confirming Logout calls AuthRepository.logout and navigates to Login',
        (tester) async {
      final fakeRepo = _FakeAuthRepository();

      await tester.pumpWidget(createProfileScreenTestWidget(
        authRepository: fakeRepo,
        userModel: _testUserModel,
      ));
      await tester.pumpAndSettle();

      // Tap logout menu item
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      // Confirm logout in dialog
      final logoutDialogButton = find.descendant(
        of: find.byType(TextButton),
        matching: find.text('Log out'),
      );
      await tester.tap(logoutDialogButton);
      await tester.pumpAndSettle();

      expect(fakeRepo.logoutCalled, isTrue);
      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
}
