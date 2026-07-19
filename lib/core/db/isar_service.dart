import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/alarm.dart';
import 'models/alarm_history.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final alarmsStreamProvider = StreamProvider<List<Alarm>>((ref) async* {
  final service = ref.watch(isarServiceProvider);
  final isar = await service.db;
  yield* isar.alarms.where().watch(fireImmediately: true);
});

final alarmHistoryStreamProvider = StreamProvider<List<AlarmHistory>>((ref) async* {
  final service = ref.watch(isarServiceProvider);
  final isar = await service.db;
  yield* isar.alarmHistorys.where().sortByTimestampDesc().watch(fireImmediately: true);
});

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [AlarmSchema, AlarmHistorySchema],
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }

  Future<int> saveAlarm(Alarm alarm) async {
    final isar = await db;
    return await isar.writeTxn(() async {
      return await isar.alarms.put(alarm);
    });
  }

  Future<void> deleteAlarm(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.alarms.delete(id);
    });
  }

  Future<void> toggleAlarm(int id, bool enabled) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final alarm = await isar.alarms.get(id);
      if (alarm != null) {
        alarm.enabled = enabled;
        await isar.alarms.put(alarm);
      }
    });
  }

  Future<List<Alarm>> getAllAlarms() async {
    final isar = await db;
    return await isar.alarms.where().findAll();
  }

  Future<int> recordHistory(AlarmHistory history) async {
    final isar = await db;
    return await isar.writeTxn(() async {
      return await isar.alarmHistorys.put(history);
    });
  }

  Future<List<AlarmHistory>> getAllHistory() async {
    final isar = await db;
    return await isar.alarmHistorys.where().sortByTimestampDesc().findAll();
  }
}
