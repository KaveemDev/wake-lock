import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/ui/app_ui.dart';

class MathMissionView extends StatefulWidget {
  final String difficulty;
  final int totalProblems;
  final VoidCallback onCompleted;

  const MathMissionView({
    super.key,
    required this.difficulty,
    required this.totalProblems,
    required this.onCompleted,
  });

  @override
  State<MathMissionView> createState() => _MathMissionViewState();
}

class _MathMissionViewState extends State<MathMissionView> {
  int _currentIndex = 1;
  late String _equationText;
  late int _correctAnswer;
  String _inputBuffer = '';
  bool _hasError = false;
  int _errorCount = 0;

  @override
  void initState() {
    super.initState();
    _generateProblem();
  }

  void _generateProblem() {
    final rnd = Random();
    if (widget.difficulty == 'easy') {
      // Single digit (+ or -)
      final isAdd = rnd.nextBool();
      if (isAdd) {
        final a = 1 + rnd.nextInt(9);
        final b = 1 + rnd.nextInt(9);
        _equationText = '$a + $b';
        _correctAnswer = a + b;
      } else {
        final a = 2 + rnd.nextInt(8); // 2 to 9
        final b = 1 + rnd.nextInt(a); // 1 to a (ensures positive answer)
        _equationText = '$a - $b';
        _correctAnswer = a - b;
      }
    } else if (widget.difficulty == 'hard') {
      // Multi-digit & Mixed expressions
      final a = 12 + rnd.nextInt(25);
      final b = 10 + rnd.nextInt(15);
      final c = 10 + rnd.nextInt(50);
      _equationText = '$a × $b + $c';
      _correctAnswer = a * b + c;
    } else {
      // medium: 2 digits (+ or -)
      final isAdd = rnd.nextBool();
      if (isAdd) {
        final a = 10 + rnd.nextInt(90); // 10 to 99
        final b = 10 + rnd.nextInt(90); // 10 to 99
        _equationText = '$a + $b';
        _correctAnswer = a + b;
      } else {
        final a = 20 + rnd.nextInt(80); // 20 to 99
        final b =
            10 + rnd.nextInt(a - 10); // 10 to a-1 (ensures positive answer)
        _equationText = '$a - $b';
        _correctAnswer = a - b;
      }
    }
    _inputBuffer = '';
    _hasError = false;
  }

  void _onDigit(String digit) {
    if (_inputBuffer.length < 6) {
      setState(() {
        _hasError = false;
        _inputBuffer += digit;
      });
    }
  }

  void _onClear() {
    setState(() {
      _hasError = false;
      _inputBuffer = '';
    });
  }

  void _onSubmit() {
    final val = int.tryParse(_inputBuffer);
    if (val == _correctAnswer) {
      if (_currentIndex >= widget.totalProblems) {
        widget.onCompleted();
      } else {
        setState(() {
          _currentIndex++;
          _generateProblem();
        });
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _hasError = true;
        _errorCount++;
        _inputBuffer = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                // Progress
                Text(
                  'Problem $_currentIndex of ${widget.totalProblems}',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: (_currentIndex - 1) / widget.totalProblems,
                    ),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Equation Card
                ShakeOnChange(
                  trigger: _errorCount,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _hasError
                            ? AppColors.danger
                            : AppColors.border,
                        width: _hasError ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$_equationText = ?',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 200,
                          height: 54,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _hasError
                                  ? AppColors.danger
                                  : AppColors.accent.withValues(alpha: 0.4),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                _inputBuffer.isEmpty
                                    ? (_hasError ? 'Wrong, try again' : '_')
                                    : _inputBuffer,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: _hasError
                                      ? AppColors.danger
                                      : AppColors.accent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Keypad
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.45,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _buildKey('1', () => _onDigit('1')),
                      _buildKey('2', () => _onDigit('2')),
                      _buildKey('3', () => _onDigit('3')),
                      _buildKey('4', () => _onDigit('4')),
                      _buildKey('5', () => _onDigit('5')),
                      _buildKey('6', () => _onDigit('6')),
                      _buildKey('7', () => _onDigit('7')),
                      _buildKey('8', () => _onDigit('8')),
                      _buildKey('9', () => _onDigit('9')),
                      _buildKey(
                        'C',
                        _onClear,
                        color: AppColors.danger.withValues(alpha: 0.2),
                        textColor: AppColors.danger,
                      ),
                      _buildKey('0', () => _onDigit('0')),
                      _buildKey(
                        '✓',
                        _onSubmit,
                        color: AppColors.accent,
                        textColor: AppColors.onAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKey(
    String label,
    VoidCallback onTap, {
    Color? color,
    Color? textColor,
  }) {
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? AppColors.surfaceHi,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: textColor ?? AppColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
