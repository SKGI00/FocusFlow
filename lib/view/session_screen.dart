import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_services.dart';
import '../presenter/session_presenter.dart';
import '../utils/focus_duration.dart';
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
    initialMinutes: 30,
    sessions: widget.services?.sessions,
    distractions: widget.services?.distractions,
  );

  // Visual preview only: no audio dependency, assets, or playback.
  bool _soundOptionsExpanded = false;
  String _previewSound = 'Off';

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  Future<void> _pickCustomDuration() async {
    final formKey = GlobalKey<FormState>();
    final current = _presenter.durationMinutes;
    String input = '$current';

    final minutes = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Custom duration'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: '$current',
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 3,
            decoration: const InputDecoration(
              labelText: 'Minutes',
              helperText: 'Between 3 and 120 minutes',
              border: OutlineInputBorder(),
              counterText: '',
            ),
            validator: (value) => FocusDuration.parse(value ?? '') == null
                ? 'Enter 3–120 minutes'
                : null,
            onChanged: (value) => input = value,
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(FocusDuration.parse(input));
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(FocusDuration.parse(input));
              }
            },
            child: const Text('Set duration'),
          ),
        ],
      ),
    );

    if (mounted &&
        minutes != null &&
        _presenter.status == SessionStatus.ready) {
      _presenter.setDuration(minutes);
    }
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

  Widget _durationChoice(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label duration',
      child: Material(
        color: selected ? colors.secondaryContainer : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: selected
                ? colors.primary
                : colors.outline.withValues(alpha: 0.45),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            height: 79,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: colors.onSurface, size: 24),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _durationOptions(BuildContext context) {
    final selected = _presenter.durationMinutes;
    final options =
        <({String label, IconData icon, bool chosen, VoidCallback onTap})>[
          for (final value in [15, 30, 60])
            (
              label: '$value min',
              icon: Icons.schedule_rounded,
              chosen: selected == value,
              onTap: () => _presenter.setDuration(value),
            ),
          (
            label: 'Custom',
            icon: Icons.edit_outlined,
            chosen: ![15, 30, 60].contains(selected),
            onTap: _pickCustomDuration,
          ),
        ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
        final columns = constraints.maxWidth < 325 || largeText ? 2 : 4;
        const gap = 8.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final option in options)
              SizedBox(
                width: width,
                child: _durationChoice(
                  context,
                  label: option.label,
                  icon: option.icon,
                  selected: option.chosen,
                  onTap: option.onTap,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _soundPreviewChoice(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;
    final chosen = _previewSound == label;
    return Semantics(
      button: true,
      selected: chosen,
      label: '$label sound concept. Preview only, no sound plays.',
      child: Material(
        color: chosen ? colors.secondaryContainer : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: chosen
                ? colors.primary
                : colors.outline.withValues(alpha: 0.32),
          ),
        ),
        child: InkWell(
          key: ValueKey('preview-$label'),
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _previewSound = label),
          child: SizedBox(
            height: 68,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 23, color: colors.onSurface),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: chosen ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _focusSounds(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The dropdown itself is functional. Audio is not part of this MVP.
          InkWell(
            key: const ValueKey('focus-sounds-toggle'),
            borderRadius: BorderRadius.circular(16),
            onTap: () =>
                setState(() => _soundOptionsExpanded = !_soundOptionsExpanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.graphic_eq_rounded, color: colors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Focus sounds', style: fonts.titleMedium),
                  ),
                  Text(
                    'Optional idea',
                    style: fonts.bodySmall?.copyWith(color: colors.primary),
                  ),
                  const SizedBox(width: 7),
                  Icon(
                    _soundOptionsExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (_soundOptionsExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview only — coming later. No audio plays.',
                    style: fonts.bodySmall,
                  ),
                  const SizedBox(height: 11),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final largeText =
                          MediaQuery.textScalerOf(context).scale(14) > 20;
                      final columns = constraints.maxWidth < 310 || largeText
                          ? 2
                          : 4;
                      const gap = 8.0;
                      final width =
                          (constraints.maxWidth - gap * (columns - 1)) /
                          columns;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          SizedBox(
                            width: width,
                            child: _soundPreviewChoice(
                              context,
                              label: 'Forest',
                              icon: Icons.park_rounded,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: _soundPreviewChoice(
                              context,
                              label: 'Rain',
                              icon: Icons.water_drop_rounded,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: _soundPreviewChoice(
                              context,
                              label: 'White noise',
                              icon: Icons.waves_rounded,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: _soundPreviewChoice(
                              context,
                              label: 'Off',
                              icon: Icons.volume_off_rounded,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                Text('Your focus space', style: fonts.headlineMedium),
                const SizedBox(height: 5),
                Text(
                  ready
                      ? 'Choose a pace that works for you.'
                      : completed
                      ? 'Your effort matters, however long you focused.'
                      : 'One moment at a time.',
                  style: fonts.bodyLarge,
                ),
                const SizedBox(height: 17),
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
                      const SizedBox(height: 9),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: fonts.titleMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Semantics(
                        label: 'Time remaining: ${_presenter.formattedTime}',
                        child: ExcludeSemantics(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _presenter.formattedTime,
                              style: TextStyle(
                                fontSize: 68,
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
                      const SizedBox(height: 13),
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
                                  : 'Your focus time is finished.'
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
                  _durationOptions(context),
                  const SizedBox(height: 13),
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

                if (!completed) ...[
                  const SizedBox(height: 13),
                  _focusSounds(context),
                ],

                if (active && widget.services != null) ...[
                  const SizedBox(height: 12),
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
                                    'Distractions noted: '
                                    '${_presenter.distractionCount}',
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: colors.secondaryContainer,
                                  child: Text('${_presenter.distractionCount}'),
                                ),
                              ),
                            ],
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
                  const SizedBox(height: 12),
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
