import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/db/models/alarm.dart';
import '../../../core/db/models/alarm_history.dart';
import '../../../core/services/alarm_scheduler.dart';
import '../../../core/ui/app_ui.dart';
import '../../../core/utils/alarm_time_utils.dart';
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
  bool _hasStartedMission = false;
  bool _isVerificationCheck = false;
  bool _isVerificationConfirmed = false;
  int _verificationSecondsRemaining = 60;
  Timer? _verificationTimer;
  Timer? _idleTimer;
  int _secondsRemaining = 60;
  late DateTime _startTime;
  int _snoozes = 0;

  final List<String> _briefingQuotes = [
    "Wake up with determination, go to bed with satisfaction.",
    "Today is a new opportunity to build your future and conquer your goals.",
    "Discipline equals freedom. You beat the alarm today!",
    "Greatness is won in the quiet early hours while others sleep.",
    "Focus on your mission. Every morning is a fresh start.",
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _loadAlarmData();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _verificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAlarmData() async {
    final isarService = ref.read(isarServiceProvider);
    final isar = await isarService.db;
    final isVerify = widget.alarmId >= 90000;
    final realId = isVerify ? widget.alarmId - 90000 : widget.alarmId;
    final alarm = await isar.alarms.get(realId);
    if (mounted) {
      setState(() {
        _alarm = alarm;
        _isLoading = false;
        _isVerificationCheck = isVerify;
      });
      if (isVerify) {
        _startVerificationTimer();
      }
    }
  }

  void _startVerificationTimer() {
    _verificationTimer?.cancel();
    _verificationSecondsRemaining = 60;
    _verificationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_verificationSecondsRemaining <= 1) {
        _verificationTimer?.cancel();
        _onVerificationFailedEscalate();
      } else {
        setState(() {
          _verificationSecondsRemaining--;
        });
      }
    });
  }

  Future<void> _onVerificationConfirm() async {
    _verificationTimer?.cancel();
    setState(() {
      _isVerificationConfirmed = true;
    });

    final isarService = ref.read(isarServiceProvider);
    final scheduler = ref.read(alarmSchedulerProvider);
    final realId = widget.alarmId >= 90000
        ? widget.alarmId - 90000
        : widget.alarmId;

    final history = AlarmHistory(
      alarmId: realId,
      alarmLabel: widget.label,
      timestamp: DateTime.now(),
      missionType: 'wake_up_verification',
      dismissTimeSeconds: 60 - _verificationSecondsRemaining,
      snoozeCount: 0,
      verifiedAwake: true,
    );
    await isarService.recordHistory(history);

    await Future.delayed(const Duration(milliseconds: 2500));
    await scheduler.stopAlarmService();
    if (mounted) {
      SystemNavigator.pop();
    }
  }

  Future<void> _onVerificationFailedEscalate() async {
    if (!mounted) return;
    setState(() {
      _isVerificationCheck = false;
    });
    try {
      await const MethodChannel(
        'com.focusalarm.app/ringing',
      ).invokeMethod('resumeRing');
    } catch (e) {
      debugPrint('Failed to resume ring on verification escalation: $e');
    }
  }

  Future<void> _startMissionFlow() async {
    setState(() {
      _hasStartedMission = true;
      _secondsRemaining = 60;
    });
    try {
      await const MethodChannel(
        'com.focusalarm.app/ringing',
      ).invokeMethod('pauseRing');
    } catch (e) {
      debugPrint('Failed to pause ring: $e');
    }
    _idleTimer?.cancel();
    _idleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        _idleTimer?.cancel();
        _onIdleTimeout();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _resetIdleTimer() {
    if (_hasStartedMission && mounted) {
      setState(() {
        _secondsRemaining = 60;
      });
    }
  }

  Future<void> _onIdleTimeout() async {
    if (!mounted) return;
    setState(() {
      _hasStartedMission = false;
    });
    try {
      await const MethodChannel(
        'com.focusalarm.app/ringing',
      ).invokeMethod('resumeRing');
    } catch (e) {
      debugPrint('Failed to resume ring: $e');
    }
  }

  Future<void> _onMissionComplete() async {
    _idleTimer?.cancel();
    _verificationTimer?.cancel();
    setState(() {
      _isMissionSolved = true;
    });

    final isarService = ref.read(isarServiceProvider);
    final scheduler = ref.read(alarmSchedulerProvider);
    final elapsedSecs = DateTime.now().difference(_startTime).inSeconds;
    final realId = widget.alarmId >= 90000
        ? widget.alarmId - 90000
        : widget.alarmId;

    // Record History (Phase 6 Statistics)
    final history = AlarmHistory(
      alarmId: realId,
      alarmLabel: widget.label,
      timestamp: DateTime.now(),
      missionType: _alarm?.missionType ?? 'math',
      dismissTimeSeconds: elapsedSecs,
      snoozeCount: _snoozes,
      verifiedAwake: true,
    );
    await isarService.recordHistory(history);

    // Turn off one-shot alarms, or reschedule repeating alarms for next occurrence
    if (_alarm != null) {
      if (_alarm!.repeatDays.isEmpty) {
        await isarService.toggleAlarm(realId, false);
      } else {
        final nextRingTime = AlarmTimeUtils.computeNextRingTime(
          hour: _alarm!.time.hour,
          minute: _alarm!.time.minute,
          repeatDays: _alarm!.repeatDays,
        );
        _alarm!.time = nextRingTime;
        await isarService.saveAlarm(_alarm!);
        await scheduler.scheduleAlarm(
          id: realId,
          time: nextRingTime,
          label: _alarm!.label,
          soundPath: _alarm!.soundPath,
        );
      }
    }

    // Phase 4 Wake-Up Verification Check-in (Schedule ONLY if completing primary alarm)
    if (widget.alarmId < 90000 &&
        _alarm != null &&
        _alarm!.isVerificationRequired) {
      final verifyMins = _alarm!.verificationDurationMinutes;
      final verifyTime = DateTime.now().add(Duration(minutes: verifyMins));
      await scheduler.scheduleAlarm(
        id: 90000 + realId,
        time: verifyTime,
        label: 'Still up?',
        soundPath: _alarm!.soundPath,
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
    _idleTimer?.cancel();
    _verificationTimer?.cancel();
    if (_alarm != null && _alarm!.isHardcoreMode) {
      return; // Hardcore blocks snooze!
    }

    final scheduler = ref.read(alarmSchedulerProvider);
    final snoozeMins = _alarm?.snoozeDurationMinutes ?? 5;
    if (snoozeMins <= 0) return;

    setState(() {
      _snoozes++;
    });

    final realId = widget.alarmId >= 90000
        ? widget.alarmId - 90000
        : widget.alarmId;
    final snoozeTime = DateTime.now().add(Duration(minutes: snoozeMins));
    await scheduler.scheduleAlarm(
      id: realId,
      time: snoozeTime,
      label: '${widget.label} (Snoozed)',
      soundPath: _alarm!.soundPath,
    );

    await scheduler.stopAlarmService();
    if (mounted) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    // Handle Wake-Up Verification Screen when alarmId >= 90000
    if (_isVerificationCheck) {
      if (_isVerificationConfirmed) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PopIn(
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 110,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'You\'re up',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Thanks. You\'re all set.',
                      style: TextStyle(color: AppColors.success, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PulseGlow(
                    color: AppColors.accent,
                    radius: 36,
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.verified_user_rounded,
                        size: 80,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Check-in',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                      letterSpacing: 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Still up?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                      letterSpacing: 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: AppColors.warn,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_verificationSecondsRemaining}s left',
                          style: TextStyle(
                            color: AppColors.warn,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 72,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.onAccent,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36),
                        ),
                      ),
                      onPressed: _onVerificationConfirm,
                      child: const Text(
                        "YES, I'M AWAKE!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tap below within 60 seconds, or the alarm and your mission start again.',
                    style: TextStyle(color: AppColors.textDim, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_isMissionSolved) {
      final quote =
          _briefingQuotes[DateTime.now().second % _briefingQuotes.length];
      final verifyMins = _alarm?.verificationDurationMinutes ?? 5;
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PopIn(
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 110,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Alarm off',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                      letterSpacing: 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (_alarm?.isVerificationRequired == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user,
                            color: AppColors.success,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'We\'ll check you\'re still up in $verifyMins ${verifyMins == 1 ? "minute" : "minutes"}.',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '"$quote"',
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: AppColors.text,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final missionType = _alarm?.missionType ?? 'math';
    final difficulty = _alarm?.missionDifficulty ?? 'medium';
    final count = _alarm?.missionCount ?? 3;
    final isHardcore = _alarm?.isHardcoreMode ?? false;

    if (!_hasStartedMission) {
      final missionName = missionType == 'shake'
          ? 'Shake'
          : missionType == 'typing'
          ? 'Typing'
          : missionType == 'memory'
          ? 'Memory'
          : missionType == 'step'
          ? 'Steps'
          : missionType == 'none'
          ? 'Tap to stop'
          : 'Math';

      return Scaffold(
        backgroundColor: const Color(0xFF2A0610),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const RingingBell(),
                  const SizedBox(height: 20),
                  Text(
                    'Alarm',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                      letterSpacing: 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDim,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          color: AppColors.warn,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '$missionName · $difficulty',
                            style: TextStyle(
                              color: AppColors.warn,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  GradientButton(
                    label: 'Start',
                    icon: Icons.bolt_rounded,
                    height: 72,
                    colors: [AppColors.text, Color(0xFFFFD6DD)],
                    textColor: const Color(0xFF8A0F25),
                    onPressed: _startMissionFlow,
                  ),
                  const SizedBox(height: 24),
                  if (!isHardcore && (_alarm?.snoozeDurationMinutes ?? 5) > 0)
                    TextButton.icon(
                      onPressed: _onSnooze,
                      icon: Icon(Icons.snooze, color: AppColors.textDim),
                      label: Text(
                        'Snooze ${_alarm?.snoozeDurationMinutes ?? 5} min',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Listener(
      onPointerDown: (_) => _resetIdleTimer(),
      onPointerMove: (_) => _resetIdleTimer(),
      onPointerUp: (_) => _resetIdleTimer(),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Idle Timer Banner at Top
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _secondsRemaining <= 15
                        ? AppColors.danger.withValues(alpha: 0.2)
                        : AppColors.warn.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _secondsRemaining <= 15
                          ? AppColors.danger
                          : AppColors.warn,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer,
                        color: _secondsRemaining <= 15
                            ? AppColors.danger
                            : AppColors.warn,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rings again in ${_secondsRemaining}s',
                        style: TextStyle(
                          color: _secondsRemaining <= 15
                              ? AppColors.danger
                              : AppColors.warn,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Header & Hardcore Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                          letterSpacing: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isHardcore)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 16,
                              color: AppColors.text,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Hardcore',
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: AppColors.border),
                const SizedBox(height: 12),

                // Active Mission View
                Expanded(
                  child: _buildMissionContent(missionType, difficulty, count),
                ),

                // Snooze Option (Hidden if Hardcore Mode or Snooze Off)
                if (!isHardcore &&
                    (_alarm?.snoozeDurationMinutes ?? 5) > 0) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _onSnooze,
                    icon: Icon(Icons.snooze, color: AppColors.textDim),
                    label: Text(
                      'Snooze ${_alarm?.snoozeDurationMinutes ?? 5} min',
                      style: TextStyle(
                        color: AppColors.textDim,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMissionContent(String type, String difficulty, int count) {
    switch (type) {
      case 'shake':
        final target = count >= 10 ? count : count * 10;
        return ShakeMissionView(
          targetShakes: target,
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
        final targetSteps = count >= 10 ? count : count * 10;
        return StepMissionView(
          targetSteps: targetSteps,
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
              Icon(Icons.alarm_on, size: 96, color: AppColors.accent),
              const SizedBox(height: 36),
              SizedBox(
                width: 240,
                height: 72,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.onAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                  onPressed: _onMissionComplete,
                  child: const Text(
                    'Stop alarm',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

/// Bell that wobbles in bursts with a red glow, signalling the alarm is ringing.
class RingingBell extends StatefulWidget {
  const RingingBell({super.key});

  @override
  State<RingingBell> createState() => _RingingBellState();
}

class _RingingBellState extends State<RingingBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PulseGlow(
      color: AppColors.danger,
      radius: 44,
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: const BoxDecoration(
          color: Color(0xFF3F0A18),
          shape: BoxShape.circle,
        ),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, child) {
            final v = _c.value;
            final angle = v < 0.55
                ? math.sin(v / 0.55 * math.pi * 7) * 0.35 * (1 - v / 0.55)
                : 0.0;
            return Transform.rotate(
              angle: angle,
              alignment: Alignment.topCenter,
              child: child,
            );
          },
          child: Icon(
            Icons.notifications_active_rounded,
            size: 84,
            color: AppColors.text,
          ),
        ),
      ),
    );
  }
}
