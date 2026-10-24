import 'package:flutter/material.dart';

import '../app_services.dart';
import '../model/models.dart';
import '../settings/focus_settings.dart';
import 'flow_buddy.dart';
import 'history_screen.dart';
import 'insights_screen.dart';
import 'session_screen.dart';
import 'settings_screen.dart';
import 'tips_screen.dart';

/// A reassuring first screen with one primary action and low reading load.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshProgress();
    }
  }

  late Future<List<Session>> _sessions = widget.services.sessions.all();
  late Future<_ReminderData> _reminder = _readReminder();

  Future<_ReminderData> _readReminder() async {
    final repository = FocusSettingsRepository.instance;
    final settings = await repository.load();
    final dismissed = await repository.dismissedOn();
    final sessions = await widget.services.sessions.all();
    return _ReminderData(
      show: shouldOfferInAppReminder(
        settings: settings,
        now: DateTime.now(),
        sessions: sessions,
        dismissedOn: dismissed,
      ),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
    if (mounted) _refreshProgress();
  }

  Future<void> _dismissReminder() async {
    try {
      await FocusSettingsRepository.instance.dismissForToday(DateTime.now());
      if (mounted) _refreshProgress();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not dismiss the reminder.')),
        );
      }
    }
  }

  Widget _reminderCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FutureBuilder<_ReminderData>(
      future: _reminder,
      builder: (context, snapshot) {
        if (snapshot.data?.show != true) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Card(
            color: colors.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('A gentle nudge 🌱'),
                  const SizedBox(height: 8),
                  const Text('Feel like a short focus session?'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      TextButton(
                        onPressed: _dismissReminder,
                        child: const Text('Not today'),
                      ),
                      FilledButton(
                        onPressed: _openFocus,
                        child: const Text('Start focus'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _refreshProgress() {
    setState(() {
      _sessions = widget.services.sessions.all();
      _reminder = _readReminder();
    });
  }

  Future<void> _openFocus() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SessionScreen(services: widget.services),
      ),
    );
    if (mounted) _refreshProgress();
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => HistoryScreen(services: widget.services),
      ),
    );
    if (mounted) _refreshProgress();
  }

  void _openInsights() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => InsightsScreen(services: widget.services),
      ),
    );
  }

  void _openTips() {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => const TipsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FocusFlow',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            key: const ValueKey('open-settings'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            // Keep the familiar, reassuring companion and headline.
            Container(
              padding: const EdgeInsets.fromLTRB(22, 25, 22, 22),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const ExcludeSemantics(child: FlowBuddy(size: 82)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'A calmer moment starts here',
                          style: text.titleLarge?.copyWith(
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _openFocus,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start focus session'),
                  ),
                ],
              ),
            ),
            _reminderCard(context),
            const SizedBox(height: 24),
            Text('Your progress', style: text.titleLarge),
            const SizedBox(height: 10),
            FutureBuilder<List<Session>>(
              future: _sessions,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const _ProgressNotice(message: 'Progress unavailable');
                }
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final records = snapshot.data!;
                final now = DateTime.now();
                final weekStart = DateTime(
                  now.year,
                  now.month,
                  now.day,
                ).subtract(Duration(days: now.weekday - 1));
                final seconds = records
                    .where((session) => !session.startTime.isBefore(weekStart))
                    .fold<int>(
                      0,
                      (sum, session) => sum + (session.actualSeconds ?? 0),
                    );
                final focusTime = seconds >= 60
                    ? '${seconds ~/ 60} min'
                    : '$seconds sec';

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            value: focusTime,
                            label: 'this week',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 42,
                          color: scheme.outlineVariant,
                        ),
                        Expanded(
                          child: _MiniStat(
                            value: '${records.length}',
                            label: 'sessions saved',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            Text('Explore', style: text.titleLarge),
            const SizedBox(height: 10),
            _HomeLink(
              icon: Icons.bar_chart_rounded,
              title: 'Weekly insights',
              onTap: _openInsights,
            ),
            const SizedBox(height: 10),
            _HomeLink(
              icon: Icons.history_rounded,
              title: 'History',
              onTap: _openHistory,
            ),
            const SizedBox(height: 10),
            _HomeLink(
              icon: Icons.lightbulb_outline_rounded,
              title: 'Study tips',
              onTap: _openTips,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: text.titleLarge),
        const SizedBox(height: 3),
        Text(label, style: text.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }
}

class _ProgressNotice extends StatelessWidget {
  const _ProgressNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(18), child: Text(message)),
    );
  }
}

class _HomeLink extends StatelessWidget {
  const _HomeLink({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          child: Row(
            children: [
              Icon(icon, size: 28, color: scheme.primary),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: text.titleMedium)),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderData {
  const _ReminderData({required this.show});

  final bool show;
}
