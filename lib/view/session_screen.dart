import 'package:flutter/material.dart';

import '../presenter/session_presenter.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final SessionPresenter _presenter = SessionPresenter(initialMinutes: 25);

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FocusFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedBuilder(
        animation: _presenter,
        builder: (context, _) {
          final status = _presenter.status;
          final isReady = status == SessionStatus.ready;

          final endedEarly =
              status == SessionStatus.completed &&
              _presenter.remaining > Duration.zero;

          final statusText = switch (status) {
            SessionStatus.ready => 'Ready when you are',
            SessionStatus.running => 'Finding your flow',
            SessionStatus.paused => 'Taking a breather',
            SessionStatus.completed =>
              endedEarly ? 'Session ended early' : 'Session finished',
          };

          final totalMilliseconds = _presenter.durationMinutes * 60000;

          final progress =
              (1.0 - _presenter.remaining.inMilliseconds / totalMilliseconds)
                  .clamp(0.0, 1.0)
                  .toDouble();

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Text('Your focus space', style: textTheme.headlineMedium),
                const SizedBox(height: 8),

                Text(
                  'A little progress still counts. '
                  'Choose the pace that works for you.',
                  style: textTheme.bodyLarge,
                ),

                const SizedBox(height: 24),

                // Main timer card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        status == SessionStatus.running
                            ? Icons.self_improvement
                            : Icons.spa_outlined,
                        color: colors.onPrimaryContainer,
                        size: 36,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        statusText,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium,
                      ),

                      const SizedBox(height: 20),

                      // Accessible timer with stable digit widths
                      Semantics(
                        label: 'Time remaining: ${_presenter.formattedTime}',
                        child: ExcludeSemantics(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _presenter.formattedTime,
                              style: TextStyle(
                                fontSize: 68,
                                fontWeight: FontWeight.w700,
                                color: colors.onPrimaryContainer,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Visual progress
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: colors.surface.withValues(alpha: 0.7),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        status == SessionStatus.completed
                            ? endedEarly
                                  ? 'Stopping early is okay. '
                                        'You can begin again whenever you like.'
                                  : 'Your planned focus time is finished.'
                            : '${_presenter.durationMinutes}-minute session',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Session duration selection
                Text('Choose your duration', style: textTheme.titleMedium),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [15, 25, 40, 60].map((minutes) {
                    return ChoiceChip(
                      label: Text('$minutes min'),
                      selected: _presenter.durationMinutes == minutes,
                      onSelected: isReady
                          ? (_) => _presenter.setDuration(minutes)
                          : null,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                Text(
                  'Adjust from 5 to 120 minutes',
                  style: textTheme.bodyLarge,
                ),

                Slider(
                  min: 5,
                  max: 120,
                  divisions: 23,
                  value: _presenter.durationMinutes.clamp(5, 120).toDouble(),
                  label: '${_presenter.durationMinutes} minutes',
                  onChanged: isReady
                      ? (value) => _presenter.setDuration(value.round())
                      : null,
                ),

                const SizedBox(height: 24),

                // Start button
                if (status == SessionStatus.ready)
                  FilledButton.icon(
                    onPressed: _presenter.start,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start focusing'),
                  ),

                // Running session controls
                if (status == SessionStatus.running) ...[
                  FilledButton.icon(
                    onPressed: _presenter.pause,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause session'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _presenter.complete,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('End session'),
                  ),
                ],

                // Paused session controls
                if (status == SessionStatus.paused) ...[
                  FilledButton.icon(
                    onPressed: _presenter.resume,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume session'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _presenter.complete,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('End session'),
                  ),
                ],

                // Session completion feedback
                if (status == SessionStatus.completed) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Icon(Icons.favorite_border, size: 32),

                          const SizedBox(height: 8),

                          Text(
                            'Every effort matters',
                            style: textTheme.titleMedium,
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Reflecting on what worked '
                            'can help you find your rhythm.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  FilledButton.icon(
                    onPressed: _presenter.reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Begin another session'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
