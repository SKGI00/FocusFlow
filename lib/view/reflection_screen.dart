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
                  radius: 32,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(
                    Icons.favorite_border_rounded,
                    size: 32,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'How did your focus session go?',
                style: fonts.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 7),
              Text(
                'Optional — you can skip this.',
                textAlign: TextAlign.center,
                style: fonts.bodyMedium,
              ),
              const SizedBox(height: 23),
              // Four compact options on standard phones; two columns when the
              // screen or text scale is larger, to avoid overflow.
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      constraints.maxWidth < 340 ||
                          MediaQuery.textScalerOf(context).scale(14) > 19
                      ? 2
                      : 4;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ReflectionPresenter.feelingLabels.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      mainAxisExtent: 80,
                    ),
                    itemBuilder: (context, index) {
                      final label = ReflectionPresenter.feelingLabels[index];
                      // Keep the NZ name in stored history; display the gesture
                      // only once, beneath the word on this compact control.
                      final displayLabel = label == 'Choice 🤙'
                          ? 'Choice'
                          : label;
                      final value = ReflectionPresenter.feelingRatings[index];
                      final isSelected = _presenter.rating == value;
                      return Semantics(
                        button: true,
                        selected: isSelected,
                        label: '$label session rating',
                        child: Material(
                          color: isSelected
                              ? colors.primaryContainer
                              : colors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isSelected
                                  ? colors.primary
                                  : colors.outlineVariant,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _presenter.isSaving
                                ? null
                                : () => _presenter.selectFeeling(value),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    displayLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: fonts.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  ExcludeSemantics(
                                    child: Text(
                                      ReflectionPresenter.feelingEmoji[index],
                                      style: const TextStyle(fontSize: 21),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('What helped or distracted you?', style: fonts.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 10,
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
                  labelText: 'Add a note (optional)',
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
