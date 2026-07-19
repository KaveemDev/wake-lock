import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class StepMissionView extends StatefulWidget {
  final int targetSteps;
  final VoidCallback onCompleted;

  const StepMissionView({
    super.key,
    required this.targetSteps,
    required this.onCompleted,
  });

  @override
  State<StepMissionView> createState() => _StepMissionViewState();
}

class _StepMissionViewState extends State<StepMissionView> {
  int _steps = 0;
  DateTime _lastStepTime = DateTime.fromMillisecondsSinceEpoch(0);
  StreamSubscription<UserAccelerometerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _subscription = userAccelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen((event) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (magnitude > 11.0) {
        final now = DateTime.now();
        if (now.difference(_lastStepTime).inMilliseconds > 400) {
          _lastStepTime = now;
          setState(() {
            _steps++;
            if (_steps >= widget.targetSteps) {
              _subscription?.cancel();
              widget.onCompleted();
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_steps / widget.targetSteps).clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'WALK AWAY FROM YOUR BED',
          style: TextStyle(
            color: Colors.tealAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 36),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 16,
                backgroundColor: Colors.white.withOpacity(0.1),
                color: Colors.tealAccent,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_walk, size: 48, color: Colors.tealAccent),
                const SizedBox(height: 8),
                Text(
                  '$_steps / ${widget.targetSteps}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'STEPS',
                  style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 36),
        const Text(
          'Get out of bed and take steps around your room to stop the alarm.',
          style: TextStyle(color: Colors.white54, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
