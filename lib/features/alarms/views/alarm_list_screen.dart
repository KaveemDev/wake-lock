import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/utils/alarm_time_utils.dart';
import '../../missions/models/mission.dart';
import '../../permissions/views/permissions_screen.dart';
import '../../stats/views/stats_screen.dart';
import '../providers/alarms_provider.dart';
import 'alarm_edit_screen.dart';

class AlarmListScreen extends ConsumerWidget {
  const AlarmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmsAsync = ref.watch(alarmsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'WAKELOCK',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.security, color: Colors.tealAccent, size: 26),
            tooltip: 'App Permissions',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PermissionsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: Colors.tealAccent, size: 28),
            tooltip: 'Statistics & History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: alarmsAsync.when(
        data: (alarms) {
          final activeAlarms = alarms.where((a) => a.enabled).toList();
          activeAlarms.sort((a, b) => a.time.compareTo(b.time));
          final nextAlarm = activeAlarms.isNotEmpty ? activeAlarms.first : null;

          return Column(
            children: [
              // Next Ring Hero Banner
              Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal.withOpacity(0.25),
                      const Color(0xFF181824),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.alarm, color: Colors.tealAccent, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextAlarm != null
                                ? AlarmTimeUtils.formatCountdown(nextAlarm.time)
                                : 'All alarms disabled',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nextAlarm != null
                                ? 'Next: ${nextAlarm.label} at ${AlarmTimeUtils.formatTime(nextAlarm.time)}'
                                : 'Tap + below to set your wake-up alarm',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Alarms List
              Expanded(
                child: alarms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.alarm_add, size: 72, color: Colors.white.withOpacity(0.15)),
                            const SizedBox(height: 16),
                            const Text(
                              'No Alarms Yet',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap the + button to create your first alarm',
                              style: TextStyle(color: Colors.white38, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: alarms.length,
                        itemBuilder: (context, index) {
                          final alarm = alarms[index];
                          final repeatStr = AlarmTimeUtils.formatRepeatDays(alarm.repeatDays);
                          final missionCfg = MissionConfig(
                            type: alarm.missionType,
                            difficulty: alarm.missionDifficulty,
                            count: alarm.missionCount,
                          );

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: alarm.enabled
                                  ? const Color(0xFF181824)
                                  : const Color(0xFF14141E),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: alarm.enabled
                                    ? Colors.tealAccent.withOpacity(0.35)
                                    : Colors.white.withOpacity(0.06),
                              ),
                              boxShadow: alarm.enabled
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AlarmEditScreen(existingAlarm: alarm),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.baseline,
                                              textBaseline: TextBaseline.alphabetic,
                                              children: [
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    AlarmTimeUtils.formatTime(alarm.time),
                                                    style: TextStyle(
                                                      fontSize: 38,
                                                      fontWeight: FontWeight.w900,
                                                      color: alarm.enabled
                                                          ? Colors.white
                                                          : Colors.white38,
                                                      letterSpacing: -1,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    repeatStr,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: alarm.enabled
                                                          ? Colors.tealAccent
                                                          : Colors.white24,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 6,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: [
                                                Text(
                                                  alarm.label,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: alarm.enabled
                                                        ? Colors.white
                                                        : Colors.white38,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: Colors.tealAccent.withOpacity(0.12),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    missionCfg.displayName,
                                                    style: const TextStyle(
                                                      color: Colors.tealAccent,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                if (alarm.isHardcoreMode)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 6, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: Colors.redAccent.withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.local_fire_department,
                                                            size: 12, color: Colors.redAccent),
                                                        SizedBox(width: 2),
                                                        Text(
                                                          'HC',
                                                          style: TextStyle(
                                                            color: Colors.redAccent,
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                if (alarm.isVerificationRequired)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 6, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: Colors.cyanAccent.withOpacity(0.15),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.verified_user,
                                                            size: 11, color: Colors.cyanAccent),
                                                        SizedBox(width: 3),
                                                        Text(
                                                          'VERIFY',
                                                          style: TextStyle(
                                                            color: Colors.cyanAccent,
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: alarm.enabled,
                                        activeColor: Colors.tealAccent,
                                        onChanged: (val) {
                                          ref
                                              .read(alarmsControllerProvider)
                                              .toggleAlarm(alarm, val);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
        error: (err, stack) => Center(child: Text('Error loading alarms: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
        elevation: 8,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AlarmEditScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add, size: 24, fontWeight: FontWeight.bold),
        label: const Text(
          'ADD ALARM',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
    );
  }
}
