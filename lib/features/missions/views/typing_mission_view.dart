import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/ui/app_ui.dart';

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
  int _errorCount = 0;

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
    "Do something today that your future self will thank you for.",
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
    if (_controller.text.trim().toLowerCase() ==
        _targetQuote.trim().toLowerCase()) {
      if (_currentIndex >= widget.totalQuotes) {
        widget.onCompleted();
      } else {
        setState(() {
          _currentIndex++;
          _pickQuote();
        });
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _hasError = true;
        _errorCount++;
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
            'Phrase $_currentIndex of ${widget.totalQuotes}',
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
                end: (_currentIndex - 1) / widget.totalQuotes,
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
          const SizedBox(height: 20),

          // Quote Card
          AppCard(
            key: ValueKey(_targetQuote),
            padding: const EdgeInsets.all(24),
            borderColor: AppColors.accent.withValues(alpha: 0.3),
            child: Column(
              children: [
                Text(
                  'Type this exactly',
                  style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _targetQuote,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Input Field
          ShakeOnChange(
            trigger: _errorCount,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _hasError
                      ? AppColors.danger
                      : AppColors.border,
                  width: _hasError ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: AppColors.text, fontSize: 16),
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Your text',
                  hintStyle: TextStyle(color: AppColors.textFaint),
                  errorText: _hasError
                      ? 'That doesn\'t match yet.'
                      : null,
                ),
                onChanged: (_) {
                  if (_hasError) {
                    setState(() => _hasError = false);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          GradientButton(
            label: 'Check',
            icon: Icons.check_rounded,
            onPressed: _onSubmit,
          ),
        ],
      ),
    );
  }
}
