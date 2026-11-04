import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/db/isar_service.dart';
import 'core/services/alarm_scheduler.dart';
import 'core/services/permissions_service.dart';
import 'core/ui/app_theme.dart';
import 'core/ui/app_ui.dart';
import 'core/ui/home_shell.dart';
import 'features/missions/views/mission_host_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PermissionsService.requestBasePermissions();
  await ThemeController.instance.load();
  runApp(const ProviderScope(child: FocusAlarmApp()));
}

class FocusAlarmApp extends StatefulWidget {
  const FocusAlarmApp({super.key});

  @override
  State<FocusAlarmApp> createState() => _FocusAlarmAppState();
}

class _FocusAlarmAppState extends State<FocusAlarmApp>
    with WidgetsBindingObserver {
  final _theme = ThemeController.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _theme.addListener(_restyle);
  }

  @override
  void dispose() {
    _theme.removeListener(_restyle);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() => _restyle();

  /// AppColors are read straight from widgets (many of them const), so a theme
  /// change marks every element dirty instead of remounting and losing state.
  void _restyle() {
    setState(() {});
    void mark(Element e) {
      e.markNeedsBuild();
      e.visitChildren(mark);
    }

    (context as Element).visitChildren(mark);
  }

  @override
  Widget build(BuildContext context) {
    final t = _theme.value;
    AppColors.apply(
      dark: switch (t.mode) {
        AppThemeMode.dark => true,
        AppThemeMode.light => false,
        AppThemeMode.system =>
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark,
      },
      accent: t.accent,
    );
    return MaterialApp(
      title: 'WakeLock',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
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
      home: const HomeShell(),
    );
  }
}

class Phase1RingingScreen extends ConsumerWidget {
  final int id;
  final String label;

  const Phase1RingingScreen({super.key, required this.id, required this.label});

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
                const Icon(Icons.alarm_on, size: 96, color: Colors.white),
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
                  style: const TextStyle(fontSize: 24, color: Colors.white70),
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
                      await ref
                          .read(isarServiceProvider)
                          .toggleAlarm(id, false);
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
