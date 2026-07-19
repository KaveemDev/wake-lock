import 'package:isar/isar.dart';

part 'alarm.g.dart';

@Collection()
class Alarm {
  Id id = Isar.autoIncrement;

  late DateTime time;

  late String label;

  late List<int> repeatDays; // 1 = Monday, 2 = Tuesday, ..., 7 = Sunday

  late bool enabled;

  late bool vibrate;

  late int snoozeDurationMinutes;

  late String soundName;

  Alarm({
    required this.time,
    this.label = 'Alarm',
    this.repeatDays = const [],
    this.enabled = true,
    this.vibrate = true,
    this.snoozeDurationMinutes = 5,
    this.soundName = 'Default System Alarm',
  });
}
