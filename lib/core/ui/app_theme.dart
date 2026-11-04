import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

enum AppThemeMode { system, light, dark }

/// Each accent has a bright shade for dark mode and a deeper one for light mode,
/// so text on it and next to it stays readable in both.
class AccentOption {
  final String name;
  final Color dark;
  final Color light;
  const AccentOption(this.name, this.dark, this.light);
}

const accentOptions = [
  AccentOption('Amber', Color(0xFFF5A524), Color(0xFFB45309)),
  AccentOption('Blue', Color(0xFF60A5FA), Color(0xFF1D4ED8)),
  AccentOption('Green', Color(0xFF34D399), Color(0xFF047857)),
  AccentOption('Rose', Color(0xFFFB7185), Color(0xFFBE123C)),
];

class ThemeSettings {
  final AppThemeMode mode;
  final int accent;
  const ThemeSettings(this.mode, this.accent);

  ThemeSettings copyWith({AppThemeMode? mode, int? accent}) =>
      ThemeSettings(mode ?? this.mode, accent ?? this.accent);
}

/// The user's theme choice, saved to a small JSON file in the app's documents folder.
class ThemeController extends ValueNotifier<ThemeSettings> {
  ThemeController._() : super(const ThemeSettings(AppThemeMode.system, 0));
  static final instance = ThemeController._();

  Future<File> _file() async =>
      File('${(await getApplicationDocumentsDirectory()).path}/theme.json');

  Future<void> load() async {
    try {
      final j = jsonDecode(await (await _file()).readAsString()) as Map;
      value = ThemeSettings(
        AppThemeMode.values.byName(j['mode'] as String),
        (j['accent'] as int).clamp(0, accentOptions.length - 1),
      );
    } catch (_) {
      // No saved choice yet (or unreadable): keep the default.
    }
  }

  Future<void> update(ThemeSettings s) async {
    value = s;
    try {
      await (await _file()).writeAsString(
        jsonEncode({'mode': s.mode.name, 'accent': s.accent}),
      );
    } catch (_) {
      // Saving failed: the choice still applies until the app restarts.
    }
  }
}
