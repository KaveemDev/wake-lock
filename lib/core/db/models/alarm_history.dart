import 'package:isar/isar.dart';

part 'alarm_history.g.dart';

@Collection()
class AlarmHistory {
  Id id = Isar.autoIncrement;

  late int alarmId;

  late String alarmLabel;

  late DateTime timestamp;

  late String missionType;

  late int dismissTimeSeconds;

  late int snoozeCount;

  late bool verifiedAwake;

  AlarmHistory({
    required this.alarmId,
    required this.alarmLabel,
    required this.timestamp,
    required this.missionType,
    this.dismissTimeSeconds = 30,
    this.snoozeCount = 0,
    this.verifiedAwake = true,
  });
}
