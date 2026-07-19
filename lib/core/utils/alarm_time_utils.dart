class AlarmTimeUtils {
  static DateTime computeNextRingTime({
    required int hour,
    required int minute,
    required List<int> repeatDays,
    DateTime? from,
  }) {
    final now = from ?? DateTime.now();
    final baseToday = DateTime(now.year, now.month, now.day, hour, minute, 0);

    if (repeatDays.isEmpty) {
      if (baseToday.isAfter(now)) {
        return baseToday;
      } else {
        return baseToday.add(const Duration(days: 1));
      }
    }

    for (int dayOffset = 0; dayOffset <= 7; dayOffset++) {
      final candidate = baseToday.add(Duration(days: dayOffset));
      if (repeatDays.contains(candidate.weekday) && candidate.isAfter(now)) {
        return candidate;
      }
    }

    // Fallback in case of unexpected repeatDays values
    return baseToday.isAfter(now) ? baseToday : baseToday.add(const Duration(days: 1));
  }

  static String formatCountdown(DateTime target, [DateTime? from]) {
    final now = from ?? DateTime.now();
    final diff = target.difference(now);

    if (diff.isNegative || diff.inSeconds <= 0) {
      return 'Ringing soon...';
    }

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (hours == 0 && minutes == 0) {
      return 'Ring in less than 1 min';
    } else if (hours == 0) {
      return 'Ring in $minutes ${minutes == 1 ? "min" : "mins"}';
    } else if (minutes == 0) {
      return 'Ring in $hours ${hours == 1 ? "hour" : "hours"}';
    } else {
      return 'Ring in $hours ${hours == 1 ? "hour" : "hours"} $minutes ${minutes == 1 ? "min" : "mins"}';
    }
  }

  static String formatRepeatDays(List<int> repeatDays) {
    if (repeatDays.isEmpty) {
      return 'One-shot';
    }
    if (repeatDays.length == 7) {
      return 'Every day';
    }
    final sorted = List<int>.from(repeatDays)..sort();
    if (sorted.length == 5 &&
        sorted[0] == 1 &&
        sorted[1] == 2 &&
        sorted[2] == 3 &&
        sorted[3] == 4 &&
        sorted[4] == 5) {
      return 'Weekdays (Mon-Fri)';
    }
    if (sorted.length == 2 && sorted[0] == 6 && sorted[1] == 7) {
      return 'Weekends (Sat-Sun)';
    }

    const dayNames = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };

    return sorted.map((d) => dayNames[d] ?? '').where((s) => s.isNotEmpty).join(', ');
  }

  static String formatTime(DateTime time) {
    final hourStr = time.hour.toString().padLeft(2, '0');
    final minuteStr = time.minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }
}
