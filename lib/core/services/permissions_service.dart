import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static Future<bool> requestBasePermissions() async {
    if (kIsWeb || !Platform.isAndroid) return true;

    // Check base permissions required for alarms and notifications
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
      Permission.scheduleExactAlarm,
      Permission.ignoreBatteryOptimizations,
      Permission.systemAlertWindow,
    ].request();

    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        debugPrint('Permission not granted: $permission -> $status');
        allGranted = false;
      }
    });

    return allGranted;
  }
}
