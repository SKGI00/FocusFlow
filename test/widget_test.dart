import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focusflow/main.dart';

void main() {
  testWidgets('W1: duration presets and custom replace the slider', (
    tester,
  ) async {
    await tester.pumpWidget(const FocusFlowApp());
    expect(find.text('30:00'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('15 min'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('15 min'), findsOneWidget);
    expect(find.text('30 min'), findsOneWidget);
    expect(find.text('60 min'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
    expect(find.byType(Slider), findsNothing);
    await tester.tap(find.text('15 min'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('15:00'),
      -160,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('15:00'), findsOneWidget);
  });

  testWidgets('W2: custom input accepts three minutes', (tester) async {
    await tester.pumpWidget(const FocusFlowApp());
    await tester.scrollUntilVisible(
      find.text('Custom'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();
    expect(find.text('Custom duration'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '3');
    await tester.tap(find.text('Set duration'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('03:00'),
      -160,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('03:00'), findsOneWidget);
  });

  testWidgets('W3: focus sounds is a collapsed, explicitly marked preview', (
    tester,
  ) async {
    await tester.pumpWidget(const FocusFlowApp());
    await tester.scrollUntilVisible(
      find.text('Focus sounds'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Optional idea'), findsOneWidget);
    expect(find.text('Forest'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('focus-sounds-toggle')));
    await tester.pumpAndSettle();
    expect(
      find.text('Preview only — coming later. No audio plays.'),
      findsOneWidget,
    );
    expect(find.text('Forest'), findsOneWidget);
    expect(find.text('Rain'), findsOneWidget);
    expect(find.text('White noise'), findsOneWidget);
    expect(find.text('Off'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('focus-sounds-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Forest'), findsNothing);
  });
}
