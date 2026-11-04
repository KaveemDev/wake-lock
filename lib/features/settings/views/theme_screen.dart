import 'package:flutter/material.dart';
import '../../../core/ui/app_theme.dart';
import '../../../core/ui/app_ui.dart';

String themeModeLabel(AppThemeMode m) => switch (m) {
  AppThemeMode.system => 'System',
  AppThemeMode.light => 'Light',
  AppThemeMode.dark => 'Dark',
};

/// Pick light/dark/system and an accent. Changes apply and save at once.
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ThemeController.instance;
    return ValueListenableBuilder(
      valueListenable: ctrl,
      builder: (context, t, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Theme',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          iconTheme: IconThemeData(color: AppColors.text),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const SectionLabel('Mode'),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  for (final m in AppThemeMode.values)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: t.mode == m,
                        child: Pressable(
                          onTap: () => ctrl.update(t.copyWith(mode: m)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: t.mode == m
                                  ? AppColors.surfaceHi
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              themeModeLabel(m),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: t.mode == m
                                    ? AppColors.text
                                    : AppColors.textDim,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 28),
              child: Text(switch (t.mode) {
                AppThemeMode.system => 'Follows your phone.',
                AppThemeMode.light => 'Always light.',
                AppThemeMode.dark => 'Always dark.',
              }, style: TextStyle(fontSize: 13, color: AppColors.textDim)),
            ),
            const SectionLabel('Accent'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var i = 0; i < accentOptions.length; i++)
                  Semantics(
                    button: true,
                    selected: t.accent == i,
                    label: accentOptions[i].name,
                    child: Pressable(
                      onTap: () => ctrl.update(t.copyWith(accent: i)),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2,
                                color: t.accent == i
                                    ? AppColors.text
                                    : Colors.transparent,
                              ),
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.isDark
                                    ? accentOptions[i].dark
                                    : accentOptions[i].light,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ExcludeSemantics(
                            child: Text(
                              accentOptions[i].name,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            const SectionLabel('Preview'),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '6:30 AM',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          'Wake up · Mon–Fri',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(value: true, onChanged: (_) {}),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GradientButton(label: 'New alarm', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
