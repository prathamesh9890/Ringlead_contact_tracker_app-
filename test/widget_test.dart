import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:contact_tracker/main.dart';
import 'package:contact_tracker/widgets/neu.dart';

void main() {
  testWidgets('Login screen shows brand, and Sign In enables once email + password are valid', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RingleadApp());

    expect(find.text('Ringlead'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    NeuPrimaryButton signInButton() => tester.widget<NeuPrimaryButton>(find.byType(NeuPrimaryButton));

    expect(signInButton().onPressed, isNull);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'owner@business.com');
    await tester.enterText(fields.at(1), 'secret123');
    await tester.pump();

    expect(signInButton().onPressed, isNotNull);
  });
}
