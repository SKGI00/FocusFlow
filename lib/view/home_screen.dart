import 'package:flutter/material.dart';

import '../app_services.dart';
import '../model/models.dart';
import 'flow_buddy.dart';
import 'history_screen.dart';
import 'insights_screen.dart';
import 'session_screen.dart';
import 'tips_screen.dart';

/// A reassuring first screen with one primary action and low reading load.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Session>> _sessions = widget.services.sessions.all();

  void _refreshProgress() {
    setState(() {
      _sessions = widget.services.sessions.all();
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
