import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeMissionView extends StatefulWidget {
  final int targetShakes;
  final VoidCallback onCompleted;

  const ShakeMissionView({
    super.key,
    required this.targetShakes,
    required this.onCompleted,
  });

  @override
  State<ShakeMissionView> createState() => _ShakeMissionViewState();
}

class _ShakeMissionViewState extends State<ShakeMissionView> with SingleTickerProviderStateMixin {
  int _shakes = 0;
  DateTime _lastShakeTime = DateTime.fromMillisecondsSinceEpoch(0);
  StreamSubscription<UserAccelerometerEvent>? _subscription;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 1.0,
      upperBound: 1.15,
    );
    _startListening();
  }

  void _startListening() {
    _subscription = userAccelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((event) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (magnitude > 13.0) {
        final now = DateTime.now();
        if (now.difference(_lastShakeTime).inMilliseconds > 180) {
          _lastShakeTime = now;
          _pulseController.forward().then((_) => _pulseController.reverse());
          setState(() {
            _shakes++;
            if (_shakes >= widget.targetShakes) {
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
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_shakes / widget.targetShakes).clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'SHAKE VIGOROUSLY TO DISMISS',
          style: TextStyle(
            color: Colors.tealAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 36),
        ScaleTransition(
          scale: _pulseController,
          child: Stack(
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
                  Text(
                    '$_shakes / ${widget.targetShakes}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SHAKES',
                    style: TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        const Text(
          'Keep shaking your phone until the circle fills up!',
          style: TextStyle(color: Colors.white54, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
