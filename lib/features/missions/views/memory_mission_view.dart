import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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
    final seqLen = widget.difficulty == 'easy' ? 3 : (widget.difficulty == 'hard' ? 5 : 4);
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'MEMORY ROUND $_currentRound of ${widget.totalRounds}',
          style: const TextStyle(
            color: Colors.tealAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isShowingSequence
              ? (_hasError ? 'WRONG! WATCH AGAIN...' : 'WATCH THE SEQUENCE...')
              : 'REPEAT THE SEQUENCE (${_userInputs.length} / ${_sequence.length})',
          style: TextStyle(
            color: _hasError ? Colors.redAccent : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 28),

        // 3x3 Grid
        SizedBox(
          width: 280,
          height: 280,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            itemBuilder: (context, index) {
              final isFlashing = _flashingTile == index;
              return GestureDetector(
                onTap: () => _onTileTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isFlashing
                        ? Colors.tealAccent
                        : (_hasError && _userInputs.isNotEmpty && _userInputs.last == index
                            ? Colors.redAccent
                            : const Color(0xFF262638)),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isFlashing ? Colors.white : Colors.white.withOpacity(0.1),
                      width: isFlashing ? 3 : 1,
                    ),
                    boxShadow: isFlashing
                        ? [
                            BoxShadow(
                              color: Colors.tealAccent.withOpacity(0.6),
                              blurRadius: 16,
                              spreadRadius: 2,
                            )
                          ]
                        : [],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
