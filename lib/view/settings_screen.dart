import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../notifications/reminder_scheduler.dart';
import '../settings/focus_settings.dart';
import '../utils/focus_duration.dart';

/// Local preferences: flexible focus duration and opt-in study reminders.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.repository, this.scheduler});

  final FocusSettingsRepository? repository;
  final ReminderScheduler? scheduler;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final FocusSettingsRepository _repository =
      widget.repository ?? FocusSettingsRepository.instance;

  late final ReminderScheduler _scheduler =
      widget.scheduler ??
      (widget.repository == null
          ? SystemReminderScheduler()
          : const NoopReminderScheduler());

  FocusSettings? _settings;
  bool? _dailyReminderPending;
  bool _saving = false;
  String? _error;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final settings = await _repository.load();
      bool? pending;
      if (settings.reminderEnabled) {
        try {
          pending = await _scheduler.isScheduled();
        } catch (_) {
          // A notification-service failure must not block local Settings.
          pending = false;
        }
      }
      if (mounted) {
        setState(() {
          _settings = settings;
          _dailyReminderPending = pending;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not load settings. Please reopen this page.',
        );
      }
    }
  }

  Future<void> _save(FocusSettings value) async {
    if (_saving) return;
    final previous = _settings;
    if (previous == null) return;
    setState(() {
      _saving = true;
      _error = null;
      _message = null;
    });

    try {
      final scheduleChanged =
          value.reminderEnabled != previous.reminderEnabled ||
          (value.reminderEnabled &&
              value.reminderMinuteOfDay != previous.reminderMinuteOfDay);
      if (scheduleChanged) {
        if (value.reminderEnabled) {
          if (!previous.reminderEnabled) {
            final granted = await _scheduler.requestPermission();
            if (!granted) {
              if (mounted) {
                setState(
                  () => _error = 'Notifications are not allowed. You can enable them in Android Settings.',
                );
              }
              return;
            }
          }
          await _scheduler.scheduleDaily(value.reminderMinuteOfDay);
          final pending = await _scheduler.isScheduled();
          if (!pending) {
            throw StateError('No scheduled reminder found after saving.');
          }
        } else {
          await _scheduler.cancel();
        }
      }
      await _repository.save(value);
      if (mounted) {
        setState(() {
          _settings = value;
          _dailyReminderPending = value.reminderEnabled
              ? (scheduleChanged ? true : _dailyReminderPending)
              : false;
          if (scheduleChanged) {
            _message = value.reminderEnabled
                ? 'Daily study reminder scheduled.'
                : 'Study reminder switched off.';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Could not save the reminder. Please try again.';
          _dailyReminderPending = false;
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sendTest() async {
    if (_saving || _settings?.reminderEnabled != true) return;
    setState(() {
      _saving = true;
      _error = null;
      _message = null;
    });
    try {
      final permitted = await _scheduler.requestPermission();
      if (!permitted) {
        if (mounted) {
          setState(
            () => _error = 'Android notifications are off. Allow notifications in your device settings.',
          );
        }
        return;
      }
      await _scheduler.sendTestNotification();
      final pending = await _scheduler.isScheduled();
      if (mounted) {
        setState(() {
          _dailyReminderPending = pending;
          _message = 'Test sent. Swipe down to check your notification panel.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not send the test notification. Check Android notification settings.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _reschedule() async {
    if (_saving) return;
    final settings = _settings;
    if (settings == null || !settings.reminderEnabled) return;
    setState(() {
      _saving = true;
      _error = null;
      _message = null;
    });
    try {
      final allowed = await _scheduler.requestPermission();
      if (!allowed) {
        if (mounted) {
          setState(
            () => _error = 'Allow notifications in Android Settings first.',
          );
        }
        return;
      }
      await _scheduler.scheduleDaily(settings.reminderMinuteOfDay);
      final pending = await _scheduler.isScheduled();
      if (mounted) {
        setState(() {
          _dailyReminderPending = pending;
          _message = pending ? 'Daily study reminder scheduled.' : null;
          if (!pending) {
            _error = 'Android did not register the reminder. Please try again.';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not schedule the study reminder.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickCustomDuration() async {
    final settings = _settings;
    if (settings == null || _saving) return;
    final formKey = GlobalKey<FormState>();
    String input = '${settings.defaultMinutes}';
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Custom focus time'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: input,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 3,
            decoration: const InputDecoration(
              labelText: 'Minutes',
              helperText: '3 to 120 minutes',
              border: OutlineInputBorder(),
              counterText: '',
            ),
            validator: (value) => FocusDuration.parse(value ?? '') == null
                ? 'Enter 3–120 minutes'
                : null,
            onChanged: (value) => input = value,
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, FocusDuration.parse(input));
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, FocusDuration.parse(input));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (mounted && selected != null) {
      await _save(settings.copyWith(defaultMinutes: selected));
    }
  }

  Future<void> _pickTime() async {
    final settings = _settings;
    if (settings == null || _saving) return;
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.reminderMinuteOfDay ~/ 60,
        minute: settings.reminderMinuteOfDay % 60,
      ),
      helpText: 'Choose a study reminder time',
    );
    if (mounted && selected != null) {
      await _save(
        settings.copyWith(
          reminderMinuteOfDay: selected.hour * 60 + selected.minute,
        ),
      );
    }
  }

  Widget _durationButton(int minutes, FocusSettings settings) {
    final selected = settings.defaultMinutes == minutes;
    return ChoiceChip(
      avatar: const Icon(Icons.schedule_rounded, size: 18),
      label: Text('$minutes min'),
      selected: selected,
      onSelected: _saving
          ? null
          : (_) => _save(settings.copyWith(defaultMinutes: minutes)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final settings = _settings;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: settings == null
            ? Center(
                child: _error == null
                    ? const CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!),
                      ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          color: colors.onPrimaryContainer,
                          size: 30,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Make it your own',
                            style: text.titleLarge?.copyWith(
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text('Default focus time', style: text.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Used when you start a new session.',
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _durationButton(15, settings),
                      _durationButton(30, settings),
                      _durationButton(60, settings),
                      ChoiceChip(
                        avatar: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Custom'),
                        selected: ![
                          15,
                          30,
                          60,
                        ].contains(settings.defaultMinutes),
                        onSelected: _saving
                            ? null
                            : (_) => _pickCustomDuration(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text('Study reminders', style: text.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'A gentle nudge to study. No pressure.',
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      secondary: const Icon(Icons.notifications_none_rounded),
                      title: const Text('Remind me to focus'),
                      subtitle: const Text('Optional · Quiet · Off by default'),
                      value: settings.reminderEnabled,
                      onChanged: _saving
                          ? null
                          : (value) => _save(
                              settings.copyWith(reminderEnabled: value),
                            ),
                    ),
                  ),
                  if (settings.reminderEnabled) ...[
                    const SizedBox(height: 10),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.access_time_rounded),
                        title: const Text('Reminder time'),
                        subtitle: Text(
                          TimeOfDay(
                            hour: settings.reminderMinuteOfDay ~/ 60,
                            minute: settings.reminderMinuteOfDay % 60,
                          ).format(context),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: _saving ? null : _pickTime,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_dailyReminderPending == true)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded, size: 19),
                            SizedBox(width: 8),
                            Expanded(child: Text('Daily reminder scheduled')),
                          ],
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _reschedule,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Schedule reminder'),
                      ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _sendTest,
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('Send test notification'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A test appears now. Daily reminders may arrive later '
                      'than the selected time on Android.',
                      style: text.bodySmall,
                    ),
                  ],
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Text(_message!, style: text.bodyMedium),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: colors.error)),
                  ],
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Icon(Icons.lock_outline_rounded, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Saved on this device · No account needed',
                          style: text.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
