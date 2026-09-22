import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/shared_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/study_session.dart';
import '../../data/models/subject.dart';
import '../home/providers/home_providers.dart';
import 'log_session_sheet.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(weekStudySessionsProvider);
    final checkinsAsync = ref.watch(weekCheckinsProvider);
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(weekStudySessionsProvider);
            ref.invalidate(weekCheckinsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Study analytics',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  IconButton.filled(
                    onPressed: () => showLogSessionSheet(context),
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(backgroundColor: AppColors.ctaDark),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              sessionsAsync.when(
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => const SizedBox.shrink(),
                data: (sessions) => _WeeklyMinutesCard(sessions: sessions),
              ),
              const SizedBox(height: 20),
              checkinsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
                data: (checkins) {
                  final done = checkins.where((c) => c.completed).length;
                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Days on track',
                          value: '$done / 7',
                        ),
                      ),
                      const SizedBox(width: 14),
                      sessionsAsync.when(
                        loading: () => const Expanded(child: SizedBox.shrink()),
                        error: (e, st) => const Expanded(child: SizedBox.shrink()),
                        data: (sessions) {
                          final total = sessions.fold<int>(
                              0, (sum, s) => sum + (s.durationMinutes ?? 0));
                          final hours = (total / 60);
                          return Expanded(
                            child: _StatCard(
                              label: 'Study time',
                              value: '${hours.toStringAsFixed(1)} h',
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('By subject',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              sessionsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
                data: (sessions) => subjectsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (e, st) => const SizedBox.shrink(),
                  data: (subjects) => _SubjectBreakdown(sessions: sessions, subjects: subjects),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyMinutesCard extends StatelessWidget {
  const _WeeklyMinutesCard({required this.sessions});

  final List<StudySession> sessions;

  static const _labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final startOfWeek = todayNorm.subtract(Duration(days: todayNorm.weekday % 7));

    final minutesPerDay = List<int>.filled(7, 0);
    for (final session in sessions) {
      final day = DateTime(session.startedAt.year, session.startedAt.month, session.startedAt.day);
      final index = day.difference(startOfWeek).inDays;
      if (index >= 0 && index < 7) {
        minutesPerDay[index] += session.durationMinutes ?? 0;
      }
    }
    final todayIndex = todayNorm.difference(startOfWeek).inDays;
    final maxMinutes = minutesPerDay.fold<int>(0, (m, v) => v > m ? v : m);
    final maxY = (maxMinutes < 30 ? 30 : maxMinutes).toDouble() * 1.2;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Minutes studied this week',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                barTouchData: BarTouchData(enabled: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i > 6) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _labels[i],
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < 7; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: minutesPerDay[i].toDouble(),
                          color: i == todayIndex ? AppColors.primary : AppColors.surface,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SubjectBreakdown extends StatelessWidget {
  const _SubjectBreakdown({required this.sessions, required this.subjects});

  final List<StudySession> sessions;
  final List<Subject> subjects;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Text('Log a study session to see your subject breakdown.',
          style: TextStyle(color: AppColors.textSecondary));
    }
    final byId = {for (final s in subjects) s.id: s};
    final minutesBySubject = <String?, int>{};
    for (final session in sessions) {
      minutesBySubject.update(
        session.subjectId,
        (v) => v + (session.durationMinutes ?? 0),
        ifAbsent: () => session.durationMinutes ?? 0,
      );
    }
    final entries = minutesBySubject.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        for (final entry in entries)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _colorFor(entry.key, byId),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key == null ? 'No subject' : (byId[entry.key]?.name ?? 'Unknown'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text('${entry.value} min',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }

  Color _colorFor(String? subjectId, Map<String, Subject> byId) {
    final hex = subjectId == null ? null : byId[subjectId]?.color;
    if (hex == null || hex.isEmpty) return AppColors.textMuted;
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
