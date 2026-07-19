import 'dart:math';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _generateProblem();
  }

  void _generateProblem() {
    final rnd = Random();
    if (widget.difficulty == 'easy') {
      final a = 10 + rnd.nextInt(80);
      final b = 10 + rnd.nextInt(80);
      _equationText = '$a + $b';
      _correctAnswer = a + b;
    } else if (widget.difficulty == 'hard') {
      final a = 12 + rnd.nextInt(25);
      final b = 10 + rnd.nextInt(15);
      final c = 10 + rnd.nextInt(50);
      _equationText = '$a × $b + $c';
      _correctAnswer = a * b + c;
    } else {
      // medium
      final a = 15 + rnd.nextInt(75);
      final b = 2 + rnd.nextInt(8);
      final c = 10 + rnd.nextInt(50);
      _equationText = '$a + $b × $c';
      _correctAnswer = a + (b * c);
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
      setState(() {
        _hasError = true;
        _inputBuffer = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Header
        Text(
          'PROBLEM $_currentIndex of ${widget.totalProblems}',
          style: const TextStyle(
            color: Colors.tealAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),

        // Equation Card
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hasError ? Colors.redAccent : Colors.white.withOpacity(0.1),
              width: _hasError ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$_equationText = ?',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 200,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasError ? Colors.redAccent : Colors.tealAccent.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  _inputBuffer.isEmpty ? (_hasError ? 'WRONG' : '_') : _inputBuffer,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _hasError ? Colors.redAccent : Colors.tealAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Keypad
        SizedBox(
          width: 300,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
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
              _buildKey('C', _onClear, color: Colors.redAccent.withOpacity(0.2), textColor: Colors.redAccent),
              _buildKey('0', () => _onDigit('0')),
              _buildKey('✓', _onSubmit, color: Colors.tealAccent, textColor: Colors.black),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKey(String label, VoidCallback onTap, {Color? color, Color? textColor}) {
    return Material(
      color: color ?? const Color(0xFF262638),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
