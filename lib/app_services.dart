import 'data/database_helper.dart';
import 'data/repositories.dart';

class AppServices {
  AppServices._(this.helper)
    : sessions = SessionRepository(helper),
      distractions = DistractionRepository(helper),
      reflections = ReflectionRepository(helper);

  factory AppServices.create({String? databasePath}) {
    return AppServices._(DatabaseHelper(path: databasePath));
  }

  final DatabaseHelper helper;

  final SessionRepository sessions;
  final DistractionRepository distractions;
  final ReflectionRepository reflections;

  Future<void> dispose() async {
    await helper.close();
  }
}
