import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/ui/app_ui.dart';

class MemoryMissionView extends StatefulWidget {
  final String difficulty;
  final int totalRounds;
  final VoidCallback onCompleted;

  const MemoryMissionView({
    super.key,
    required this.difficulty,
    required this.totalRounds,
    required this.onCompleted,
  });

  @override
  State<MemoryMissionView> createState() => _MemoryMissionViewState();
}

class _MemoryMissionViewState extends State<MemoryMissionView> {
  int _currentRound = 1;
  late List<int> _sequence;
  List<int> _userInputs = [];
  int? _flashingTile;
  bool _isShowingSequence = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    final rnd = Random();
    final seqLen = widget.difficulty == 'easy'
        ? 3
        : (widget.difficulty == 'hard' ? 5 : 4);
    _sequence = List.generate(seqLen, (_) => rnd.nextInt(9));
    _userInputs = [];
    _hasError = false;
    _playSequence();
  }

  Future<void> _playSequence() async {
    setState(() {
      _isShowingSequence = true;
      _flashingTile = null;
    });
    await Future.delayed(const Duration(milliseconds: 600));

    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      setState(() {
        _flashingTile = _sequence[i];
      });
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() {
        _flashingTile = null;
      });
      await Future.delayed(const Duration(milliseconds: 250));
    }

    if (!mounted) return;
    setState(() {
      _isShowingSequence = false;
    });
  }

  void _onTileTap(int tileIndex) {
    if (_isShowingSequence) return;

    setState(() {
      _userInputs.add(tileIndex);
      final currentPos = _userInputs.length - 1;

      if (_userInputs[currentPos] != _sequence[currentPos]) {
        HapticFeedback.heavyImpact();
        _hasError = true;
        _isShowingSequence = true;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) _startRound();
        });
      } else if (_userInputs.length == _sequence.length) {
        if (_currentRound >= widget.totalRounds) {
          widget.onCompleted();
        } else {
          _currentRound++;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _startRound();
          });
        }
      }
    });
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Round $_currentRound of ${widget.totalRounds}',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _isShowingSequence
                          ? (_hasError
                                ? 'Wrong. Watch again.'
                                : 'Watch the pattern')
                          : 'Your turn: ${_userInputs.length} of ${_sequence.length}',
                      style: TextStyle(
                        color: _hasError ? AppColors.danger : AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 3x3 Grid
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 280,
                    maxHeight: 280,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        final isFlashing = _flashingTile == index;
                        final isWrong =
                            _hasError &&
                            _userInputs.isNotEmpty &&
                            _userInputs.last == index;
                        return Pressable(
                          scale: 0.9,
                          onTap: () => _onTileTap(index),
                          child: AnimatedScale(
                            scale: isFlashing ? 1.06 : 1,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOutBack,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isFlashing
                                    ? AppColors.accent
                                    : (isWrong
                                          ? AppColors.danger
                                          : AppColors.surfaceHi),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isFlashing
                                      ? AppColors.text
                                      : AppColors.border,
                                  width: isFlashing ? 2 : 1,
                                ),
                                boxShadow: isFlashing
                                    ? [
                                        BoxShadow(
                                          color: AppColors.accent.withValues(
                                            alpha: 0.6,
                                          ),
                                          blurRadius: 24,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
