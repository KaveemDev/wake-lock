import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/ui/app_ui.dart';
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
    _subscription =
        userAccelerometerEventStream(
          samplingPeriod: SensorInterval.uiInterval,
        ).listen((event) {
          final magnitude = sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z,
          );
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
                    'Get out of bed and walk',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                ProgressRing(
                  value: progress,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_walk_rounded,
                        size: 44,
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$_steps / ${widget.targetSteps}',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      Text(
                        'steps',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Carry your phone. The alarm stops when you hit the goal.',
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
