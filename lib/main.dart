import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/db/isar_service.dart';
import 'core/services/alarm_scheduler.dart';
import 'core/services/permissions_service.dart';
import 'features/alarms/views/alarm_list_screen.dart';
import 'features/missions/views/mission_host_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PermissionsService.requestBasePermissions();
  runApp(const ProviderScope(child: FocusAlarmApp()));
}

class FocusAlarmApp extends StatelessWidget {
  const FocusAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Alarm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF12121A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.tealAccent,
          brightness: Brightness.dark,
        ),
      ),
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/ringing')) {
          final uri = Uri.parse(settings.name!);
          final id = int.tryParse(uri.queryParameters['id'] ?? '0') ?? 0;
          final label = uri.queryParameters['label'] ?? 'Wake Up!';
          return MaterialPageRoute(
            builder: (_) => MissionHostScreen(alarmId: id, label: label),
          );
        }
        return null;
      },
      home: const AlarmListScreen(),
    );
  }
}

class Phase1RingingScreen extends ConsumerWidget {
  final int id;
  final String label;

  const Phase1RingingScreen({
    super.key,
    required this.id,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.alarm_on,
                  size: 96,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'WAKE UP!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red.shade900,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    onPressed: () async {
                      await ref.read(alarmSchedulerProvider).stopAlarmService();
                      await ref.read(isarServiceProvider).toggleAlarm(id, false);
                      if (context.mounted) {
                        SystemNavigator.pop();
                      }
                    },
                    child: const Text(
                      'STOP ALARM',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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
}
