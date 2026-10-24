import 'package:flutter_test/flutter_test.dart';
import 'package:focusflow/main.dart';

void main() {
  testWidgets('FocusFlow opens with a configurable timer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FocusFlowApp());

    expect(find.text('FocusFlow'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Ready when you are'), findsOneWidget);

    await tester.tap(find.text('15 min'));
    await tester.pump();

    expect(find.text('15:00'), findsOneWidget);
  });
}
