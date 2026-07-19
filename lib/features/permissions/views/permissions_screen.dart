import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/alarm_scheduler.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> with WidgetsBindingObserver {
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
      final exactAlarm = await ref.read(alarmSchedulerProvider).canScheduleExactAlarms();

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
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'WakeLock Permissions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.tealAccent))
          : SafeArea(
              child: RefreshIndicator(
                color: Colors.tealAccent,
                backgroundColor: const Color(0xFF181824),
                onRefresh: _checkAllPermissions,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.withOpacity(0.2),
                              const Color(0xFF181824),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.teal.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.security, color: Colors.tealAccent, size: 36),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Why Permissions Matter',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'To guarantee WakeLock rings loudly when your screen is locked or phone is asleep, all permissions below should be granted.',
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildPermissionCard(
                        title: 'Notification Permission',
                        description: 'Displays high-priority foreground alarms and verification countdowns on your lock screen.',
                        icon: Icons.notifications_active,
                        isGranted: _hasNotification,
                        onRequest: _requestNotification,
                      ),
                      const SizedBox(height: 16),

                      _buildPermissionCard(
                        title: 'Exact Alarms & Reminders',
                        description: 'Ensures alarms fire at the precise second without delay from Android Doze mode.',
                        icon: Icons.alarm_on,
                        isGranted: _hasExactAlarm,
                        onRequest: _requestExactAlarm,
                      ),
                      const SizedBox(height: 16),

                      _buildPermissionCard(
                        title: 'Display Over Other Apps',
                        description: 'Required to open the full-screen mission solver immediately when the alarm triggers over the lock screen.',
                        icon: Icons.layers,
                        isGranted: _hasSystemAlertWindow,
                        onRequest: _requestSystemAlertWindow,
                      ),
                      const SizedBox(height: 16),

                      _buildPermissionCard(
                        title: 'Ignore Battery Optimizations',
                        description: 'Prevents device manufacturers (ColorOS, MIUI, Samsung Doze) from killing the background wake service.',
                        icon: Icons.battery_charging_full,
                        isGranted: _hasBatteryExemption,
                        onRequest: _requestBatteryExemption,
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF252538),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.settings, size: 20, color: Colors.tealAccent),
                        label: const Text('OPEN SYSTEM APP SETTINGS', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          await openAppSettings();
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF181824),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isGranted ? Colors.tealAccent.withOpacity(0.4) : Colors.amberAccent.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isGranted ? Colors.tealAccent : Colors.amberAccent).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isGranted ? Colors.tealAccent : Colors.amberAccent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isGranted ? Colors.tealAccent : Colors.amberAccent).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isGranted ? 'GRANTED' : 'ACTION REQUIRED',
                        style: TextStyle(
                          color: isGranted ? Colors.tealAccent : Colors.amberAccent,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
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
            style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
          ),
          if (!isGranted) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onRequest,
                child: const Text('GRANT PERMISSION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
