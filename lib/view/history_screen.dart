import 'package:flutter/material.dart';

import '../app_services.dart';
import '../model/models.dart';
import '../presenter/reflection_presenter.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.services});

  final AppServices services;

  String _dateTime(DateTime value) {
    final local = value.toLocal();
    final date = '${local.day}/${local.month}/${local.year}';
    final hours = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minutes = local.minute.toString().padLeft(2, '0');
    return '$date · $hours:$minutes ${local.hour < 12 ? 'am' : 'pm'}';
  }

  @override
  Widget build(BuildContext context) {
    final fonts = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Session history')),
      body: SafeArea(
        child: FutureBuilder<List<Session>>(
          future: services.sessions.all(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Could not load saved sessions.'),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final sessions = snapshot.data!;
            if (sessions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 52,
                        color: colors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your story starts with one session',
                        style: fonts.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Completed and early-ended sessions will appear here.',
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              itemCount: sessions.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your focus journey', style: fonts.headlineMedium),
                      const SizedBox(height: 6),
                      Text(
                        '${sessions.length} sessions saved on this device',
                        style: fonts.bodyLarge,
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }
                final session = sessions[index - 1];
                final duration = session.actualSeconds ?? 0;
                final durationText = duration >= 60
                    ? '${duration ~/ 60} min ${duration % 60} sec'
                    : '$duration sec';
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: colors.secondaryContainer,
                              child: Icon(
                                Icons.timer_outlined,
                                color: colors.onSecondaryContainer,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _dateTime(session.startTime),
                                    style: fonts.titleMedium,
                                  ),
                                  Text(
                                    session.endTime == null
                                        ? 'Not yet ended'
                                        : session.completed
                                        ? 'Focus session completed'
                                        : 'Ended early',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Focused: $durationText · Planned: ${session.plannedMinutes} min',
                        ),
                        if (session.id != null)
                          FutureBuilder<int>(
                            future: services.distractions.countForSession(
                              session.id!,
                            ),
                            builder: (context, count) {
                              if (!count.hasData) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  'Distractions noted: ${count.data}',
                                ),
                              );
                            },
                          ),
                        if (session.id != null)
                          FutureBuilder<Reflection?>(
                            future: services.reflections.forSession(
                              session.id!,
                            ),
                            builder: (context, saved) {
                              if (!saved.hasData) {
                                return const SizedBox.shrink();
                              }
                              final reflection = saved.data!;
                              final feeling =
                                  ReflectionPresenter.labelForRating(
                                    reflection.rating,
                                  );
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Reflection: $feeling'
                                  '${reflection.note == null ? '' : ' · ${reflection.note}'}',
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
