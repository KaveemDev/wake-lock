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

  late String missionType; // 'math', 'shake', 'typing', 'memory', 'step', 'none'

  late String missionDifficulty; // 'easy', 'medium', 'hard'

  late int missionCount; // number of problems, shakes, or sequence repeats

  late bool isHardcoreMode; // prevents lowering volume & locks snooze

  late bool isVerificationRequired; // asks for confirmation 5 min after dismiss

  Alarm({
    required this.time,
    this.label = 'Alarm',
    this.repeatDays = const [],
    this.enabled = true,
    this.vibrate = true,
    this.snoozeDurationMinutes = 5,
    this.soundName = 'Default System Alarm',
    this.missionType = 'math',
    this.missionDifficulty = 'medium',
    this.missionCount = 3,
    this.isHardcoreMode = false,
    this.isVerificationRequired = true,
  });
}
