import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/ui/app_ui.dart';
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

class _ShakeMissionViewState extends State<ShakeMissionView>
    with SingleTickerProviderStateMixin {
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
    _subscription =
        userAccelerometerEventStream(
          samplingPeriod: SensorInterval.gameInterval,
        ).listen((event) {
          final magnitude = sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z,
          );
          if (magnitude > 13.0) {
            final now = DateTime.now();
            if (now.difference(_lastShakeTime).inMilliseconds > 180) {
              _lastShakeTime = now;
              HapticFeedback.lightImpact();
              _pulseController.forward().then(
                (_) => _pulseController.reverse(),
              );
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 0.0;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Shake your phone',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                ScaleTransition(
                  scale: _pulseController,
                  child: ProgressRing(
                    value: progress,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.vibration_rounded,
                          size: 40,
                          color: AppColors.accent,
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$_shakes / ${widget.targetShakes}',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Text(
                          'shakes',
                          style: TextStyle(
                            color: AppColors.textDim,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Keep going until the ring is full.',
                    style: TextStyle(color: AppColors.textDim, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
