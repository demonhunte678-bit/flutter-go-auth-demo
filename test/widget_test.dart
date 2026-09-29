import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets(
    'Smoke test: Verify Authentication & Authorization UI elements render',
    (WidgetTester tester) async {
      // Build the app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify the presence of input fields for Authentication.
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Verify the presence of the Authentication button.
      expect(find.text('1.Login in (Authentication)'), findsOneWidget);

      // Verify the presence of the Authorization button.
      expect(
        find.text('2.request data Access the data (Authorization)'),
        findsOneWidget,
      );

      // Verify initial server response placeholder.
      expect(
        find.text('Server Response:\nWaiting for server response...'),
        findsOneWidget,
      );
    },
  );
}
