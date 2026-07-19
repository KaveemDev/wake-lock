import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmSchedulerService {
  static const MethodChannel _channel = MethodChannel('com.focusalarm.app/scheduler');
  static const MethodChannel _ringingChannel = MethodChannel('com.focusalarm.app/ringing');

  Future<bool> scheduleAlarm({
    required int id,
    required DateTime time,
    required String label,
    String? soundPath,
  }) async {
    try {
      final success = await _channel.invokeMethod<bool>('scheduleAlarm', {
        'id': id,
        'timestampMillis': time.millisecondsSinceEpoch,
        'label': label,
        'soundPath': soundPath ?? '',
      });
      return success ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelAlarm(int id) async {
    try {
      final success = await _channel.invokeMethod<bool>('cancelAlarm', {
        'id': id,
      });
      return success ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> canScheduleExactAlarms() async {
    try {
      final canSchedule = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
      return canSchedule ?? true;
    } catch (e) {
      return true;
    }
  }

  Future<bool> stopAlarmService() async {
    try {
      final success = await _ringingChannel.invokeMethod<bool>('stopAlarm');
      return success ?? false;
    } catch (e) {
      return false;
    }
  }
}

final alarmSchedulerProvider = Provider<AlarmSchedulerService>((ref) {
  return AlarmSchedulerService();
});
