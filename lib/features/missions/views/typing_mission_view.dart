import 'dart:math';
import 'package:flutter/material.dart';

class TypingMissionView extends StatefulWidget {
  final String difficulty;
  final int totalQuotes;
  final VoidCallback onCompleted;

  const TypingMissionView({
    super.key,
    required this.difficulty,
    required this.totalQuotes,
    required this.onCompleted,
  });

  @override
  State<TypingMissionView> createState() => _TypingMissionViewState();
}

class _TypingMissionViewState extends State<TypingMissionView> {
  int _currentIndex = 1;
  late String _targetQuote;
  final TextEditingController _controller = TextEditingController();
  bool _hasError = false;

  final List<String> _quotes = [
    "Wake up with determination and go to bed with satisfaction.",
    "Discipline is choosing between what you want now and what you want most.",
    "Early to bed and early to rise makes a man healthy, wealthy, and wise.",
    "The only bad workout is the one that did not happen.",
    "I will not hit snooze. Today is my opportunity to build my future.",
    "Action is the foundational key to all success.",
    "Your future is created by what you do today, not tomorrow.",
    "Focus on being productive instead of busy.",
    "Small daily improvements over time lead to stunning results.",
    "Do something today that your future self will thank you for."
  ];

  @override
  void initState() {
    super.initState();
    _pickQuote();
  }

  void _pickQuote() {
    final rnd = Random();
    _targetQuote = _quotes[rnd.nextInt(_quotes.length)];
    _controller.clear();
    _hasError = false;
  }

  void _onSubmit() {
    if (_controller.text.trim().toLowerCase() == _targetQuote.trim().toLowerCase()) {
      if (_currentIndex >= widget.totalQuotes) {
        widget.onCompleted();
      } else {
        setState(() {
          _currentIndex++;
          _pickQuote();
        });
      }
    } else {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'QUOTE $_currentIndex of ${widget.totalQuotes}',
            style: const TextStyle(
              color: Colors.tealAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Quote Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'TYPE THE PHRASE EXACTLY:',
                  style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  _targetQuote,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hasError ? Colors.redAccent : Colors.white.withOpacity(0.2),
                width: _hasError ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Type exact quote here...',
                hintStyle: const TextStyle(color: Colors.white38),
                errorText: _hasError ? 'Does not match quote. Try again!' : null,
              ),
              onChanged: (_) {
                if (_hasError) {
                  setState(() => _hasError = false);
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _onSubmit,
              child: const Text(
                'SUBMIT QUOTE',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
