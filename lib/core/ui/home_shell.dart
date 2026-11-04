import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/alarms/views/alarm_list_screen.dart';
import '../../features/permissions/views/permissions_screen.dart';
import '../../features/stats/views/stats_screen.dart';
import 'app_ui.dart';

/// Root scaffold with a three-tab bottom bar. Tabs build lazily on first visit
/// (so their entrance animations play when first seen) and keep their state.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _tabs = [
    (Icons.alarm_rounded, Icons.alarm_rounded, 'Alarms'),
    (Icons.bar_chart_rounded, Icons.bar_chart_rounded, 'Stats'),
    (Icons.verified_user_outlined, Icons.verified_user_outlined, 'Setup'),
  ];
  int _index = 0;
  final _visited = {0};

  Widget _page(int i) => switch (i) {
    0 => const AlarmListScreen(),
    1 => const StatsScreen(),
    _ => const PermissionsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (var i = 0; i < _tabs.length; i++)
            _visited.contains(i)
                ? AnimatedOpacity(
                    opacity: _index == i ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: _page(i),
                  )
                : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.bg.withValues(alpha: 0.96),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _NavItem(
                      icon: _tabs[i].$1,
                      label: _tabs[i].$3,
                      selected: _index == i,
                      onTap: () {
                        if (_index == i) return;
                        HapticFeedback.selectionClick();
                        setState(() {
                          _index = i;
                          _visited.add(i);
                        });
                      },
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textFaint;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Pressable(
        onTap: onTap,
        scale: 0.94,
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: selected ? 56 : 36,
                height: 30,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accent.withValues(alpha: 0.16)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
