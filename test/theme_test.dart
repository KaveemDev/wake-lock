import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_alarm/core/ui/app_theme.dart';
import 'package:focus_alarm/core/ui/app_ui.dart';
import 'package:focus_alarm/features/settings/views/theme_screen.dart';

void main() {
  test('AppColors follow light/dark and accent', () {
    AppColors.apply(dark: true, accent: 1);
    expect(AppColors.accent, accentOptions[1].dark);
    AppColors.apply(dark: false, accent: 1);
    expect(AppColors.accent, accentOptions[1].light);
    expect(AppColors.bg, isNot(AppColors.text));
  });

  testWidgets('Theme screen changes mode and accent', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ThemeScreen()));
    await tester.tap(find.text('Light'));
    await tester.pump();
    expect(ThemeController.instance.value.mode, AppThemeMode.light);
    await tester.tap(find.text('Green'));
    await tester.pump();
    expect(ThemeController.instance.value.accent, 2);
  });
}
