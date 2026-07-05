import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_frontend/main.dart';

void main() {
  testWidgets('App starts with login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EventManagerApp());

    expect(find.text('University Event Manager'), findsOneWidget);
    expect(find.text('Login to continue'), findsOneWidget);
    expect(find.text('Login as User'), findsOneWidget);
  });
}