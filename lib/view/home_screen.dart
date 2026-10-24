import 'package:flutter/material.dart';

import '../app_services.dart';
import '../model/models.dart';
import 'flow_buddy.dart';
import 'history_screen.dart';
import 'session_screen.dart';
import 'tips_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Session>> _sessions = widget.services.sessions.all();

  void _refresh() {
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
    if (mounted) _refresh();
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => HistoryScreen(services: widget.services),
      ),
    );
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FocusFlow',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Study tips',
            icon: const Icon(Icons.lightbulb_outline_rounded),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => const TipsScreen()),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text('Welcome to your space', style: fonts.headlineMedium),
            const SizedBox(height: 6),
            Text(
              'Small steps. Your pace. No pressure to be perfect.',
              style: fonts.bodyLarge,
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const FlowBuddy(size: 78),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'A calmer moment starts here',
                          style: fonts.titleLarge?.copyWith(
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Choose a focus time, notice distractions gently, '
                    'and reflect only if you want to.',
                    style: fonts.bodyLarge?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _openFocus,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Start a focus session'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Your progress', style: fonts.titleLarge),
            const SizedBox(height: 12),
            FutureBuilder<List<Session>>(
              future: _sessions,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _ProgressTile(
                    message: 'Your saved sessions could not be loaded.',
                    caption: 'Try opening this screen again.',
                    icon: Icons.info_outline,
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
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
                final focusText = seconds >= 60
                    ? '${seconds ~/ 60} min'
                    : '$seconds sec';
                return _ProgressTile(
                  message: focusText,
                  caption:
                      'Focus recorded this week · ${records.length} saved sessions in total',
                  icon: Icons.auto_graph_rounded,
                );
              },
            ),
            const SizedBox(height: 22),
            Text('Explore', style: fonts.titleLarge),
            const SizedBox(height: 12),
            _FeatureTile(
              icon: Icons.history_rounded,
              title: 'Session history',
              description: 'See your sessions and distractions.',
              onTap: _openHistory,
            ),
            const SizedBox(height: 10),
            _FeatureTile(
              icon: Icons.lightbulb_outline_rounded,
              title: 'Gentle study tips',
              description: 'Helpful ideas, available offline.',
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => const TipsScreen()),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Your focus records stay on this device. No account needed.',
              textAlign: TextAlign.center,
              style: fonts.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({
    required this.message,
    required this.caption,
    required this.icon,
  });

  final String message;
  final String caption;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: colors.secondaryContainer,
              child: Icon(icon, color: colors.onSecondaryContainer),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: fonts.titleLarge),
                  const SizedBox(height: 4),
                  Text(caption, style: fonts.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: colors.primary, size: 29),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: fonts.titleMedium),
                    const SizedBox(height: 3),
                    Text(description, style: fonts.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
