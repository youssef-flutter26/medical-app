import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/routing/app_router.dart';
import 'package:medical_app/features/splash/presentation/views/splash_screen.dart';
import 'package:medical_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    if (!getIt.isRegistered<AppRouter>()) {
      setupServiceLocator();
    }
  });

  testWidgets('App launch smoke test displays SplashScreen first',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() => EasyLocalization.ensureInitialized());

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
