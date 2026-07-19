import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/models/alarm.dart';
import '../../../core/utils/alarm_time_utils.dart';
import '../providers/alarms_provider.dart';

class AlarmEditScreen extends ConsumerStatefulWidget {
  final Alarm? existingAlarm;

  const AlarmEditScreen({super.key, this.existingAlarm});

  @override
  ConsumerState<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends ConsumerState<AlarmEditScreen> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  late Set<int> _selectedDays; // 1 = Mon .. 7 = Sun
  late bool _vibrate;
  late int _snoozeMinutes;
  late String _soundName;

  @override
  void initState() {
    super.initState();
    final alarm = widget.existingAlarm;
    if (alarm != null) {
      _selectedTime = TimeOfDay(hour: alarm.time.hour, minute: alarm.time.minute);
      _labelController = TextEditingController(text: alarm.label);
      _selectedDays = Set<int>.from(alarm.repeatDays);
      _vibrate = alarm.vibrate;
      _snoozeMinutes = alarm.snoozeDurationMinutes;
      _soundName = alarm.soundName;
    } else {
      final now = DateTime.now().add(const Duration(minutes: 5));
      _selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
      _labelController = TextEditingController(text: 'Wake Up');
      _selectedDays = {};
      _vibrate = true;
      _snoozeMinutes = 5;
      _soundName = 'Default System Alarm';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF1E1E2C),
              hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _showSoundPicker() {
    final sounds = [
      'Default System Alarm',
      'Radar (Loud & Urgent)',
      'Beacon (Electronic)',
      'Circuit (Digital Pulse)',
      'Chimes (Gentle Wake)',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select Alarm Sound',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              ...sounds.map((sound) {
                final isSelected = _soundName == sound;
                return ListTile(
                  title: Text(sound),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.tealAccent)
                      : null,
                  onTap: () {
                    setState(() {
                      _soundName = sound;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSnoozePicker() {
    final options = [0, 5, 10, 15, 20];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select Snooze Duration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              ...options.map((mins) {
                final text = mins == 0 ? 'Off (No Snooze)' : '$mins minutes';
                final isSelected = _snoozeMinutes == mins;
                return ListTile(
                  title: Text(text),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.tealAccent)
                      : null,
                  onTap: () {
                    setState(() {
                      _snoozeMinutes = mins;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextRingTime = AlarmTimeUtils.computeNextRingTime(
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      repeatDays: _selectedDays.toList(),
    );
    final countdownText = AlarmTimeUtils.formatCountdown(nextRingTime);

    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.existingAlarm == null ? 'Create Alarm' : 'Edit Alarm',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.existingAlarm != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                await ref.read(alarmsControllerProvider).deleteAlarm(widget.existingAlarm!);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Time Selector Card
                    GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.withOpacity(0.2),
                              const Color(0xFF1E1E2C),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.teal.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                countdownText,
                                style: const TextStyle(
                                  color: Colors.tealAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Repeat Days Pill Row
                    const Text(
                      'REPEAT DAYS',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDayPill(1, 'M'),
                        _buildDayPill(2, 'T'),
                        _buildDayPill(3, 'W'),
                        _buildDayPill(4, 'T'),
                        _buildDayPill(5, 'F'),
                        _buildDayPill(6, 'S'),
                        _buildDayPill(7, 'S'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Label Input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _labelController,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.label_outline, color: Colors.tealAccent),
                          hintText: 'Alarm Label (e.g. Wake Up)',
                          hintStyle: TextStyle(color: Colors.white38),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sound Selector Tile
                    _buildTile(
                      icon: Icons.music_note,
                      title: 'Alarm Sound',
                      subtitle: _soundName,
                      onTap: _showSoundPicker,
                    ),
                    const SizedBox(height: 12),

                    // Snooze Duration Tile
                    _buildTile(
                      icon: Icons.snooze,
                      title: 'Snooze',
                      subtitle: _snoozeMinutes == 0
                          ? 'Off'
                          : 'Every $_snoozeMinutes minutes',
                      onTap: _showSnoozePicker,
                    ),
                    const SizedBox(height: 12),

                    // Vibration Toggle Tile
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SwitchListTile(
                        value: _vibrate,
                        activeColor: Colors.tealAccent,
                        onChanged: (val) {
                          setState(() {
                            _vibrate = val;
                          });
                        },
                        secondary: const Icon(Icons.vibration, color: Colors.tealAccent),
                        title: const Text('Vibrate While Ringing'),
                        subtitle: const Text(
                          'Pulsing vibration pattern',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A26),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    await ref.read(alarmsControllerProvider).saveOrUpdateAlarm(
                      existingId: widget.existingAlarm?.id,
                      hour: _selectedTime.hour,
                      minute: _selectedTime.minute,
                      label: _labelController.text,
                      repeatDays: _selectedDays.toList(),
                      vibrate: _vibrate,
                      snoozeDurationMinutes: _snoozeMinutes,
                      soundName: _soundName,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    widget.existingAlarm == null ? 'SAVE ALARM' : 'UPDATE ALARM',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPill(int dayIndex, String letter) {
    final isSelected = _selectedDays.contains(dayIndex);
    return GestureDetector(
      onTap: () => _toggleDay(dayIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? Colors.tealAccent : const Color(0xFF1E1E2C),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.tealAccent : Colors.white.withOpacity(0.1),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.tealAccent.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          letter,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.tealAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
      ),
    );
  }
}
