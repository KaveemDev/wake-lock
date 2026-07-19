import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/db/models/alarm.dart';
import '../../../core/services/alarm_scheduler.dart';
import '../../../core/utils/alarm_time_utils.dart';

class AlarmsController {
  final IsarService _isarService;
  final AlarmSchedulerService _schedulerService;

  AlarmsController(this._isarService, this._schedulerService);

  Future<int> saveOrUpdateAlarm({
    int? existingId,
    required int hour,
    required int minute,
    required String label,
    required List<int> repeatDays,
    required bool vibrate,
    required int snoozeDurationMinutes,
    required String soundName,
  }) async {
    final nextRingTime = AlarmTimeUtils.computeNextRingTime(
      hour: hour,
      minute: minute,
      repeatDays: repeatDays,
    );

    final alarm = Alarm(
      time: nextRingTime,
      label: label.trim().isEmpty ? 'Alarm' : label.trim(),
      repeatDays: repeatDays,
      enabled: true,
      vibrate: vibrate,
      snoozeDurationMinutes: snoozeDurationMinutes,
      soundName: soundName,
    );

    if (existingId != null && existingId != 0) {
      alarm.id = existingId;
    }

    final id = await _isarService.saveAlarm(alarm);

    await _schedulerService.scheduleAlarm(
      id: id,
      time: nextRingTime,
      label: alarm.label,
    );

    return id;
  }

  Future<void> toggleAlarm(Alarm alarm, bool enabled) async {
    if (enabled) {
      final nextRingTime = AlarmTimeUtils.computeNextRingTime(
        hour: alarm.time.hour,
        minute: alarm.time.minute,
        repeatDays: alarm.repeatDays,
      );
      alarm.time = nextRingTime;
      alarm.enabled = true;
      await _isarService.saveAlarm(alarm);
      await _schedulerService.scheduleAlarm(
        id: alarm.id,
        time: nextRingTime,
        label: alarm.label,
      );
    } else {
      alarm.enabled = false;
      await _isarService.saveAlarm(alarm);
      await _schedulerService.cancelAlarm(alarm.id);
    }
  }

  Future<void> deleteAlarm(Alarm alarm) async {
    await _schedulerService.cancelAlarm(alarm.id);
    await _isarService.deleteAlarm(alarm.id);
  }
}

final alarmsControllerProvider = Provider<AlarmsController>((ref) {
  final isar = ref.watch(isarServiceProvider);
  final scheduler = ref.watch(alarmSchedulerProvider);
  return AlarmsController(isar, scheduler);
});
