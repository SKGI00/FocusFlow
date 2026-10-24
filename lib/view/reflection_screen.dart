import 'package:flutter/material.dart';

import '../data/repositories.dart';
import '../presenter/reflection_presenter.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({
    super.key,
    required this.sessionId,
    required this.repository,
  });

  final int sessionId;
  final ReflectionRepository repository;

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  late final ReflectionPresenter _presenter = ReflectionPresenter(
    sessionId: widget.sessionId,
    repository: widget.repository,
  );

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await _presenter.save();
    if (!mounted) return;
    if (saved) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final fonts = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Reflection')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _presenter,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 34),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(
                    Icons.favorite_border_rounded,
                    size: 35,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'How did it feel?',
                style: fonts.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'There is no right answer. Reflect as much or as little as you like.',
                textAlign: TextAlign.center,
                style: fonts.bodyLarge,
              ),
              const SizedBox(height: 24),
              Text('Pick a feeling (optional)', style: fonts.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 9,
                children: [
                  for (
                    var index = 0;
                    index < ReflectionPresenter.feelingLabels.length;
                    index++
                  )
                    ChoiceChip(
                      label: Text(ReflectionPresenter.feelingLabels[index]),
                      selected: _presenter.rating == index + 1,
                      onSelected: _presenter.isSaving
                          ? null
                          : (_) => _presenter.selectFeeling(index + 1),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Text('What helped, or got in the way?', style: fonts.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 9,
                children: [
                  for (final tag in ReflectionPresenter.supportTags)
                    FilterChip(
                      label: Text(tag),
                      selected: _presenter.tags.contains(tag),
                      onSelected: _presenter.isSaving
                          ? null
                          : (_) => _presenter.toggleTag(tag),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              TextField(
                enabled: !_presenter.isSaving,
                maxLines: 3,
                maxLength: 400,
                textCapitalization: TextCapitalization.sentences,
                onChanged: _presenter.setNote,
                decoration: const InputDecoration(
                  labelText: 'A note to yourself (optional)',
                  hintText: 'Something I noticed today…',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_presenter.error != null) ...[
                const SizedBox(height: 8),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _presenter.error!,
                    style: TextStyle(color: colors.error),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _presenter.isSaving ? null : _save,
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  _presenter.isSaving ? 'Saving…' : 'Save reflection',
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _presenter.isSaving
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text('Skip for now'),
              ),
              const SizedBox(height: 12),
              Text(
                'Your reflection stays on this device.',
                style: fonts.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
