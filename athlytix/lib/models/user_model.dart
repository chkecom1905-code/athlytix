class UserProfile {
  final String id;
  final String email;
  final String username;
  final int xp;
  final int level;
  final int streak;
  final bool isPremium;
  final int duelsWon;
  final int duelsPlayed;
  final int aiTokens;           // Coach IA tokens
  final int duelPoints;         // Points échangeables boutique
  final List<String> movesUnlocked;
  final List<String> programsEnrolled;
  final List<String> rewardsUnlocked;
  final String language;        // code langue: 'fr', 'en'...

  const UserProfile({
    required this.id,
    required this.email,
    required this.username,
    required this.xp,
    required this.level,
    required this.streak,
    required this.isPremium,
    required this.duelsWon,
    required this.duelsPlayed,
    this.aiTokens = 10,
    this.duelPoints = 0,
    required this.movesUnlocked,
    required this.programsEnrolled,
    this.rewardsUnlocked = const [],
    this.language = 'fr',
  });

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    id:               m['id'] as String,
    email:            m['email'] as String? ?? '',
    username:         m['username'] as String? ?? 'Joueur',
    xp:               m['xp'] as int? ?? 0,
    level:            m['level'] as int? ?? 1,
    streak:           m['streak'] as int? ?? 0,
    isPremium:        m['is_premium'] as bool? ?? false,
    duelsWon:         m['duels_won'] as int? ?? 0,
    duelsPlayed:      m['duels_played'] as int? ?? 0,
    aiTokens:         m['ai_tokens'] as int? ?? 10,
    duelPoints:       m['duel_points'] as int? ?? 0,
    movesUnlocked:    List<String>.from(m['moves_unlocked'] as List? ?? []),
    programsEnrolled: List<String>.from(m['programs_enrolled'] as List? ?? []),
    rewardsUnlocked:  List<String>.from(m['rewards_unlocked'] as List? ?? []),
    language:         m['language'] as String? ?? 'fr',
  );

  UserProfile copyWith({
    int? xp, int? level, int? streak, bool? isPremium,
    int? duelsWon, int? duelsPlayed, int? aiTokens, int? duelPoints,
    List<String>? movesUnlocked, List<String>? programsEnrolled,
    List<String>? rewardsUnlocked,
  }) => UserProfile(
    id: id, email: email, username: username,
    xp:               xp               ?? this.xp,
    level:            level            ?? this.level,
    streak:           streak           ?? this.streak,
    isPremium:        isPremium        ?? this.isPremium,
    duelsWon:         duelsWon         ?? this.duelsWon,
    duelsPlayed:      duelsPlayed      ?? this.duelsPlayed,
    aiTokens:         aiTokens         ?? this.aiTokens,
    duelPoints:       duelPoints       ?? this.duelPoints,
    movesUnlocked:    movesUnlocked    ?? this.movesUnlocked,
    programsEnrolled: programsEnrolled ?? this.programsEnrolled,
    rewardsUnlocked:  rewardsUnlocked  ?? this.rewardsUnlocked,
  );

  int    get xpForNextLevel => level * 500;
  double get xpProgress     => (xp % 500) / 500.0;
  bool   get hasTokens      => aiTokens > 0;

  String get levelTitle {
    if (level >= 20) return 'Légende';
    if (level >= 15) return 'Élite';
    if (level >= 10) return 'Pro';
    if (level >= 5)  return 'Confirmé';
    return 'Rookie';
  }

  String get tokenLabel {
    if (aiTokens == 0) return 'Aucun token';
    if (aiTokens == 1) return '1 token';
    return '$aiTokens tokens';
  }
}
