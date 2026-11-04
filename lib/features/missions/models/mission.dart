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
        return 'Math';
      case 'shake':
        return 'Shake';
      case 'typing':
        return 'Typing';
      case 'memory':
        return 'Memory';
      case 'step':
        return 'Steps';
      case 'none':
      default:
        return 'None';
    }
  }

  String get description {
    switch (type) {
      case 'math':
        return '$count problems ($difficulty)';
      case 'shake':
        return '$count shakes';
      case 'typing':
        return '$count phrases ($difficulty)';
      case 'memory':
        return '$count rounds ($difficulty)';
      case 'step':
        return '$count steps';
      case 'none':
      default:
        return 'Tap to stop';
    }
  }
}
