import 'package:flutter/material.dart';

import '../app_services.dart';
import '../presenter/session_presenter.dart';
import 'flow_buddy.dart';
import 'reflection_screen.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key, this.services});

  final AppServices? services;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late final SessionPresenter _presenter = SessionPresenter(
    initialMinutes: 25,
    sessions: widget.services?.sessions,
    distractions: widget.services?.distractions,
  );

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  Future<void> _openReflection() async {
    final services = widget.services;
    if (services == null) return;

    final id = await _presenter.savedSessionId();
    if (!mounted) return;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The session could not be saved. Please try again.'),
        ),
      );
      return;
    }

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            ReflectionScreen(sessionId: id, repository: services.reflections),
      ),
    );

    if (!mounted || saved == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Reflection saved. Thanks for showing up.'
              : 'Reflection skipped. That is completely fine.',
        ),
      ),
    );
    // Both Save and Skip return to Home, where data is reloaded from SQLite.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      _presenter.reset();
    }
  }

  void _returnHome() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      _presenter.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fonts = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FocusFlow',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: AnimatedBuilder(
        animation: _presenter,
        builder: (context, _) {
          final status = _presenter.status;
          final ready = status == SessionStatus.ready;
          final active =
              status == SessionStatus.running || status == SessionStatus.paused;
          final completed = status == SessionStatus.completed;

          final title = switch (status) {
            SessionStatus.ready => 'Ready when you are',
            SessionStatus.running => 'Finding your flow',
            SessionStatus.paused => 'Take a breather',
            SessionStatus.completed =>
              _presenter.endedEarly
                  ? 'Session ended early'
                  : 'Session finished',
          };
          final progress =
              (1 -
                      _presenter.remaining.inMilliseconds /
                          (_presenter.durationMinutes * 60000))
                  .clamp(0.0, 1.0);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              children: [
                Text('Your focus space', style: fonts.headlineMedium),
                const SizedBox(height: 5),
                Text(
                  ready
                      ? 'Choose a pace that works for you.'
                      : completed
                      ? 'Your effort matters, however long you focused.'
                      : 'One moment at a time. You are doing enough.',
                  style: fonts.bodyLarge,
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 19, 20, 20),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      FlowBuddy(
                        size: 76,
                        resting: status == SessionStatus.paused,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: fonts.titleMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: 'Time remaining: ${_presenter.formattedTime}',
                        child: ExcludeSemantics(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _presenter.formattedTime,
                              style: TextStyle(
                                fontSize: 66,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.5,
                                color: colors.onPrimaryContainer,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        borderRadius: BorderRadius.circular(9),
                        backgroundColor: colors.surface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        completed
                            ? _presenter.endedEarly
                                  ? 'Stopping early is okay.'
                                  : 'Your planned focus time is finished.'
                            : '${_presenter.durationMinutes}-minute session',
                        style: fonts.bodyMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                if (ready) ...[
                  Text('Choose your duration', style: fonts.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [15, 25, 40, 60].map((minutes) {
                      return ChoiceChip(
                        label: Text('$minutes min'),
                        selected: _presenter.durationMinutes == minutes,
                        onSelected: (_) => _presenter.setDuration(minutes),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Or adjust between 5 and 120 minutes',
                    style: fonts.bodyMedium,
                  ),
                  Slider(
                    min: 5,
                    max: 120,
                    divisions: 23,
                    value: _presenter.durationMinutes.clamp(5, 120).toDouble(),
                    label: '${_presenter.durationMinutes} minutes',
                    onChanged: (value) => _presenter.setDuration(value.round()),
                  ),
                  const SizedBox(height: 4),
                  FilledButton.icon(
                    onPressed: _presenter.start,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start focusing'),
                  ),
                ],

                if (status == SessionStatus.running) ...[
                  FilledButton.icon(
                    onPressed: _presenter.pause,
                    icon: const Icon(Icons.pause_rounded),
                    label: const Text('Pause session'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _presenter.complete,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('End session'),
                  ),
                ],

                if (status == SessionStatus.paused) ...[
                  FilledButton.icon(
                    onPressed: _presenter.resume,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Resume session'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _presenter.complete,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('End session'),
                  ),
                ],

                if (active && widget.services != null) ...[
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.bubble_chart_outlined,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Got distracted?',
                                  style: fonts.titleMedium,
                                ),
                              ),
                              Semantics(
                                liveRegion: true,
                                label:
                                    'Distractions noted: ${_presenter.distractionCount}',
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: colors.secondaryContainer,
                                  child: Text('${_presenter.distractionCount}'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Tap a tag and carry on.',
                            style: fonts.bodyMedium,
                          ),
                          const SizedBox(height: 9),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              for (final tag in [
                                'Phone',
                                'Noise',
                                'Thoughts',
                                'Other',
                              ])
                                ActionChip(
                                  label: Text(tag),
                                  onPressed: () =>
                                      _presenter.logDistraction(tag),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                if (_presenter.saveError != null) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _presenter.saveError!,
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                ],

                if (completed) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(17),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_border_rounded,
                            size: 28,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Every effort matters',
                                  style: fonts.titleMedium,
                                ),
                                const SizedBox(height: 3),
                                const Text('A short check-in is optional.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.services != null) ...[
                    FilledButton.icon(
                      onPressed: _openReflection,
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text('Reflect or skip'),
                    ),
                    const SizedBox(height: 9),
                    OutlinedButton(
                      onPressed: _returnHome,
                      child: const Text('Back to Home'),
                    ),
                    const SizedBox(height: 9),
                  ],
                  OutlinedButton.icon(
                    onPressed: _presenter.reset,
                    icon: const Icon(Icons.refresh_rounded),
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
