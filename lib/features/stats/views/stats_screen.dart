import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/utils/alarm_time_utils.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(alarmHistoryStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'WAKE-UP STATISTICS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 80, color: Colors.white.withOpacity(0.15)),
                  const SizedBox(height: 16),
                  const Text(
                    'No Wake-Up History Yet',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete dismissal missions to build your streak & discipline score!',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final totalDismissed = history.length;
          final totalSecs = history.fold<int>(0, (sum, item) => sum + item.dismissTimeSeconds);
          final avgSecs = totalDismissed > 0 ? (totalSecs / totalDismissed).round() : 0;
          final totalSnoozes = history.fold<int>(0, (sum, item) => sum + item.snoozeCount);
          final zeroSnoozeCount = history.where((h) => h.snoozeCount == 0).length;
          final disciplineScore = totalDismissed > 0 ? ((zeroSnoozeCount / totalDismissed) * 100).round() : 100;

          return SafeArea(
            child: Column(
              children: [
                // Top Metrics Grid
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.6,
                    children: [
                      _buildMetricCard(
                        'DISCIPLINE SCORE',
                        '$disciplineScore%',
                        Icons.military_tech,
                        disciplineScore >= 80 ? Colors.tealAccent : Colors.amberAccent,
                      ),
                      _buildMetricCard(
                        'MISSIONS SOLVED',
                        '$totalDismissed',
                        Icons.assignment_turned_in,
                        Colors.blueAccent,
                      ),
                      _buildMetricCard(
                        'AVG DISMISS SPEED',
                        '${avgSecs}s',
                        Icons.timer,
                        Colors.purpleAccent,
                      ),
                      _buildMetricCard(
                        'TOTAL SNOOZES',
                        '$totalSnoozes',
                        Icons.snooze,
                        totalSnoozes == 0 ? Colors.tealAccent : Colors.orangeAccent,
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'RECENT WAKE-UP LOGS',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      final dateStr = '${item.timestamp.month}/${item.timestamp.day} at ${AlarmTimeUtils.formatTime(item.timestamp)}';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2C),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.tealAccent.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.alarm_on, color: Colors.tealAccent, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.alarmLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$dateStr • Mission: ${item.missionType.toUpperCase()}',
                                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.dismissTimeSeconds}s',
                                  style: const TextStyle(
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  item.snoozeCount == 0 ? 'No snoozes' : '${item.snoozeCount} snoozed',
                                  style: TextStyle(
                                    color: item.snoozeCount == 0 ? Colors.white38 : Colors.amberAccent,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
        error: (err, stack) => Center(child: Text('Error loading stats: $err')),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
