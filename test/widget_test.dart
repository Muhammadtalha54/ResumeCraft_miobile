import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resumecraft_mobile/app.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ResumeCraftApp(),
      ),
    );

    // Initial frame renders successfully
    expect(find.byType(ResumeCraftApp), findsOneWidget);
  });
}
