import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/models/alarm.dart';
import '../../../core/utils/alarm_time_utils.dart';
import '../../missions/models/mission.dart';
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
  String? _soundPath;
  late String _missionType;
  late String _missionDifficulty;
  late int _missionCount;
  late bool _isHardcoreMode;
  late bool _isVerificationRequired;
  late int _verificationMinutes;

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
      _soundPath = alarm.soundPath;
      _missionType = alarm.missionType;
      _missionDifficulty = alarm.missionDifficulty;
      _missionCount = alarm.missionCount;
      _isHardcoreMode = alarm.isHardcoreMode;
      _isVerificationRequired = alarm.isVerificationRequired;
      _verificationMinutes = alarm.verificationDurationMinutes;
    } else {
      final now = DateTime.now().add(const Duration(minutes: 5));
      _selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
      _labelController = TextEditingController(text: 'Wake Up');
      _selectedDays = {};
      _vibrate = true;
      _snoozeMinutes = 5;
      _soundName = 'Default System Alarm';
      _soundPath = null;
      _missionType = 'math';
      _missionDifficulty = 'medium';
      _missionCount = 3;
      _isHardcoreMode = false;
      _isVerificationRequired = true;
      _verificationMinutes = 5;
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
              backgroundColor: const Color(0xFF181824),
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

  Future<void> _pickCustomAudioFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.audio,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _soundPath = result.files.single.path;
          _soundName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick audio file: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showSoundPicker() {
    final builtInSounds = [
      'Default System Alarm',
      'Radar (Loud & Urgent)',
      'Beacon (Electronic)',
      'Circuit (Digital Pulse)',
      'Chimes (Gentle Wake)',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181824),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select Alarm Sound',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const Divider(height: 1, color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.folder_open, color: Colors.tealAccent),
                  title: const Text('Pick Custom Audio File...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    _soundPath != null ? 'Selected: $_soundName' : 'Browse MP3, WAV, OGG from device',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickCustomAudioFile();
                  },
                ),
                const Divider(height: 1, color: Colors.white12),
                ...builtInSounds.map((sound) {
                  final isSelected = _soundName == sound && _soundPath == null;
                  return ListTile(
                    leading: Icon(Icons.music_note, color: isSelected ? Colors.tealAccent : Colors.white54),
                    title: Text(sound, style: TextStyle(color: isSelected ? Colors.tealAccent : Colors.white)),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.tealAccent)
                        : null,
                    onTap: () {
                      setState(() {
                        _soundName = sound;
                        _soundPath = null;
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnoozePicker() {
    final options = [0, 5, 10, 15, 20];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181824),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              ...options.map((mins) {
                final text = mins == 0 ? 'Off (No Snooze)' : '$mins minutes';
                final isSelected = _snoozeMinutes == mins;
                return ListTile(
                  title: Text(text, style: TextStyle(color: isSelected ? Colors.tealAccent : Colors.white)),
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
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showVerificationDurationPicker() {
    final options = [1, 3, 5, 10, 15];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181824),
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
                  'Follow-Up Check Duration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'After dismissing the alarm, WakeLock will ask you to confirm you are still awake after this duration.',
                  style: TextStyle(fontSize: 13, color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              ...options.map((mins) {
                final isSelected = _verificationMinutes == mins;
                return ListTile(
                  title: Text('$mins minutes after dismissal', style: TextStyle(color: isSelected ? Colors.tealAccent : Colors.white)),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.tealAccent)
                      : null,
                  onTap: () {
                    setState(() {
                      _verificationMinutes = mins;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showMissionPicker() {
    final missions = [
      const MissionConfig(type: 'math', difficulty: 'medium', count: 3),
      const MissionConfig(type: 'shake', difficulty: 'medium', count: 30),
      const MissionConfig(type: 'typing', difficulty: 'medium', count: 2),
      const MissionConfig(type: 'memory', difficulty: 'medium', count: 3),
      const MissionConfig(type: 'step', difficulty: 'medium', count: 20),
      const MissionConfig(type: 'none', difficulty: 'easy', count: 1),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181824),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select Dismissal Mission',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const Divider(height: 1, color: Colors.white12),
                ...missions.map((cfg) {
                  final isSelected = _missionType == cfg.type;
                  return ListTile(
                    title: Text(cfg.displayName, style: TextStyle(color: isSelected ? Colors.tealAccent : Colors.white)),
                    subtitle: Text(cfg.description, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.tealAccent)
                        : null,
                    onTap: () {
                      setState(() {
                        _missionType = cfg.type;
                        if (cfg.type == 'shake') {
                          _missionCount = 30;
                        } else if (cfg.type == 'step') {
                          _missionCount = 20;
                        } else if (cfg.type == 'typing') {
                          _missionCount = 2;
                        } else {
                          _missionCount = cfg.count;
                        }
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDynamicMissionOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181824),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${_getMissionTitle(_missionType)} Configuration',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 12),

                    // Difficulty selector (for math, shake, memory)
                    if (_missionType == 'math' || _missionType == 'shake' || _missionType == 'memory') ...[
                      const Text(
                        'DIFFICULTY LEVEL',
                        style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: ['easy', 'medium', 'hard'].map((diff) {
                          final isSelected = _missionDifficulty == diff;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(
                                  diff.toUpperCase(),
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: Colors.tealAccent,
                                backgroundColor: const Color(0xFF252538),
                                onSelected: (selected) {
                                  if (selected) {
                                    setSheetState(() => _missionDifficulty = diff);
                                    setState(() => _missionDifficulty = diff);
                                  }
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Target / Count selector based on mission type
                    if (_missionType == 'math') ...[
                      const Text(
                        'NUMBER OF MATH PROBLEMS',
                        style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [1, 2, 3, 4, 5].map((num) {
                          final isSelected = _missionCount == num;
                          return ChoiceChip(
                            label: Text('$num Problems', style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                            selected: isSelected,
                            selectedColor: Colors.tealAccent,
                            backgroundColor: const Color(0xFF252538),
                            onSelected: (selected) {
                              if (selected) {
                                setSheetState(() => _missionCount = num);
                                setState(() => _missionCount = num);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ] else if (_missionType == 'shake') ...[
                      const Text(
                        'TARGET SHAKES REQUIRED',
                        style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [15, 30, 50, 75].map((num) {
                          final isSelected = _missionCount == num;
                          return ChoiceChip(
                            label: Text('$num Shakes', style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                            selected: isSelected,
                            selectedColor: Colors.tealAccent,
                            backgroundColor: const Color(0xFF252538),
                            onSelected: (selected) {
                              if (selected) {
                                setSheetState(() => _missionCount = num);
                                setState(() => _missionCount = num);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ] else if (_missionType == 'typing') ...[
                      const Text(
                        'NUMBER OF QUOTES TO TYPE',
                        style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [1, 2, 3].map((num) {
                          final isSelected = _missionCount == num;
                          return ChoiceChip(
                            label: Text('$num Quotes', style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                            selected: isSelected,
                            selectedColor: Colors.tealAccent,
                            backgroundColor: const Color(0xFF252538),
                            onSelected: (selected) {
                              if (selected) {
                                setSheetState(() => _missionCount = num);
                                setState(() => _missionCount = num);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ] else if (_missionType == 'memory') ...[
                      const Text(
                        'SEQUENCE ROUNDS TO REPEAT',
                        style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [3, 4, 5].map((num) {
                          final isSelected = _missionCount == num;
                          return ChoiceChip(
                            label: Text('$num Rounds', style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                            selected: isSelected,
                            selectedColor: Colors.tealAccent,
                            backgroundColor: const Color(0xFF252538),
                            onSelected: (selected) {
                              if (selected) {
                                setSheetState(() => _missionCount = num);
                                setState(() => _missionCount = num);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ] else if (_missionType == 'step') ...[
                      const Text(
                        'TARGET WALKING STEPS',
                        style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [10, 20, 30, 50].map((num) {
                          final isSelected = _missionCount == num;
                          return ChoiceChip(
                            label: Text('$num Steps', style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                            selected: isSelected,
                            selectedColor: Colors.tealAccent,
                            backgroundColor: const Color(0xFF252538),
                            onSelected: (selected) {
                              if (selected) {
                                setSheetState(() => _missionCount = num);
                                setState(() => _missionCount = num);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getMissionTitle(String type) {
    switch (type) {
      case 'math': return 'Math Challenge';
      case 'shake': return 'Shake Challenge';
      case 'typing': return 'Typing Challenge';
      case 'memory': return 'Memory Grid';
      case 'step': return 'Step Counter';
      default: return 'No Mission';
    }
  }

  String _getMissionSubtitle() {
    if (_missionType == 'none') return 'Tap to dismiss instantly';
    if (_missionType == 'math') return '${_missionCount} problems (${_missionDifficulty.toUpperCase()})';
    if (_missionType == 'shake') return '${_missionCount} shakes (${_missionDifficulty.toUpperCase()})';
    if (_missionType == 'typing') return '${_missionCount} quotes';
    if (_missionType == 'memory') return '${_missionCount} rounds (${_missionDifficulty.toUpperCase()})';
    if (_missionType == 'step') return '${_missionCount} steps';
    return '${_missionCount} tasks (${_missionDifficulty.toUpperCase()})';
  }

  @override
  Widget build(BuildContext context) {
    final nextRingTime = AlarmTimeUtils.computeNextRingTime(
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      repeatDays: _selectedDays.toList(),
    );
    final countdownText = AlarmTimeUtils.formatCountdown(nextRingTime);
    final missionCfg = MissionConfig(type: _missionType, difficulty: _missionDifficulty, count: _missionCount);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.existingAlarm == null ? 'Create WakeLock Alarm' : 'Edit WakeLock Alarm',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                              Colors.teal.withOpacity(0.25),
                              const Color(0xFF181824),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.teal.withOpacity(0.4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _selectedTime.format(context),
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                    Material(
                      color: const Color(0xFF181824),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                    ),
                    const SizedBox(height: 16),

                    // Mission Selector
                    _buildTile(
                      icon: Icons.assignment_turned_in,
                      title: 'Dismissal Mission',
                      subtitle: missionCfg.displayName,
                      onTap: _showMissionPicker,
                    ),
                    const SizedBox(height: 12),

                    // Dynamic Mission Options Tile (If mission != none)
                    if (_missionType != 'none') ...[
                      _buildTile(
                        icon: Icons.tune,
                        title: 'Mission Configuration',
                        subtitle: _getMissionSubtitle(),
                        onTap: _showDynamicMissionOptionsSheet,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Sound Selector Tile
                    _buildTile(
                      icon: Icons.music_note,
                      title: 'Alarm Sound',
                      subtitle: _soundPath != null ? 'Custom: $_soundName' : _soundName,
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

                    // Hardcore Mode Switch Tile
                    Material(
                      color: const Color(0xFF181824),
                      borderRadius: BorderRadius.circular(16),
                      child: SwitchListTile(
                        value: _isHardcoreMode,
                        activeColor: Colors.redAccent,
                        onChanged: (val) {
                          setState(() {
                            _isHardcoreMode = val;
                          });
                        },
                        secondary: const Icon(Icons.local_fire_department, color: Colors.redAccent),
                        title: const Text('Hardcore Mode', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                        subtitle: const Text(
                          'Locks snooze & volume during ring',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Wake-Up Verification Switch Tile
                    Material(
                      color: const Color(0xFF181824),
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        children: [
                          SwitchListTile(
                            value: _isVerificationRequired,
                            activeColor: Colors.tealAccent,
                            onChanged: (val) {
                              setState(() {
                                _isVerificationRequired = val;
                              });
                            },
                            secondary: const Icon(Icons.verified_user, color: Colors.tealAccent),
                            title: const Text('Wake-Up Verification', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                            subtitle: const Text(
                              'Follow-up check-in to confirm awake',
                              style: TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                          ),
                          if (_isVerificationRequired) ...[
                            const Divider(height: 1, color: Colors.white12),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                              leading: const Icon(Icons.timer_outlined, size: 20, color: Colors.tealAccent),
                              title: const Text('Check-In Delay', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              subtitle: Text(
                                'Check in after $_verificationMinutes minutes',
                                style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              trailing: const Icon(Icons.edit, size: 16, color: Colors.white38),
                              onTap: _showVerificationDurationPicker,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Vibration Toggle Tile
                    Material(
                      color: const Color(0xFF181824),
                      borderRadius: BorderRadius.circular(16),
                      child: SwitchListTile(
                        value: _vibrate,
                        activeColor: Colors.tealAccent,
                        onChanged: (val) {
                          setState(() {
                            _vibrate = val;
                          });
                        },
                        secondary: const Icon(Icons.vibration, color: Colors.tealAccent),
                        title: const Text('Vibrate While Ringing', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
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
                color: const Color(0xFF141420),
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
                      soundPath: _soundPath,
                      missionType: _missionType,
                      missionDifficulty: _missionDifficulty,
                      missionCount: _missionCount,
                      isHardcoreMode: _isHardcoreMode,
                      isVerificationRequired: _isVerificationRequired,
                      verificationDurationMinutes: _verificationMinutes,
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isSelected ? Colors.tealAccent : const Color(0xFF181824),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.tealAccent : Colors.white.withOpacity(0.12),
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
            fontSize: 15,
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
    return Material(
      color: const Color(0xFF181824),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.tealAccent, size: 26),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}
