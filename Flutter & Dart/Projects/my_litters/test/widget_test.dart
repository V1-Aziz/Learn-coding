import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_litters/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // flutter_secure_storage talks to a platform channel that isn't available
  // in the test environment, so we stub it. Returning null for `read` means
  // "no stored token", which makes Session.bootstrap resolve to logged-out.
  const storageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (call) async {
      switch (call.method) {
        case 'read':
          return null;
        case 'readAll':
          return <String, String>{};
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  testWidgets('App boots to the login screen when no token is stored',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // On the first frame the RootGate shows a spinner while the session
    // bootstraps asynchronously.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the async bootstrap complete. With no stored token we land on the
    // login screen, which shows the app name and a Login button.
    await tester.pumpAndSettle();

    expect(find.text('My Litters'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
