import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/alarm_scheduler.dart';
import '../../../core/ui/app_theme.dart';
import '../../../core/ui/app_ui.dart';
import '../../settings/views/theme_screen.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _hasNotification = false;
  bool _hasExactAlarm = false;
  bool _hasSystemAlertWindow = false;
  bool _hasBatteryExemption = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAllPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAllPermissions();
    }
  }

  Future<void> _checkAllPermissions() async {
    setState(() => _isLoading = true);
    try {
      final notifStatus = await Permission.notification.status;
      final alertStatus = await Permission.systemAlertWindow.status;
      final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
      final exactAlarm = await ref
          .read(alarmSchedulerProvider)
          .canScheduleExactAlarms();

      if (mounted) {
        setState(() {
          _hasNotification = notifStatus.isGranted;
          _hasSystemAlertWindow = alertStatus.isGranted;
          _hasBatteryExemption = batteryStatus.isGranted;
          _hasExactAlarm = exactAlarm;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _requestNotification() async {
    await Permission.notification.request();
    await _checkAllPermissions();
  }

  Future<void> _requestExactAlarm() async {
    // If not granted, open settings as exact alarm often requires redirecting on Android 12/13/14
    if (!_hasExactAlarm) {
      await openAppSettings();
    }
    await _checkAllPermissions();
  }

  Future<void> _requestSystemAlertWindow() async {
    final status = await Permission.systemAlertWindow.request();
    if (!status.isGranted) {
      await openAppSettings();
    }
    await _checkAllPermissions();
  }

  Future<void> _requestBatteryExemption() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    if (!status.isGranted) {
      await openAppSettings();
    }
    await _checkAllPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        'Notifications',
        'Shows the alarm on your lock screen.',
        Icons.notifications_active_rounded,
        _hasNotification,
        _requestNotification,
      ),
      (
        'Exact alarms',
        'Rings on the minute, even when the phone is idle.',
        Icons.alarm_on_rounded,
        _hasExactAlarm,
        _requestExactAlarm,
      ),
      (
        'Show over other apps',
        'Opens the mission screen as soon as the alarm goes off.',
        Icons.layers_rounded,
        _hasSystemAlertWindow,
        _requestSystemAlertWindow,
      ),
      (
        'Battery',
        'Stops the phone from closing WakeLock in the background.',
        Icons.battery_charging_full_rounded,
        _hasBatteryExemption,
        _requestBatteryExemption,
      ),
    ];
    final grantedCount = cards.where((c) => c.$4).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Permissions',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: GlowBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: RefreshIndicator(
                  color: AppColors.accent,
                  backgroundColor: AppColors.surface,
                  onRefresh: _checkAllPermissions,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FadeSlideIn(
                          child: AppCard(
                            padding: const EdgeInsets.all(22),
                            borderColor: AppColors.accent.withValues(
                              alpha: 0.28,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accent.withValues(alpha: 0.2),
                                AppColors.accent2.withValues(alpha: 0.1),
                                AppColors.surface,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(
                                      begin: 0,
                                      end: grantedCount / cards.length,
                                    ),
                                    duration: const Duration(milliseconds: 900),
                                    curve: Curves.easeOutCubic,
                                    builder: (_, v, _) => Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox.expand(
                                          child: CircularProgressIndicator(
                                            value: v,
                                            strokeWidth: 5,
                                            strokeCap: StrokeCap.round,
                                            backgroundColor: AppColors.border,
                                            color: v == 1
                                                ? AppColors.accent
                                                : AppColors.warn,
                                          ),
                                        ),
                                        Text(
                                          '$grantedCount/${cards.length}',
                                          style: TextStyle(
                                            color: AppColors.text,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        grantedCount == cards.length
                                            ? 'All set. Alarms will ring.'
                                            : 'Why these matter',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.text,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Allow these so alarms still ring when your phone is locked.',
                                        style: TextStyle(
                                          color: AppColors.textDim,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        for (var i = 0; i < cards.length; i++)
                          FadeSlideIn(
                            delay: FadeSlideIn.stagger(i + 1),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _buildPermissionCard(
                                title: cards[i].$1,
                                description: cards[i].$2,
                                icon: cards[i].$3,
                                isGranted: cards[i].$4,
                                onRequest: cards[i].$5,
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        FadeSlideIn(
                          delay: FadeSlideIn.stagger(5),
                          child: AppCard(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ThemeScreen(),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Theme',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: ThemeController.instance,
                                  builder: (_, t, _) => Text(
                                    '${themeModeLabel(t.mode)} · ${accentOptions[t.accent].name}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textDim,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textDim,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeSlideIn(
                          delay: FadeSlideIn.stagger(6),
                          child: Pressable(
                            onTap: () async => await openAppSettings(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHi,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.settings_rounded,
                                    size: 20,
                                    color: AppColors.accent,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Open app settings',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isGranted,
    required VoidCallback onRequest,
  }) {
    final color = isGranted ? AppColors.success : AppColors.warn;
    return AppCard(
      borderColor: color.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Tag(
                        isGranted ? 'Allowed' : 'Needed',
                        key: ValueKey(isGranted),
                        color: color,
                        icon: isGranted
                            ? Icons.check_circle_rounded
                            : Icons.error_outline_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: AppColors.textDim,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: isGranted
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: GradientButton(
                      label: 'Allow',
                      height: 46,
                      colors: AppColors.sunrise,
                      onPressed: onRequest,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
