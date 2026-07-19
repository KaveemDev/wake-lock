class MissionConfig {
  final String type; // 'math', 'shake', 'typing', 'memory', 'step', 'none'
  final String difficulty; // 'easy', 'medium', 'hard'
  final int count;

  const MissionConfig({
    required this.type,
    required this.difficulty,
    required this.count,
  });

  String get displayName {
    switch (type) {
      case 'math':
        return 'Math Problems';
      case 'shake':
        return 'Shake Phone';
      case 'typing':
        return 'Quote Typing';
      case 'memory':
        return 'Memory Grid';
      case 'step':
        return 'Step Walker';
      case 'none':
      default:
        return 'Standard (No Mission)';
    }
  }

  String get description {
    switch (type) {
      case 'math':
        return '$count problems ($difficulty)';
      case 'shake':
        return '$count shakes vigorously';
      case 'typing':
        return '$count quotes ($difficulty)';
      case 'memory':
        return '$count sequence rounds ($difficulty)';
      case 'step':
        return '$count steps away from bed';
      case 'none':
      default:
        return 'Tap Stop button directly';
    }
  }
}
