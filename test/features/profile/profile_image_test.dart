import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
import 'package:medical_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:medical_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:medical_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:medical_app/features/profile/presentation/widgets/profile_avatar_section.dart';
import 'package:medical_app/features/profile/presentation/widgets/profile_photo_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileTestAssetLoader extends AssetLoader {
  const ProfileTestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "profilePicture": "Profile Picture",
      "chooseFromGallery": "Choose from Gallery",
      "takePhoto": "Take Photo",
      "removeProfilePicture": "Remove Profile Picture",
      "removePhotoConfirmation": "Are you sure you want to remove your profile picture?",
      "cancel": "Cancel",
      "yesRemove": "Yes, Remove",
    };
  }
}

class FakeUserRemoteDataSource implements UserRemoteDataSource {
  final StreamController<UserModel?> _streamController =
      StreamController<UserModel?>.broadcast();
  UserModel? storedUser;
  bool deletePhotoCalled = false;

  @override
  Future<void> saveUser(UserModel user) async {
    storedUser = user;
    _streamController.add(user);
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    return storedUser;
  }

  @override
  Stream<UserModel?> getUserStream(String uid) {
    return _streamController.stream;
  }

  @override
  Future<void> deleteUserPhoto(String uid) async {
    deletePhotoCalled = true;
    if (storedUser != null) {
      storedUser = UserModel(
        id: storedUser!.id,
        email: storedUser!.email,
        name: storedUser!.name,
        nickname: storedUser!.nickname,
        birthDate: storedUser!.birthDate,
        gender: storedUser!.gender,
        photoUrl: null,
        role: storedUser!.role,
      );
      _streamController.add(storedUser);
    }
  }
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<void>> logout() async => const SuccessAPI(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  String? _photoURL;

  FakeUser({
    required this.uid,
    this.email,
    this.displayName,
    String? photoURL,
  }) : _photoURL = photoURL;

  @override
  String? get photoURL => _photoURL;

  @override
  Future<void> updatePhotoURL(String? photoUri) async {
    _photoURL = photoUri;
  }
}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  final User? _user;

  FakeFirebaseAuth([this._user]);

  @override
  User? get currentUser => _user;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('Profile Image Functionality Tests', () {
    late FakeUserRemoteDataSource fakeRemoteDataSource;
    late FakeAuthRepository fakeAuthRepository;
    late FakeFirebaseAuth fakeAuth;
    late FakeUser testUser;
    late ProfileCubit cubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      testUser = FakeUser(
        uid: 'user_123',
        email: 'test@example.com',
        displayName: 'John Doe',
      );
      fakeRemoteDataSource = FakeUserRemoteDataSource();
      fakeAuthRepository = FakeAuthRepository();
      fakeAuth = FakeFirebaseAuth(testUser);

      cubit = ProfileCubit(
        authRepository: fakeAuthRepository,
        userRemoteDataSource: fakeRemoteDataSource,
        firebaseAuth: fakeAuth,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('1. New user without a profile picture sees null photoUrl (default avatar)', () async {
      fakeRemoteDataSource.storedUser = UserModel(
        id: 'user_123',
        email: 'test@example.com',
        name: 'John Doe',
        photoUrl: null,
      );

      cubit.init();
      fakeRemoteDataSource._streamController.add(fakeRemoteDataSource.storedUser);

      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, isA<ProfileLoaded>());
      final loadedState = cubit.state as ProfileLoaded;
      expect(loadedState.user?.photoUrl, isNull);
      expect(loadedState.user?.name, 'John Doe');
      expect(loadedState.user?.email, 'test@example.com');
    });

    test('2. Selecting and updating an image updates state, prefs and keeps existing info', () async {
      fakeRemoteDataSource.storedUser = UserModel(
        id: 'user_123',
        email: 'test@example.com',
        name: 'John Doe',
        nickname: 'JD',
        gender: 'Male',
        photoUrl: null,
      );

      cubit.init();
      fakeRemoteDataSource._streamController.add(fakeRemoteDataSource.storedUser);
      await Future.delayed(const Duration(milliseconds: 10));

      const newPhoto = '/data/user/0/com.example/avatar.jpg';
      await cubit.updatePhoto(newPhoto);

      // Verify immediate state update
      expect(cubit.state, isA<ProfileLoaded>());
      final loadedState = cubit.state as ProfileLoaded;
      expect(loadedState.user?.photoUrl, newPhoto);
      // Verify existing profile info remains unchanged
      expect(loadedState.user?.name, 'John Doe');
      expect(loadedState.user?.nickname, 'JD');
      expect(loadedState.user?.gender, 'Male');

      // Verify SharedPreferences persistence
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('profile_photo_user_123'), newPhoto);

      // Verify remote data source received the update
      expect(fakeRemoteDataSource.storedUser?.photoUrl, newPhoto);
      expect(fakeRemoteDataSource.storedUser?.name, 'John Doe');
      expect(fakeRemoteDataSource.storedUser?.nickname, 'JD');
    });

    test('3. Removing the image restores default avatar and deletes photo remotely', () async {
      fakeRemoteDataSource.storedUser = UserModel(
        id: 'user_123',
        email: 'test@example.com',
        name: 'John Doe',
        nickname: 'JD',
        photoUrl: '/data/user/0/com.example/avatar.jpg',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_photo_user_123', '/data/user/0/com.example/avatar.jpg');

      cubit.init();
      fakeRemoteDataSource._streamController.add(fakeRemoteDataSource.storedUser);
      await Future.delayed(const Duration(milliseconds: 10));

      // Remove photo
      await cubit.removePhoto();

      // State is updated with null photoUrl
      final loadedState = cubit.state as ProfileLoaded;
      expect(loadedState.user?.photoUrl, isNull);
      // Profile info remains intact
      expect(loadedState.user?.name, 'John Doe');
      expect(loadedState.user?.nickname, 'JD');

      // SharedPreferences key removed
      expect(prefs.getString('profile_photo_user_123'), isNull);

      // Remote deletion invoked
      expect(fakeRemoteDataSource.deletePhotoCalled, isTrue);
      expect(fakeRemoteDataSource.storedUser?.photoUrl, isNull);
    });

    test('4. The removed image does not reappear after app restart/re-init', () async {
      fakeRemoteDataSource.storedUser = UserModel(
        id: 'user_123',
        email: 'test@example.com',
        name: 'John Doe',
        photoUrl: '/data/user/0/avatar.jpg',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_photo_user_123', '/data/user/0/avatar.jpg');

      cubit.init();
      fakeRemoteDataSource._streamController.add(fakeRemoteDataSource.storedUser);
      await Future.delayed(const Duration(milliseconds: 10));

      await cubit.removePhoto();
      await cubit.close();

      // Simulate app restart: new Cubit instance
      final restartedCubit = ProfileCubit(
        authRepository: fakeAuthRepository,
        userRemoteDataSource: fakeRemoteDataSource,
        firebaseAuth: fakeAuth,
      );

      restartedCubit.init();
      fakeRemoteDataSource._streamController.add(fakeRemoteDataSource.storedUser);
      await Future.delayed(const Duration(milliseconds: 10));

      final restartedState = restartedCubit.state as ProfileLoaded;
      expect(restartedState.user?.photoUrl, isNull);
      expect(restartedState.user?.name, 'John Doe');

      restartedCubit.close();
    });
  });

  group('Profile Avatar UI Widget Tests', () {
    testWidgets('ProfileAvatarSection displays default avatar when avatarUrl is null',
        (tester) async {
      await tester.pumpWidget(
        AppScreenUtilScope(
          child: const MaterialApp(
            home: Scaffold(
              body: ProfileAvatarSection(
                name: 'Jane Doe',
                subtitle: 'jane@example.com',
                avatarUrl: null,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('jane@example.com'), findsOneWidget);
      // Renders SVG default user icon placeholder
      expect(find.byType(SvgPicture), findsWidgets);
    });

    testWidgets('ProfilePhotoBottomSheet displays remove option only when hasExistingPhoto is true',
        (tester) async {
      ProfilePhotoAction? selectedAction;

      Widget buildWidget({required bool hasExistingPhoto}) {
        return EasyLocalization(
          supportedLocales: const [Locale('en')],
          path: 'assets/translations',
          assetLoader: const ProfileTestAssetLoader(),
          startLocale: const Locale('en'),
          child: AppScreenUtilScope(
            child: Builder(
              builder: (context) => MaterialApp(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home: Scaffold(
                  body: ProfilePhotoBottomSheet(
                    hasExistingPhoto: hasExistingPhoto,
                    onActionSelected: (action) => selectedAction = action,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildWidget(hasExistingPhoto: false));
      await tester.pumpAndSettle();

      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Remove Profile Picture'), findsNothing);

      // Now with hasExistingPhoto = true
      await tester.pumpWidget(buildWidget(hasExistingPhoto: true));
      await tester.pumpAndSettle();

      expect(find.text('Remove Profile Picture'), findsOneWidget);
      await tester.tap(find.text('Remove Profile Picture'));
      expect(selectedAction, ProfilePhotoAction.remove);
    });
  });
}
