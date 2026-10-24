import 'package:shared_preferences/shared_preferences.dart';

import '../model/models.dart';

/// Device-local preferences. These are not study records or cloud settings.
class FocusSettings {
  const FocusSettings({
    this.defaultMinutes = 30,
    this.reminderEnabled = false,
    this.reminderMinuteOfDay = 19 * 60,
  });

  final int defaultMinutes;
  final bool reminderEnabled;
  final int reminderMinuteOfDay;

  FocusSettings copyWith({
    int? defaultMinutes,
    bool? reminderEnabled,
    int? reminderMinuteOfDay,
  }) {
    final minutes = defaultMinutes ?? this.defaultMinutes;
    final reminderMinute = reminderMinuteOfDay ?? this.reminderMinuteOfDay;
    if (minutes < 3 || minutes > 120) {
      throw RangeError.range(minutes, 3, 120, 'defaultMinutes');
    }
    if (reminderMinute < 0 || reminderMinute >= 24 * 60) {
      throw RangeError.range(reminderMinute, 0, 1439, 'reminderMinuteOfDay');
    }
    return FocusSettings(
      defaultMinutes: minutes,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinuteOfDay: reminderMinute,
    );
  }
}

/// A tiny interface allows unit tests to run without platform plugins.
abstract class SettingsKeysStore {
  Future<int?> getInt(String key);
  Future<bool?> getBool(String key);
  Future<String?> getString(String key);
  Future<void> setInt(String key, int value);
  Future<void> setBool(String key, bool value);
  Future<void> setString(String key, String value);
}

class SharedPreferencesKeysStore implements SettingsKeysStore {
  SharedPreferencesKeysStore() : _prefs = SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  @override
  Future<int?> getInt(String key) => _prefs.getInt(key);

  @override
  Future<bool?> getBool(String key) => _prefs.getBool(key);

  @override
  Future<String?> getString(String key) => _prefs.getString(key);

  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
}

class FocusSettingsRepository {
  FocusSettingsRepository({SettingsKeysStore? store})
    : _store = store ?? SharedPreferencesKeysStore();

  static final FocusSettingsRepository instance = FocusSettingsRepository();

  static const _durationKey = 'focusflow.default_duration';
  static const _reminderEnabledKey = 'focusflow.reminder_enabled';
  static const _reminderMinuteKey = 'focusflow.reminder_minute';
  static const _dismissedKey = 'focusflow.reminder_dismissed_on';

  final SettingsKeysStore _store;

  Future<FocusSettings> load() async {
    final minutes = await _store.getInt(_durationKey);
    final reminderMinute = await _store.getInt(_reminderMinuteKey);
    final enabled = await _store.getBool(_reminderEnabledKey);
    return FocusSettings(
      defaultMinutes: minutes != null && minutes >= 3 && minutes <= 120
          ? minutes
          : 30,
      reminderEnabled: enabled ?? false,
      reminderMinuteOfDay:
          reminderMinute != null && reminderMinute >= 0 && reminderMinute < 1440
          ? reminderMinute
          : 19 * 60,
    );
  }

  Future<void> save(FocusSettings value) async {
    // Ensure callers cannot persist invalid values.
    value.copyWith();
    await _store.setInt(_durationKey, value.defaultMinutes);
    await _store.setBool(_reminderEnabledKey, value.reminderEnabled);
    await _store.setInt(_reminderMinuteKey, value.reminderMinuteOfDay);
  }

  Future<String?> dismissedOn() => _store.getString(_dismissedKey);

  Future<void> dismissForToday(DateTime now) =>
      _store.setString(_dismissedKey, localDateKey(now));
}

String localDateKey(DateTime date) {
  final local = date.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

/// Called only while Home is visible. This is *not* an OS-scheduled reminder.
bool shouldOfferInAppReminder({
  required FocusSettings settings,
  required DateTime now,
  required Iterable<Session> sessions,
  String? dismissedOn,
}) {
  if (!settings.reminderEnabled) return false;
  if (now.hour * 60 + now.minute < settings.reminderMinuteOfDay) {
    return false;
  }
  final today = localDateKey(now);
  if (dismissedOn == today) return false;
  for (final session in sessions) {
    if (session.endTime != null &&
        (session.actualSeconds ?? 0) > 0 &&
        localDateKey(session.startTime) == today) {
      return false;
    }
  }
  return true;
}
