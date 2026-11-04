import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/ui/app_ui.dart';
import '../../../core/utils/alarm_time_utils.dart';
import '../../missions/models/mission.dart';
import '../providers/alarms_provider.dart';
import 'alarm_edit_screen.dart';

class AlarmListScreen extends ConsumerStatefulWidget {
  const AlarmListScreen({super.key});

  @override
  ConsumerState<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends ConsumerState<AlarmListScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Keeps the "Ring in ..." countdown fresh.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alarmsAsync = ref.watch(alarmsStreamProvider);

    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: alarmsAsync.when(
                  data: _buildBody,
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) =>
                      Center(child: Text('Error loading alarms: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FadeSlideIn(
        delay: const Duration(milliseconds: 500),
        offset: const Offset(0, 40),
        child: Pressable(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AlarmEditScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: AppColors.onAccent),
                SizedBox(width: 6),
                Text(
                  'New alarm',
                  style: TextStyle(
                    color: AppColors.onAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Alarms',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: AppColors.text,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List alarms) {
    final active = alarms.where((a) => a.enabled).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    final next = active.isNotEmpty ? active.first : null;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      itemCount: alarms.isEmpty ? 2 : alarms.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildHero(next);
        if (alarms.isEmpty) return _buildEmpty();
        final alarm = alarms[index - 1];
        return FadeSlideIn(
          delay: FadeSlideIn.stagger(index),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildAlarmCard(context, alarm),
          ),
        );
      },
    );
  }

  Widget _buildHero(dynamic next) {
    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: AppCard(
          padding: const EdgeInsets.all(22),
          borderColor: AppColors.accent.withValues(alpha: 0.28),
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withValues(alpha: 0.22),
              AppColors.accent2.withValues(alpha: 0.12),
              AppColors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shadows: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.10),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          child: Row(
            children: [
              PulseGlow(
                color: next != null ? AppColors.accent : AppColors.textFaint,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bg.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    next != null
                        ? Icons.alarm_on_rounded
                        : Icons.alarm_off_rounded,
                    color: next != null ? AppColors.accent : AppColors.textDim,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (c, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.25),
                        end: Offset.zero,
                      ).animate(a),
                      child: c,
                    ),
                  ),
                  child: Column(
                    key: ValueKey(
                      next == null
                          ? 'none'
                          : '${next.id}${AlarmTimeUtils.formatCountdown(next.time)}',
                    ),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        next != null
                            ? AlarmTimeUtils.formatCountdown(next.time)
                            : 'All alarms are off',
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        next != null
                            ? '${next.label} · ${AlarmTimeUtils.formatTime(next.time)}'
                            : 'Tap New alarm to add one',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return FadeSlideIn(
      delay: const Duration(milliseconds: 150),
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  Icons.alarm_add_rounded,
                  size: 56,
                  color: AppColors.accent.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No alarms yet',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap New alarm to set your first one',
              style: TextStyle(color: AppColors.textDim, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmCard(BuildContext context, dynamic alarm) {
    final on = alarm.enabled as bool;
    final missionCfg = MissionConfig(
      type: alarm.missionType,
      difficulty: alarm.missionDifficulty,
      count: alarm.missionCount,
    );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
      borderColor: on ? AppColors.accent.withValues(alpha: 0.32) : null,
      shadows: on
          ? [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.07),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ]
          : null,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AlarmEditScreen(existingAlarm: alarm),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: on ? 1 : 0.45,
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
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                            letterSpacing: -1,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          AlarmTimeUtils.formatRepeatDays(alarm.repeatDays),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alarm.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Tag(
                        missionCfg.displayName,
                        color: AppColors.accent2,
                        icon: Icons.bolt_rounded,
                      ),
                      if (alarm.isHardcoreMode)
                        Tag(
                          'Hardcore',
                          color: AppColors.danger,
                          icon: Icons.local_fire_department_rounded,
                        ),
                      if (alarm.isVerificationRequired)
                        Tag(
                          'Check-in',
                          color: AppColors.accent,
                          icon: Icons.verified_user_rounded,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Switch(
            value: on,
            onChanged: (val) =>
                ref.read(alarmsControllerProvider).toggleAlarm(alarm, val),
          ),
        ],
      ),
    );
  }
}
