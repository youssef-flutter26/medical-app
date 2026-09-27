import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/core/responsive/app_screen_util_scope.dart';
import 'package:medical_app/features/home/presentation/screens/home_screen.dart';
import 'package:medical_app/features/home/presentation/widgets/category_item.dart';
import 'package:medical_app/features/home/presentation/widgets/home_banner.dart';
import 'package:medical_app/features/home/presentation/widgets/home_categories.dart';
import 'package:medical_app/features/home/presentation/widgets/home_location.dart';
import 'package:medical_app/features/home/presentation/widgets/home_search.dart';
import 'package:medical_app/features/home/presentation/widgets/medical_center_item.dart';
import 'package:medical_app/features/home/presentation/widgets/nearby_medical_centers.dart';

Widget createHomeScreenTestWidget() {
  return const AppScreenUtilScope(
    child: MaterialApp(
      home: HomeScreen(),
    ),
  );
}

void main() {
  testWidgets('HomeScreen renders all sections in the correct order', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createHomeScreenTestWidget());
    await tester.pumpAndSettle();

    // 1. Location section
    expect(find.byType(HomeLocation), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Seattle, USA'), findsOneWidget);

    // 2. Search section
    expect(find.byType(HomeSearch), findsOneWidget);
    expect(find.text('Search doctor, drugs, articles...'), findsOneWidget);

    // 3. Banner section
    expect(find.byType(HomeBanner), findsOneWidget);
    expect(find.text('Looking for\nSpecialist Doctors?'), findsOneWidget);

    // 4. Categories section
    expect(find.byType(HomeCategories), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.byType(CategoryItem), findsNWidgets(8));
    expect(find.text('Dentistry'), findsOneWidget);
    expect(find.text('Cardiology'), findsOneWidget);
    expect(find.text('Pulmonology'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Neurology'), findsOneWidget);
    expect(find.text('Gastro...'), findsOneWidget);
    expect(find.text('Laboratory'), findsOneWidget);
    expect(find.text('Vaccination'), findsOneWidget);

    // 5. Nearby Medical Centers section
    expect(find.byType(NearbyMedicalCenters), findsOneWidget);
    expect(find.text('Nearby Medical Centers'), findsOneWidget);
    expect(find.byType(MedicalCenterItem), findsNWidgets(2));
    expect(find.text('Sunrise Health Clinic'), findsOneWidget);
    expect(find.text('Golden Cardio...'), findsOneWidget);
  });
}
