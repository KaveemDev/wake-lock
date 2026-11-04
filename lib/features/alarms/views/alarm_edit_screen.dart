import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/db/models/alarm.dart';
import '../../../core/ui/app_ui.dart';
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
      _selectedTime = TimeOfDay(
        hour: alarm.time.hour,
        minute: alarm.time.minute,
      );
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
      _soundName = 'Phone default';
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
              backgroundColor: AppColors.surface,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
      final result = await FilePicker.pickFiles(type: FileType.audio);
      if (result != null && result.files.single.path != null) {
        final tempPath = result.files.single.path!;
        final fileName = result.files.single.name;
        final appDir = await getApplicationDocumentsDirectory();
        final customSoundsDir = Directory('${appDir.path}/custom_sounds');
        if (!await customSoundsDir.exists()) {
          await customSoundsDir.create(recursive: true);
        }
        final savedFile = await File(
          tempPath,
        ).copy('${customSoundsDir.path}/$fileName');
        setState(() {
          _soundPath = savedFile.path;
          _soundName = fileName;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick audio file: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showSoundPicker() {
    final builtInSounds = [
      'Phone default',
      'Radar',
      'Beacon',
      'Circuit',
      'Chimes',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Sound',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ),
                Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: Icon(
                    Icons.folder_open,
                    color: AppColors.accent,
                  ),
                  title: Text(
                    'Pick a file',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    _soundPath != null
                        ? 'Selected: $_soundName'
                        : 'MP3, WAV or OGG from your phone',
                    style: TextStyle(color: AppColors.textDim, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickCustomAudioFile();
                  },
                ),
                Divider(height: 1, color: AppColors.border),
                ...builtInSounds.map((sound) {
                  final isSelected = _soundName == sound && _soundPath == null;
                  return ListTile(
                    leading: Icon(
                      Icons.music_note,
                      color: isSelected ? AppColors.accent : AppColors.textDim,
                    ),
                    title: Text(
                      sound,
                      style: TextStyle(
                        color: isSelected ? AppColors.accent : AppColors.text,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.accent,
                          )
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Snooze',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              Divider(height: 1, color: AppColors.border),
              ...options.map((mins) {
                final text = mins == 0 ? 'Off' : '$mins minutes';
                final isSelected = _snoozeMinutes == mins;
                return ListTile(
                  title: Text(
                    text,
                    style: TextStyle(
                      color: isSelected ? AppColors.accent : AppColors.text,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: AppColors.accent)
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Check-in after',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'After you dismiss the alarm, WakeLock asks if you\'re still up after this long.',
                  style: TextStyle(fontSize: 13, color: AppColors.textDim),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(height: 1, color: AppColors.border),
              ...options.map((mins) {
                final isSelected = _verificationMinutes == mins;
                return ListTile(
                  title: Text(
                    '$mins minutes after dismissal',
                    style: TextStyle(
                      color: isSelected ? AppColors.accent : AppColors.text,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: AppColors.accent)
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Mission to turn it off',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ),
                Divider(height: 1, color: AppColors.border),
                ...missions.map((cfg) {
                  final isSelected = _missionType == cfg.type;
                  return ListTile(
                    title: Text(
                      cfg.displayName,
                      style: TextStyle(
                        color: isSelected ? AppColors.accent : AppColors.text,
                      ),
                    ),
                    subtitle: Text(
                      cfg.description,
                      style: TextStyle(
                        color: AppColors.textDim,
                        fontSize: 13,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.accent,
                          )
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
      backgroundColor: AppColors.surface,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Divider(color: AppColors.border),
                    const SizedBox(height: 12),

                    // Difficulty selector (for math, shake, memory)
                    if (_missionType == 'math' ||
                        _missionType == 'shake' ||
                        _missionType == 'memory') ...[
                      Text(
                        'Difficulty',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: ['easy', 'medium', 'hard'].map((diff) {
                          final isSelected = _missionDifficulty == diff;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: ChoiceChip(
                                label: Text(
                                  diff,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.onAccent
                                        : AppColors.text,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.accent,
                                backgroundColor: AppColors.surfaceHi,
                                onSelected: (selected) {
                                  if (selected) {
                                    setSheetState(
                                      () => _missionDifficulty = diff,
                                    );
                                    setState(() => _missionDifficulty = diff);
                                  }
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_missionType == 'math') ...[
                        const SizedBox(height: 8),
                        Text(
                          _missionDifficulty == 'easy'
                              ? 'Example: 7 + 4'
                              : _missionDifficulty == 'medium'
                              ? '2-Digit Addition & Subtraction (e.g. 45 + 32 or 78 - 19)'
                              : 'Example: 15 × 12 + 30',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],

                    // Target / Count selector based on mission type
                    if (_missionType == 'math') ...[
                      Text(
                        'Problems',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [1, 2, 3, 4, 5].map((count) {
                          final isSelected = _missionCount == count;
                          return ChoiceChip(
                            label: Text(
                              '$count Problems',
                              style: TextStyle(
                                color: isSelected ? AppColors.onAccent : AppColors.text,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.accent,
                            backgroundColor: AppColors.surfaceHi,
                            onSelected: (selected) {
                              if (selected) {
                                setSheetState(() => _missionCount = count);
                                setState(() => _missionCount = count);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ] else if (_missionType == 'shake') ...[
                      Text(
                        'Shakes',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [15, 30, 50, 75].map((count) {
                          final isSelected = _missionCount == count;
                          return ChoiceChip(
                            label: Text(
                              '$count Shakes',
                              style: TextStyle(
                                color: isSelected ? AppColors.onAccent : AppColors.text,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.accent,
                            backgroundColor: AppColors.surfaceHi,
                            onSelected: (selected) {
                              if (selected) {
                                setSheetState(() => _missionCount = count);
                                setState(() => _missionCount = count);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ] else if (_missionType == 'typing') ...[
                      Text(
                        'Phrases',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [1, 2, 3].map((count) {
                          final isSelected = _missionCount == count;
                          return ChoiceChip(
                            label: Text(
                              '$count Quotes',
                              style: TextStyle(
                                color: isSelected ? AppColors.onAccent : AppColors.text,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.accent,
                            backgroundColor: AppColors.surfaceHi,
                            onSelected: (selected) {
                              if (selected) {
                                setSheetState(() => _missionCount = count);
                                setState(() => _missionCount = count);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ] else if (_missionType == 'memory') ...[
                      Text(
                        'Rounds',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [3, 4, 5].map((count) {
                          final isSelected = _missionCount == count;
                          return ChoiceChip(
                            label: Text(
                              '$count Rounds',
                              style: TextStyle(
                                color: isSelected ? AppColors.onAccent : AppColors.text,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.accent,
                            backgroundColor: AppColors.surfaceHi,
                            onSelected: (selected) {
                              if (selected) {
                                setSheetState(() => _missionCount = count);
                                setState(() => _missionCount = count);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ] else if (_missionType == 'step') ...[
                      Text(
                        'Steps',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [10, 20, 30, 50].map((count) {
                          final isSelected = _missionCount == count;
                          return ChoiceChip(
                            label: Text(
                              '$count Steps',
                              style: TextStyle(
                                color: isSelected ? AppColors.onAccent : AppColors.text,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.accent,
                            backgroundColor: AppColors.surfaceHi,
                            onSelected: (selected) {
                              if (selected) {
                                setSheetState(() => _missionCount = count);
                                setState(() => _missionCount = count);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.onAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
      case 'math':
        return 'Math';
      case 'shake':
        return 'Shake';
      case 'typing':
        return 'Typing';
      case 'memory':
        return 'Memory';
      case 'step':
        return 'Steps';
      default:
        return 'None';
    }
  }

  String _getMissionSubtitle() {
    if (_missionType == 'none') {
      return 'Tap to stop';
    }
    if (_missionType == 'math') {
      return '$_missionCount problems ($_missionDifficulty)';
    }
    if (_missionType == 'shake') {
      return '$_missionCount shakes ($_missionDifficulty)';
    }
    if (_missionType == 'typing') {
      return '$_missionCount quotes';
    }
    if (_missionType == 'memory') {
      return '$_missionCount rounds ($_missionDifficulty)';
    }
    if (_missionType == 'step') {
      return '$_missionCount steps';
    }
    return '$_missionCount tasks ($_missionDifficulty)';
  }

  @override
  Widget build(BuildContext context) {
    final nextRingTime = AlarmTimeUtils.computeNextRingTime(
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      repeatDays: _selectedDays.toList(),
    );
    final countdownText = AlarmTimeUtils.formatCountdown(nextRingTime);
    final missionCfg = MissionConfig(
      type: _missionType,
      difficulty: _missionDifficulty,
      count: _missionCount,
    );
    final isEdit = widget.existingAlarm != null;

    // Staggered entrance: each section gets a slightly later delay.
    var step = 0;
    Widget section(Widget child) => FadeSlideIn(
      delay: FadeSlideIn.stagger(step++),
      child: Padding(padding: const EdgeInsets.only(bottom: 12), child: child),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit alarm' : 'New alarm',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
              tooltip: 'Delete alarm',
              onPressed: () async {
                await ref
                    .read(alarmsControllerProvider)
                    .deleteAlarm(widget.existingAlarm!);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: GlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Time card
                      section(
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            onTap: _pickTime,
                            padding: const EdgeInsets.symmetric(
                              vertical: 30,
                              horizontal: 20,
                            ),
                            borderColor: AppColors.accent.withValues(
                              alpha: 0.3,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accent.withValues(alpha: 0.2),
                                AppColors.accent2.withValues(alpha: 0.12),
                                AppColors.surface,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shadows: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.10),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            child: Column(
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (c, a) => FadeTransition(
                                    opacity: a,
                                    child: ScaleTransition(
                                      scale: Tween(
                                        begin: 0.92,
                                        end: 1.0,
                                      ).animate(a),
                                      child: c,
                                    ),
                                  ),
                                  child: FittedBox(
                                    key: ValueKey(_selectedTime),
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _selectedTime.format(context),
                                      style: TextStyle(
                                        fontSize: 68,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Container(
                                    key: ValueKey(countdownText),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.bg.withValues(
                                        alpha: 0.55,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      countdownText,
                                      style: TextStyle(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to change',
                                  style: TextStyle(
                                    color: AppColors.textFaint,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Repeat days
                      section(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel('Repeat'),
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
                          ],
                        ),
                      ),

                      // Label
                      section(
                        AppCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 2,
                          ),
                          child: TextField(
                            controller: _labelController,
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                            ),
                            cursorColor: AppColors.accent,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.edit_note_rounded,
                                color: AppColors.accent,
                              ),
                              hintText: 'Label',
                              hintStyle: TextStyle(color: AppColors.textFaint),
                            ),
                          ),
                        ),
                      ),

                      section(
                        _buildTile(
                          icon: Icons.assignment_turned_in_rounded,
                          title: 'Mission',
                          subtitle: missionCfg.displayName,
                          onTap: _showMissionPicker,
                        ),
                      ),

                      // Collapses in/out when mission is "none"
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: _missionType == 'none'
                            ? const SizedBox(width: double.infinity)
                            : section(
                                _buildTile(
                                  icon: Icons.tune_rounded,
                                  title: 'Mission settings',
                                  subtitle: _getMissionSubtitle(),
                                  onTap: _showDynamicMissionOptionsSheet,
                                ),
                              ),
                      ),

                      section(
                        _buildTile(
                          icon: Icons.music_note_rounded,
                          title: 'Sound',
                          subtitle: _soundPath != null
                              ? 'Custom: $_soundName'
                              : _soundName,
                          onTap: _showSoundPicker,
                        ),
                      ),

                      section(
                        _buildTile(
                          icon: Icons.snooze_rounded,
                          title: 'Snooze',
                          subtitle: _snoozeMinutes == 0
                              ? 'Off'
                              : 'Every $_snoozeMinutes minutes',
                          onTap: _showSnoozePicker,
                        ),
                      ),

                      section(
                        _buildSwitchTile(
                          icon: Icons.local_fire_department_rounded,
                          color: AppColors.danger,
                          title: 'Hardcore',
                          subtitle: 'No snooze. Volume stays at max.',
                          value: _isHardcoreMode,
                          onChanged: (v) => setState(() => _isHardcoreMode = v),
                        ),
                      ),

                      section(
                        AppCard(
                          padding: EdgeInsets.zero,
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: [
                                _switchRow(
                                  icon: Icons.verified_user_rounded,
                                  color: AppColors.accent,
                                  title: 'Check-in',
                                  subtitle:
                                      'Asks if you\'re up after you dismiss',
                                  value: _isVerificationRequired,
                                  onChanged: (v) => setState(
                                    () => _isVerificationRequired = v,
                                  ),
                                ),
                                if (_isVerificationRequired) ...[
                                  const Divider(),
                                  InkWell(
                                    onTap: _showVerificationDurationPicker,
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(22),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.timer_outlined,
                                            size: 20,
                                            color: AppColors.accent,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(
                                              'Check in after $_verificationMinutes minutes',
                                              style: TextStyle(
                                                color: AppColors.accent,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.edit_rounded,
                                            size: 16,
                                            color: AppColors.textFaint,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                      section(
                        _buildSwitchTile(
                          icon: Icons.vibration_rounded,
                          color: AppColors.accent2,
                          title: 'Vibrate',
                          subtitle: 'Pulses while ringing',
                          value: _vibrate,
                          onChanged: (v) => setState(() => _vibrate = v),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom action bar
              FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                offset: const Offset(0, 40),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  decoration: BoxDecoration(
                    color: AppColors.bg.withValues(alpha: 0.92),
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: GradientButton(
                    label: isEdit ? 'Save' : 'Save',
                    icon: Icons.check_rounded,
                    onPressed: () async {
                      await ref
                          .read(alarmsControllerProvider)
                          .saveOrUpdateAlarm(
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayPill(int dayIndex, String letter) {
    final isSelected = _selectedDays.contains(dayIndex);
    return Pressable(
      onTap: () => _toggleDay(dayIndex),
      scale: 0.85,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
        ),
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: isSelected ? AppColors.onAccent : AppColors.textDim,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
          child: Text(letter),
        ),
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: color, size: 22),
  );

  Widget _switchRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
      child: Row(
        children: [
          _iconBadge(icon, color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderColor: value ? color.withValues(alpha: 0.35) : null,
      child: _switchRow(
        icon: icon,
        color: color,
        title: title,
        subtitle: subtitle,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          _iconBadge(icon, AppColors.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            size: 24,
            color: AppColors.textFaint,
          ),
        ],
      ),
    );
  }
}
