import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/db/models/alarm.dart';
import '../../../core/db/models/alarm_history.dart';
import '../../../core/services/alarm_scheduler.dart';
import 'math_mission_view.dart';
import 'shake_mission_view.dart';
import 'typing_mission_view.dart';
import 'memory_mission_view.dart';
import 'step_mission_view.dart';

class MissionHostScreen extends ConsumerStatefulWidget {
  final int alarmId;
  final String label;

  const MissionHostScreen({
    super.key,
    required this.alarmId,
    required this.label,
  });

  @override
  ConsumerState<MissionHostScreen> createState() => _MissionHostScreenState();
}

class _MissionHostScreenState extends ConsumerState<MissionHostScreen> {
  Alarm? _alarm;
  bool _isLoading = true;
  bool _isMissionSolved = false;
  late DateTime _startTime;
  int _snoozes = 0;

  final List<String> _briefingQuotes = [
    "Wake up with determination, go to bed with satisfaction.",
    "Today is a new opportunity to build your future and conquer your goals.",
    "Discipline equals freedom. You beat the alarm today!",
    "Greatness is won in the quiet early hours while others sleep.",
    "Focus on your mission. Every morning is a fresh start."
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _loadAlarmData();
  }

  Future<void> _loadAlarmData() async {
    final isarService = ref.read(isarServiceProvider);
    final isar = await isarService.db;
    final alarm = await isar.alarms.get(widget.alarmId);
    if (mounted) {
      setState(() {
        _alarm = alarm;
        _isLoading = false;
      });
    }
  }

  Future<void> _onMissionComplete() async {
    setState(() {
      _isMissionSolved = true;
    });

    final isarService = ref.read(isarServiceProvider);
    final scheduler = ref.read(alarmSchedulerProvider);
    final elapsedSecs = DateTime.now().difference(_startTime).inSeconds;

    // Record History (Phase 6 Statistics)
    final history = AlarmHistory(
      alarmId: widget.alarmId,
      alarmLabel: widget.label,
      timestamp: DateTime.now(),
      missionType: _alarm?.missionType ?? 'math',
      dismissTimeSeconds: elapsedSecs,
      snoozeCount: _snoozes,
      verifiedAwake: true,
    );
    await isarService.recordHistory(history);

    // Turn off one-shot alarms
    if (_alarm != null && _alarm!.repeatDays.isEmpty) {
      await isarService.toggleAlarm(_alarm!.id, false);
    }

    // Phase 4 Wake-Up Verification Check-in
    if (_alarm != null && _alarm!.isVerificationRequired) {
      final verifyTime = DateTime.now().add(const Duration(minutes: 5));
      await scheduler.scheduleAlarm(
        id: 90000 + widget.alarmId,
        time: verifyTime,
        label: 'Verification Check! Are you awake?',
      );
    }

    // Wait 3.5 seconds showing Briefing/Quote before stopping audio and exiting
    await Future.delayed(const Duration(milliseconds: 3500));
    await scheduler.stopAlarmService();
    if (mounted) {
      SystemNavigator.pop();
    }
  }

  Future<void> _onSnooze() async {
    if (_alarm != null && _alarm!.isHardcoreMode) return; // Hardcore blocks snooze!

    final scheduler = ref.read(alarmSchedulerProvider);
    final snoozeMins = _alarm?.snoozeDurationMinutes ?? 5;
    if (snoozeMins <= 0) return;

    setState(() {
      _snoozes++;
    });

    final snoozeTime = DateTime.now().add(Duration(minutes: snoozeMins));
    await scheduler.scheduleAlarm(
      id: widget.alarmId,
      time: snoozeTime,
      label: '${widget.label} (Snoozed)',
    );

    await scheduler.stopAlarmService();
    if (mounted) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF12121A),
        body: Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
      );
    }

    if (_isMissionSolved) {
      final quote = _briefingQuotes[DateTime.now().second % _briefingQuotes.length];
      return Scaffold(
        backgroundColor: const Color(0xFF12121A),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 96, color: Colors.tealAccent),
                const SizedBox(height: 24),
                const Text(
                  'MISSION ACCOMPLISHED!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (_alarm?.isVerificationRequired == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade900.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Wake-up check-in scheduled in 5 minutes.',
                      style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 36),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    '"$quote"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final missionType = _alarm?.missionType ?? 'math';
    final difficulty = _alarm?.missionDifficulty ?? 'medium';
    final count = _alarm?.missionCount ?? 3;
    final isHardcore = _alarm?.isHardcoreMode ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header & Hardcore Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  if (isHardcore)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_fire_department, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'HARDCORE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 16),

              // Active Mission View
              Expanded(
                child: _buildMissionContent(missionType, difficulty, count),
              ),

              // Snooze Option (Hidden if Hardcore Mode or Snooze Off)
              if (!isHardcore && (_alarm?.snoozeDurationMinutes ?? 5) > 0) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _onSnooze,
                  icon: const Icon(Icons.snooze, color: Colors.white54),
                  label: Text(
                    'Snooze for ${_alarm?.snoozeDurationMinutes ?? 5} mins',
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionContent(String type, String difficulty, int count) {
    switch (type) {
      case 'shake':
        return ShakeMissionView(
          targetShakes: count * 10, // e.g. 3 count = 30 shakes
          onCompleted: _onMissionComplete,
        );
      case 'typing':
        return TypingMissionView(
          difficulty: difficulty,
          totalQuotes: count,
          onCompleted: _onMissionComplete,
        );
      case 'memory':
        return MemoryMissionView(
          difficulty: difficulty,
          totalRounds: count,
          onCompleted: _onMissionComplete,
        );
      case 'step':
        return StepMissionView(
          targetSteps: count * 10, // e.g. 2 count = 20 steps
          onCompleted: _onMissionComplete,
        );
      case 'math':
        return MathMissionView(
          difficulty: difficulty,
          totalProblems: count,
          onCompleted: _onMissionComplete,
        );
      case 'none':
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.alarm_on, size: 96, color: Colors.tealAccent),
              const SizedBox(height: 36),
              SizedBox(
                width: 240,
                height: 72,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
                  ),
                  onPressed: _onMissionComplete,
                  child: const Text(
                    'DISMISS ALARM',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
