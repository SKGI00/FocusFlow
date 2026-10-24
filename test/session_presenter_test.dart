import 'package:flutter_test/flutter_test.dart';
import 'package:focusflow/presenter/session_presenter.dart';

void main() {
  late SessionPresenter presenter;

  setUp(() {
    presenter = SessionPresenter(initialMinutes: 25);
  });

  tearDown(() {
    presenter.dispose();
  });

  test('P1: timer starts in ready state', () {
    expect(presenter.status, SessionStatus.ready);
    expect(presenter.durationMinutes, 25);
    expect(presenter.formattedTime, '25:00');
  });

  test('P2: user can customise session duration', () {
    presenter.setDuration(40);

    expect(presenter.durationMinutes, 40);
    expect(presenter.formattedTime, '40:00');
  });

  test('P3: timer starts and can be paused', () {
    presenter.start();

    expect(presenter.status, SessionStatus.running);

    presenter.pause();

    expect(presenter.status, SessionStatus.paused);
  });

  test('P4: paused session can resume', () {
    presenter.start();
    presenter.pause();
    presenter.resume();

    expect(presenter.status, SessionStatus.running);
  });

  test('P5: session can be completed', () {
    presenter.start();
    presenter.complete();

    expect(presenter.status, SessionStatus.completed);
  });

  test('P6: completed session can be reset', () {
    presenter.start();
    presenter.complete();
    presenter.reset();

    expect(presenter.status, SessionStatus.ready);
    expect(presenter.formattedTime, '25:00');
  });

  test('P7: invalid duration is rejected', () {
    presenter.setDuration(-5);

    expect(presenter.durationMinutes, 25);
  });

  test('P8: duration cannot change during active session', () {
    presenter.start();
    presenter.setDuration(60);

    expect(presenter.durationMinutes, 25);
  });
}
