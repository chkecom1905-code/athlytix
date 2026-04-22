import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/duel_model.dart';
import '../../models/user_model.dart';
import '../../services/duel_service.dart';
import '../../widgets/levelup_dialog.dart';

class DuelBattleScreen extends StatefulWidget {
  final Duel duel;
  final UserProfile profile;
  final Function(UserProfile) onUpdate;
  final VoidCallback onFinish;

  const DuelBattleScreen({
    super.key,
    required this.duel,
    required this.profile,
    required this.onUpdate,
    required this.onFinish,
  });

  @override
  State<DuelBattleScreen> createState() => _DuelBattleScreenState();
}

class _DuelBattleScreenState extends State<DuelBattleScreen>
    with TickerProviderStateMixin {
  // Round state
  int _round       = 1;
  int _maxRounds   = 5;
  int _myScore     = 0;
  int _oppScore    = 0;
  int _timeLeft    = 15;
  bool _roundActive= false;
  bool _finished   = false;
  bool _waitingForOpp = false;

  // Current question/challenge
  late _SkillChallenge _challenge;
  int? _selectedAnswer;
  bool? _wasCorrect;

  Timer? _roundTimer;
  Timer? _botTimer;
  late AnimationController _pulseCtrl;
  late AnimationController _resultCtrl;
  late Animation<double> _resultAnim;

  // Realtime
  Duel? _liveDuel;

  @override
  void initState() {
    super.initState();
    _liveDuel = widget.duel;

    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _resultCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
    _resultAnim = CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOut);

    _challenge = _SkillChallenge.forType(widget.duel.skillType, _round);

    // Listen for real-time updates (vs real player)
    if (!widget.duel.isBot) {
      DuelService.listenToDuel(widget.duel.id, (d) {
        if (mounted) setState(() => _liveDuel = d);
      });
    }

    // Start first round after brief delay
    Future.delayed(const Duration(milliseconds: 600), _startRound);
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    _botTimer?.cancel();
    _pulseCtrl.dispose();
    _resultCtrl.dispose();
    DuelService.stopListening();
    super.dispose();
  }

  void _startRound() {
    if (!mounted) return;
    setState(() {
      _roundActive  = true;
      _timeLeft     = 15;
      _selectedAnswer = null;
      _wasCorrect   = null;
      _challenge    = _SkillChallenge.forType(widget.duel.skillType, _round);
    });
    _resultCtrl.reset();

    _roundTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        _endRound(answered: false);
      }
    });

    // Bot answers in random time
    if (widget.duel.isBot) {
      final delay = 2 + Random().nextInt(8);
      _botTimer = Timer(Duration(seconds: delay), _botAnswer);
    }
  }

  void _botAnswer() {
    if (!_roundActive || _finished) return;
    // Bot success rate based on level
    final chance = 0.4 + (widget.duel.botLevel * 0.1);
    final botWins = Random().nextDouble() < chance;
    if (botWins && mounted) {
      final pts = 15 + Random().nextInt(11);
      setState(() => _oppScore += pts);
      HapticFeedback.lightImpact();
    }
  }

  void _selectAnswer(int index) {
    if (!_roundActive || _selectedAnswer != null) return;
    HapticFeedback.lightImpact();

    _roundTimer?.cancel();
    _botTimer?.cancel();

    final correct = index == _challenge.correctIndex;
    final pts = correct ? (5 + _timeLeft * 2) : 0;

    setState(() {
      _selectedAnswer = index;
      _wasCorrect     = correct;
      _myScore       += pts;
      _roundActive    = false;
    });

    _resultCtrl.forward();
    DuelService.submitScore(widget.duel.id, _myScore, widget.duel.player1Id == widget.profile.id);

    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 1800), _nextRound);
  }

  void _nextRound() {
    if (!mounted) return;
    if (_round >= _maxRounds) {
      _endGame();
    } else {
      setState(() { _round++; });
      _startRound();
    }
  }

  void _endRound({required bool answered}) {
    if (!mounted) return;
    setState(() { _roundActive = false; });
    _resultCtrl.forward();
    Future.delayed(const Duration(milliseconds: 1500), _nextRound);
  }

  Future<void> _endGame() async {
    if (_finished) return;
    setState(() => _finished = true);
    _roundTimer?.cancel();

    final oldLevel = widget.profile.level;
    final result = await DuelService.finishDuel(widget.duel.id, widget.profile);
    if (result == null || !mounted) return;

    final myId  = supabase.auth.currentUser?.id;
    final won   = result.winnerId == myId;
    final updated = await DuelService.getRecentDuels();

    widget.onFinish();

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        won: won,
        myScore: _myScore,
        oppScore: _oppScore,
        xpEarned: won ? result.xpReward : 50,
        isBot: result.isBot,
      ),
    );

    if (mounted) Navigator.pop(context);

    // Level-up check
    final refreshed = await _refreshProfile();
    if (refreshed != null && refreshed.level > oldLevel && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => LevelUpDialog(newLevel: refreshed.level, xp: refreshed.xp));
    }
  }

  Future<UserProfile?> _refreshProfile() async {
    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', widget.profile.id)
          .single();
      final p = UserProfile.fromMap(data);
      widget.onUpdate(p);
      return p;
    } catch (_) { return null; }
  }

  void _endRoundTimeout() => _endRound(answered: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _topBar(context),
          _scoreBanner(),
          _progressBar(),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _finished
                  ? const Center(child: CircularProgressIndicator(
                      color: AppColors.primary))
                  : Column(children: [
                      _questionCard(),
                      const SizedBox(height: 16),
                      ..._challenge.options.asMap().entries.map(
                        (e) => _answerTile(e.key, e.value)),
                    ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 24)),
          Text('Duel ${widget.duel.skillType}', style: AppTextStyles.heading3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _timeLeft <= 5
                  ? Colors.red.withOpacity(0.2)
                  : AppColors.primaryGlow,
              borderRadius: BorderRadius.circular(10)),
            child: Text('$_timeLeft s', style: TextStyle(
              color: _timeLeft <= 5 ? Colors.red : AppColors.primary,
              fontWeight: FontWeight.w800, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _scoreBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0A05), Color(0xFF0A0A1A)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border)),
      child: Row(children: [
        // Me
        Expanded(child: Column(children: [
          Text(widget.profile.username,
            style: const TextStyle(color: Colors.white, fontSize: 12,
              fontWeight: FontWeight.w700)),
          Text('$_myScore',
            style: GoogleFonts.inter(color: AppColors.primary, fontSize: 28,
              fontWeight: FontWeight.w900)),
        ])),
        // VS
        Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient, borderRadius: BorderRadius.circular(8)),
            child: Text('VS', style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12))),
          const SizedBox(height: 4),
          Text('Round $_round/$_maxRounds', style: AppTextStyles.caption),
        ]),
        // Opponent
        Expanded(child: Column(children: [
          Text(widget.duel.isBot
            ? '🤖 Robot Niv.${widget.duel.botLevel}'
            : 'Adversaire',
            style: const TextStyle(color: Colors.white, fontSize: 12,
              fontWeight: FontWeight.w700)),
          Text('$_oppScore',
            style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 28,
              fontWeight: FontWeight.w900)),
        ])),
      ]),
    );
  }

  Widget _progressBar() {
    final prog = (_maxRounds - _timeLeft) / _maxRounds;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: (_round - 1) / _maxRounds,
          backgroundColor: AppColors.border,
          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          minHeight: 4,
        ),
      ),
    );
  }

  Widget _questionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Text(_challenge.category, style: AppTextStyles.label),
        const SizedBox(height: 10),
        Text(_challenge.question,
          style: AppTextStyles.heading3.copyWith(height: 1.4),
          textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _answerTile(int index, String option) {
    Color? bg; Color? borderC; Color? textC = Colors.white;

    if (_selectedAnswer != null) {
      if (index == _challenge.correctIndex) {
        bg = AppColors.success.withOpacity(0.15);
        borderC = AppColors.success;
        textC = AppColors.success;
      } else if (index == _selectedAnswer) {
        bg = Colors.red.withOpacity(0.12);
        borderC = Colors.red;
        textC = Colors.red;
      } else {
        bg = AppColors.card;
        borderC = AppColors.border;
        textC = AppColors.textMuted;
      }
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg ?? AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderC ?? AppColors.border)),
        child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: (borderC ?? AppColors.primary).withOpacity(0.15),
              shape: BoxShape.circle),
            child: Center(child: Text(
              String.fromCharCode(65 + index),
              style: TextStyle(color: borderC ?? AppColors.primary,
                fontSize: 12, fontWeight: FontWeight.w800)))),
          const SizedBox(width: 12),
          Expanded(child: Text(option, style: TextStyle(
            color: textC, fontSize: 14, fontWeight: FontWeight.w600))),
          if (_selectedAnswer != null && index == _challenge.correctIndex)
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
        ]),
      ),
    );
  }
}

// ── Skill challenge generator ─────────────────────────────
class _SkillChallenge {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String category;

  const _SkillChallenge({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.category,
  });

  static _SkillChallenge forType(String type, int round) {
    final pools = <String, List<_SkillChallenge>>{
      'Tir': [
        _SkillChallenge(question: 'Quel angle de lâcher est idéal pour un tir à 3 pts ?',
          options: ['30°','45°','55°','70°'], correctIndex: 1, category: 'Technique de tir'),
        _SkillChallenge(question: 'Que fait le follow-through ?',
          options: ['Accélère la balle','Donne le bon spin','Améliore la visée','Réduit la fatigue'],
          correctIndex: 1, category: 'Technique de tir'),
        _SkillChallenge(question: 'Quelle est la hauteur idéale du coude en tir ?',
          options: ['En-dessous de la hanche','Aligné avec l\'épaule','Au-dessus de la tête','Au niveau des yeux'],
          correctIndex: 1, category: 'Biomécanique'),
        _SkillChallenge(question: 'Pour un pull-up jumper, on génère la puissance depuis…',
          options: ['Les bras','Les poignets','Les jambes et les hanches','Les épaules'],
          correctIndex: 2, category: 'Biomécanique'),
        _SkillChallenge(question: 'Quelle partie du filet faut-il viser ?',
          options: ['Le bord avant','Le centre','Le bord arrière','L\'anneau'],
          correctIndex: 1, category: 'Visée'),
      ],
      'Dribble': [
        _SkillChallenge(question: 'À quelle hauteur doit rebondir le dribble bas ?',
          options: ['Genou','Cheville','Mi-mollet','Mi-cuisse'], correctIndex: 1, category: 'Fondamentaux'),
        _SkillChallenge(question: 'Pendant un crossover, où doit être la tête ?',
          options: ['Baissée sur la balle','Levée vers le défenseur','De côté','Centrée'],
          correctIndex: 1, category: 'Fondamentaux'),
        _SkillChallenge(question: 'Le spin move sert principalement à…',
          options: ['Accélérer','Contourner un défenseur','Changer de rythme','Protéger la balle'],
          correctIndex: 1, category: 'Moves'),
        _SkillChallenge(question: 'Pour un behind-the-back, la balle passe…',
          options: ['Devant les hanches','Dans le dos','Entre les jambes','Par-dessus la tête'],
          correctIndex: 1, category: 'Moves'),
        _SkillChallenge(question: 'L\'hesitation dribble sert à…',
          options: ['Accélérer','Reculer','Créer un décalage rythmique','Protéger la balle'],
          correctIndex: 2, category: 'Stratégie'),
      ],
      'Defense': [
        _SkillChallenge(question: 'La posture défensive idéale est…',
          options: ['Jambes droites','Genoux fléchis, dos droit','Courbé en avant','Pieds serrés'],
          correctIndex: 1, category: 'Fondamentaux'),
        _SkillChallenge(question: 'Un close-out se termine comment ?',
          options: ['En sautant','Main haute, pas courts','En bloquant','Debout bras tendus'],
          correctIndex: 1, category: 'Technique'),
        _SkillChallenge(question: 'Le defensive slide, c\'est…',
          options: ['Courir normalement','Glisser sans croiser les pieds','Sauter latéralement','Pivoter'],
          correctIndex: 1, category: 'Mouvement'),
        _SkillChallenge(question: 'Pour contester un tir sans fauter, on utilise…',
          options: ['Les deux mains','La main intérieure','La main extérieure','Le corps'],
          correctIndex: 2, category: 'Contestation'),
        _SkillChallenge(question: 'Un bon help défense se positionne…',
          options: ['Derrière son joueur','Dans la peinture','Entre la balle et son joueur','Sur la ligne des 3 pts'],
          correctIndex: 2, category: 'Stratégie'),
      ],
    };

    final list = pools[type] ?? pools['Tir']!;
    return list[(round - 1) % list.length];
  }
}

// ── Result dialog ─────────────────────────────────────────
class _ResultDialog extends StatelessWidget {
  final bool won;
  final int myScore, oppScore, xpEarned;
  final bool isBot;

  const _ResultDialog({
    required this.won,
    required this.myScore,
    required this.oppScore,
    required this.xpEarned,
    required this.isBot,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(won ? '🏆' : '💀', style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 14),
          Text(won ? 'Victoire !' : 'Défaite',
            style: GoogleFonts.inter(
              color: won ? AppColors.success : Colors.red,
              fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text('$myScore — $oppScore',
            style: AppTextStyles.heading2, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryGlow, borderRadius: BorderRadius.circular(12)),
            child: Text('+$xpEarned XP',
              style: TextStyle(color: AppColors.primary,
                fontSize: 18, fontWeight: FontWeight.w800))),
          const SizedBox(height: 22),
          SizedBox(width: double.infinity, height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(14)),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
                child: Text('Continuer', style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            )),
        ]),
      ),
    );
  }
}
