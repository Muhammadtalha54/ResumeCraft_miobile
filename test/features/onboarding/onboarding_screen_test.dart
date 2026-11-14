import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resumecraft_mobile/core/constants/lang.dart';
import 'package:resumecraft_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('OnboardingScreen renders first page with illustration and title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    // Initial page title & description
    expect(find.text(Lang.obTitle1), findsOneWidget);
    expect(find.text(Lang.obDesc1), findsOneWidget);
    expect(find.text(Lang.onboardingSkip), findsOneWidget);
    expect(find.text(Lang.onboardingNext), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('OnboardingScreen advances through pages on Next click', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    // Tap Next to advance to page 2
    await tester.tap(find.text(Lang.onboardingNext));
    await tester.pumpAndSettle();

    expect(find.text(Lang.obTitle2), findsOneWidget);
    expect(find.text(Lang.obDesc2), findsOneWidget);

    // Tap Next to advance to page 3
    await tester.tap(find.text(Lang.onboardingNext));
    await tester.pumpAndSettle();

    expect(find.text(Lang.obTitle3), findsOneWidget);
    expect(find.text(Lang.obDesc3), findsOneWidget);
    expect(find.text(Lang.onboardingGetStarted), findsOneWidget);
    expect(find.text(Lang.onboardingSkip), findsNothing);
  });
}
