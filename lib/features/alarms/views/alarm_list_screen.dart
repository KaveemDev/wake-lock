import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/db/models/alarm.dart';
import '../../../core/utils/alarm_time_utils.dart';
import '../providers/alarms_provider.dart';
import 'alarm_edit_screen.dart';

class AlarmListScreen extends ConsumerWidget {
  const AlarmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmsAsync = ref.watch(alarmsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'FOCUS ALARM',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings / Mission preferences coming in Phase 3!')),
              );
            },
          ),
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
                      const Color(0xFF1E1E2C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.tealAccent.withOpacity(0.2)),
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Phase 2 Checkpoint Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amberAccent, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Phase 2 Checkpoint: Tap + to create & manage recurring alarms.',
                        style: TextStyle(color: Colors.amberAccent, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

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

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: alarm.enabled
                                  ? const Color(0xFF1E1E2C)
                                  : const Color(0xFF161620),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: alarm.enabled
                                    ? Colors.tealAccent.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.05),
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
                                                Text(
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
                                                const SizedBox(width: 8),
                                                Text(
                                                  repeatStr,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: alarm.enabled
                                                        ? Colors.tealAccent
                                                        : Colors.white24,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              alarm.label,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: alarm.enabled
                                                    ? Colors.white70
                                                    : Colors.white30,
                                              ),
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
