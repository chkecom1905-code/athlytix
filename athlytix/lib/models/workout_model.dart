// lib/models/workout_model.dart
class Workout {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String type;
  final int durationMin;
  final int xpReward;
  final String emoji;
  bool isCompleted;

  Workout({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.type,
    required this.durationMin,
    required this.xpReward,
    required this.emoji,
    this.isCompleted = false,
  });

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id:          map['id'] as String,
      title:       map['title'] as String,
      description: map['description'] as String? ?? '',
      difficulty:  map['difficulty'] as String,
      type:        map['type'] as String,
      durationMin: map['duration_min'] as int? ?? 30,
      xpReward:    map['xp_reward'] as int? ?? 50,
      emoji:       map['emoji'] as String? ?? '🏀',
    );
  }
}

// lib/models/challenge_model.dart
class Challenge {
  final String id;
  final String title;
  final String description;
  final String objective;
  final int xpReward;
  final String difficulty;
  final String emoji;
  final DateTime? deadline;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.objective,
    required this.xpReward,
    required this.difficulty,
    required this.emoji,
    this.deadline,
  });

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id:          map['id'] as String,
      title:       map['title'] as String,
      description: map['description'] as String? ?? '',
      objective:   map['objective'] as String,
      xpReward:    map['xp_reward'] as int? ?? 100,
      difficulty:  map['difficulty'] as String,
      emoji:       map['emoji'] as String? ?? '🏆',
      deadline:    map['deadline'] != null
                     ? DateTime.tryParse(map['deadline'])
                     : null,
    );
  }

  int get daysLeft {
    if (deadline == null) return -1;
    return deadline!.difference(DateTime.now()).inDays;
  }
}
