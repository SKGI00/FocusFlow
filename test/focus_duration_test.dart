import 'package:flutter_test/flutter_test.dart';
import 'package:focusflow/utils/focus_duration.dart';

void main() {
  test('C1: minimum custom duration of three minutes is accepted', () {
    expect(FocusDuration.parse('3'), 3);
  });
  test('C2: maximum custom duration of 120 minutes is accepted', () {
    expect(FocusDuration.parse('120'), 120);
  });
  test('C3: values below three are rejected', () {
    expect(FocusDuration.parse('2'), isNull);
    expect(FocusDuration.parse('0'), isNull);
  });
  test('C4: values over 120 are rejected', () {
    expect(FocusDuration.parse('121'), isNull);
  });
  test('C5: invalid text and blanks are rejected', () {
    expect(FocusDuration.parse('abc'), isNull);
    expect(FocusDuration.parse(''), isNull);
  });
  test('C6: surrounding whitespace is accepted', () {
    expect(FocusDuration.parse(' 45 '), 45);
  });
}
