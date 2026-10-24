import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../analytics/focus_analytics.dart';
import '../app_services.dart';
import '../model/models.dart';
import 'flow_buddy.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late Future<List<Session>> _sessions = widget.services.sessions.all();
  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Future<void> _refresh() async {
    setState(() => _sessions = widget.services.sessions.all());
    await _sessions;
  }

  @override
  Widget build(BuildContext context) {
    final fonts = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly insights')),
      body: SafeArea(
        child: FutureBuilder<List<Session>>(
          future: _sessions,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Could not load your focus insights.'),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final records = snapshot.data!;
            final now = DateTime.now();
            final daily = weeklyFocusTotals(records, now);
            final total = daily.fold<int>(0, (sum, item) => sum + item.seconds);
            final streak = calculateGentleStreak(records, now);
            final colors = Theme.of(context).colorScheme;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  Text('Your week, at your pace', style: fonts.headlineMedium),
                  const SizedBox(height: 7),
                  Text(
                    'Notice patterns, not perfection. Your focus data stays on this device.',
                    style: fonts.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        const FlowBuddy(size: 70),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time you showed up',
                                style: fonts.titleMedium,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                readableFocusTime(total),
                                style: fonts.headlineMedium,
                              ),
                              Text(
                                'This week · Monday to Sunday',
                                style: fonts.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily focus', style: fonts.titleLarge),
                          const SizedBox(height: 6),
                          Text(
                            'Recorded minutes for each day',
                            style: fonts.bodyMedium,
                          ),
                          const SizedBox(height: 18),
                          if (total == 0)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 25),
                              child: Center(
                                child: Text(
                                  'No focus time recorded this week yet.',
                                ),
                              ),
                            )
                          else
                            Semantics(
                              label: [
                                for (var i = 0; i < 7; i++)
                                  '${_labels[i]} ${readableFocusTime(daily[i].seconds)}',
                              ].join(', '),
                              child: SizedBox(
                                height: 190,
                                child: BarChart(
                                  BarChartData(
                                    maxY: math.max(
                                      1.0,
                                      daily
                                              .map((e) => e.minutes)
                                              .reduce(math.max) *
                                          1.2,
                                    ),
                                    minY: 0,
                                    alignment: BarChartAlignment.spaceAround,
                                    barTouchData: BarTouchData(enabled: false),
                                    gridData: const FlGridData(show: false),
                                    borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: (value, _) {
                                            final day = value.toInt();
                                            if (day < 0 ||
                                                day >= _labels.length) {
                                              return const SizedBox.shrink();
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 7,
                                              ),
                                              child: Text(
                                                _labels[day],
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    barGroups: [
                                      for (var i = 0; i < daily.length; i++)
                                        BarChartGroupData(
                                          x: i,
                                          barRods: [
                                            BarChartRodData(
                                              toY: daily[i].minutes,
                                              color: colors.primary,
                                              width: 18,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(6),
                                                    topRight: Radius.circular(
                                                      6,
                                                    ),
                                                  ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          for (var i = 0; i < daily.length; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_labels[i]),
                                  Text(readableFocusTime(daily[i].seconds)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.spa_outlined, color: colors.primary),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'Your gentle rhythm',
                                  style: fonts.titleLarge,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            streak.currentDays == 0
                                ? 'Every day can be a new start.'
                                : '${streak.currentDays} focus ${streak.currentDays == 1 ? 'day' : 'days'} in your current rhythm',
                            style: fonts.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text('Best rhythm: ${streak.bestDays} focus days'),
                          const SizedBox(height: 9),
                          const Text(
                            'One rest day can be bridged. Taking breaks is part of studying, not a failure.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
