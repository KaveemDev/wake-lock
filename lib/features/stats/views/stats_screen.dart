import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/ui/app_ui.dart';
import '../../../core/utils/alarm_time_utils.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(alarmHistoryStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stats',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: GlowBackground(
        color: AppColors.accent2,
        child: historyAsync.when(
          data: (history) {
            if (history.isEmpty) return _empty();

            final total = history.length;
            final totalSecs = history.fold<int>(
              0,
              (s, h) => s + h.dismissTimeSeconds,
            );
            final avgSecs = (totalSecs / total).round();
            final totalSnoozes = history.fold<int>(
              0,
              (s, h) => s + h.snoozeCount,
            );
            final zeroSnooze = history.where((h) => h.snoozeCount == 0).length;
            final score = ((zeroSnooze / total) * 100).round();

            final metrics = [
              (
                'Score',
                score,
                '%',
                Icons.military_tech_rounded,
                score >= 80 ? AppColors.success : AppColors.warn,
              ),
              (
                'Missions done',
                total,
                '',
                Icons.task_alt_rounded,
                AppColors.accent2,
              ),
              (
                'Avg. time to dismiss',
                avgSecs,
                's',
                Icons.timer_rounded,
                AppColors.accent2,
              ),
              (
                'Snoozes',
                totalSnoozes,
                '',
                Icons.snooze_rounded,
                totalSnoozes == 0 ? AppColors.success : AppColors.warn,
              ),
            ];

            return SafeArea(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: history.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.45,
                        children: [
                          for (var i = 0; i < metrics.length; i++)
                            FadeSlideIn(
                              delay: FadeSlideIn.stagger(i),
                              child: _metricCard(
                                metrics[i].$1,
                                metrics[i].$2,
                                metrics[i].$3,
                                metrics[i].$4,
                                metrics[i].$5,
                              ),
                            ),
                        ],
                      ),
                    );
                  }
                  if (index == 1) return const SectionLabel('Recent');

                  final item = history[index - 2];
                  final dateStr =
                      '${item.timestamp.month}/${item.timestamp.day} at ${AlarmTimeUtils.formatTime(item.timestamp)}';
                  final clean = item.snoozeCount == 0;
                  return FadeSlideIn(
                    delay: FadeSlideIn.stagger(index),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.alarm_on_rounded,
                                color: AppColors.accent,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.alarmLabel,
                                    style: TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '$dateStr · ${item.missionType}',
                                    style: TextStyle(
                                      color: AppColors.textDim,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.dismissTimeSeconds}s',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  clean
                                      ? 'No snoozes'
                                      : '${item.snoozeCount} snoozed',
                                  style: TextStyle(
                                    color: clean
                                        ? AppColors.textFaint
                                        : AppColors.warn,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading stats: $err')),
        ),
      ),
    );
  }

  Widget _empty() => Center(
    child: FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Icons.insights_rounded,
                size: 52,
                color: AppColors.accent2.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'No wake-ups yet',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Finish a mission to start your score.',
              style: TextStyle(color: AppColors.textDim, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _metricCard(
    String title,
    int value,
    String suffix,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: color.withValues(alpha: 0.3),
      gradient: LinearGradient(
        colors: [color.withValues(alpha: 0.14), AppColors.surface],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: CountUp(
              value: value,
              suffix: suffix,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
