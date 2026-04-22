// lib/models/move_model.dart
class Move {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String category;
  final bool isFree;
  final double priceEur;
  final String? proPlayer;
  final String? videoUrl;
  final int xpReward;
  final String emoji;
  final List<dynamic> poseRules;
  bool isCompleted;
  int? bestScore;

  Move({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.category,
    required this.isFree,
    required this.priceEur,
    this.proPlayer,
    this.videoUrl,
    required this.xpReward,
    required this.emoji,
    required this.poseRules,
    this.isCompleted = false,
    this.bestScore,
  });

  factory Move.fromMap(Map<String, dynamic> m) => Move(
    id:         m['id'] as String,
    title:      m['title'] as String,
    description:m['description'] as String? ?? '',
    difficulty: m['difficulty'] as String,
    category:   m['category'] as String,
    isFree:     m['is_free'] as bool? ?? true,
    priceEur:   (m['price_eur'] as num?)?.toDouble() ?? 0.0,
    proPlayer:  m['pro_player'] as String?,
    videoUrl:   m['video_url'] as String?,
    xpReward:   m['xp_reward'] as int? ?? 100,
    emoji:      m['emoji'] as String? ?? '?',
    poseRules:  m['pose_rules'] as List<dynamic>? ?? [],
  );

  bool get isPro => !isFree;
}

// lib/models/program_model.dart
class Program {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final int durationWeeks;
  final int sessionsPerWeek;
  final bool isFree;
  final double priceEur;
  final String? proPlayer;
  final String emoji;
  final String category;
  bool isEnrolled;
  int currentWeek;
  int currentDay;

  Program({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.durationWeeks,
    required this.sessionsPerWeek,
    required this.isFree,
    required this.priceEur,
    this.proPlayer,
    required this.emoji,
    required this.category,
    this.isEnrolled = false,
    this.currentWeek = 1,
    this.currentDay = 1,
  });

  factory Program.fromMap(Map<String, dynamic> m) => Program(
    id:              m['id'] as String,
    title:           m['title'] as String,
    description:     m['description'] as String? ?? '',
    difficulty:      m['difficulty'] as String,
    durationWeeks:   m['duration_weeks'] as int? ?? 4,
    sessionsPerWeek: m['sessions_week'] as int? ?? 3,
    isFree:          m['is_free'] as bool? ?? true,
    priceEur:        (m['price_eur'] as num?)?.toDouble() ?? 0.0,
    proPlayer:       m['pro_player'] as String?,
    emoji:           m['emoji'] as String? ?? '?',
    category:        m['category'] as String? ?? 'General',
  );

  bool get isPro => !isFree;
  int get totalSessions => durationWeeks * sessionsPerWeek;
}

// lib/models/duel_model.dart
class Duel {
  final String id;
  final String player1Id;
  final String? player2Id;
  final bool isBot;
  final int botLevel;
  final String status;
  final String skillType;
  final int player1Score;
  final int player2Score;
  final String? winnerId;
  final int xpReward;
  final DateTime createdAt;

  const Duel({
    required this.id,
    required this.player1Id,
    this.player2Id,
    required this.isBot,
    required this.botLevel,
    required this.status,
    required this.skillType,
    required this.player1Score,
    required this.player2Score,
    this.winnerId,
    required this.xpReward,
    required this.createdAt,
  });

  factory Duel.fromMap(Map<String, dynamic> m) => Duel(
    id:            m['id'] as String,
    player1Id:     m['player1_id'] as String,
    player2Id:     m['player2_id'] as String?,
    isBot:         m['is_bot'] as bool? ?? false,
    botLevel:      m['bot_level'] as int? ?? 1,
    status:        m['status'] as String? ?? 'waiting',
    skillType:     m['skill_type'] as String? ?? 'Tir',
    player1Score:  m['player1_score'] as int? ?? 0,
    player2Score:  m['player2_score'] as int? ?? 0,
    winnerId:      m['winner_id'] as String?,
    xpReward:      m['xp_reward'] as int? ?? 150,
    createdAt:     DateTime.parse(m['created_at'] as String),
  );

  bool get isFinished => status == 'finished';
  bool get isActive   => status == 'active';
  bool get isWaiting  => status == 'waiting';
}
