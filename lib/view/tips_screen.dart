import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  static const tips = <(IconData, String, String)>[
    (
      Icons.play_circle_outline,
      'Start small',
      'Try five minutes if a longer session feels difficult.',
    ),
    (
      Icons.volume_off_outlined,
      'Make space for focus',
      'Reduce one distraction you can control, if that helps.',
    ),
    (
      Icons.self_improvement,
      'Take a breather',
      'A pause can be part of studying. You can return when you are ready.',
    ),
    (
      Icons.edit_note_rounded,
      'Notice what worked',
      'A short reflection can make patterns easier to recognise.',
    ),
    (
      Icons.favorite_border_rounded,
      'Be kind to yourself',
      'One difficult session does not undo the effort you have made.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final fonts = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Study tips')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            Text('Little things can help', style: fonts.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Gentle ideas you can try or ignore. No pressure.',
              style: fonts.bodyLarge,
            ),
            const SizedBox(height: 22),
            for (final (icon, title, description) in tips) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundColor: colors.primaryContainer,
                        child: Icon(icon, color: colors.onPrimaryContainer),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: fonts.titleMedium),
                            const SizedBox(height: 5),
                            Text(description, style: fonts.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              'Tips are bundled with the app and work offline.',
              textAlign: TextAlign.center,
              style: fonts.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
