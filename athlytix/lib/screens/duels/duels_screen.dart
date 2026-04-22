import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/duel_model.dart';
import '../../models/user_model.dart';
import '../../services/duel_service.dart';
import '../../widgets/shimmer_card.dart';
import 'duel_battle_screen.dart';

class DuelsScreen extends StatefulWidget {
  final UserProfile? profile;
  final Function(UserProfile) onUpdate;

  const DuelsScreen({super.key, required this.profile, required this.onUpdate});

  @override
  State<DuelsScreen> createState() => _DuelsScreenState();
}

class _DuelsScreenState extends State<DuelsScreen> {
  List<Duel> _recentDuels = [];
  bool _loading = true;
  bool _matchmaking = false;
  String _selectedSkill = 'Tir';
  int _botLevel = 3;

  final _skills = ['Tir', 'Dribble', 'Defense', 'Drive', 'Mixed'];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final duels = await DuelService.getRecentDuels();
      if (mounted) setState(() => _recentDuels = duels);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startDuel({required bool vsBot}) async {
    if (widget.profile == null) return;
    HapticFeedback.mediumImpact();
    setState(() => _matchmaking = true);

    try {
      final duel = await DuelService.findOrCreateDuel(
        vsBot: vsBot,
        botLevel: _botLevel,
        skillType: _selectedSkill,
      );
      if (duel == null || !mounted) return;

      Navigator.push(context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => DuelBattleScreen(
            duel: duel,
            profile: widget.profile!,
            onUpdate: widget.onUpdate,
            onFinish: _loadHistory,
          ),
          transitionsBuilder: (_, a, __, c) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: c),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } finally {
      if (mounted) setState(() => _matchmaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 24),
            _header(),
            const SizedBox(height: 20),
            _statsRow(),
            const SizedBox(height: 24),
            _skillSelector(),
            const SizedBox(height: 20),
            _modeCards(),
            const SizedBox(height: 24),
            _historySection(),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _header() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Duels', style: AppTextStyles.heading2),
    const SizedBox(height: 4),
    Text('Affronte des joueurs réels ou des robots.', style: AppTextStyles.body),
  ]);

  Widget _statsRow() => Row(children: [
    _statTile('⚔️', '${widget.profile?.duelsWon ?? 0}', 'Victoires', AppColors.success),
    const SizedBox(width: 10),
    _statTile('🎮', '${widget.profile?.duelsPlayed ?? 0}', 'Joués', AppColors.primary),
    const SizedBox(width: 10),
    _statTile('🏆', _winRate(), 'Win Rate', AppColors.warning),
  ]);

  String _winRate() {
    final p = widget.profile;
    if (p == null || p.duelsPlayed == 0) return '0%';
    return '${(p.duelsWon / p.duelsPlayed * 100).round()}%';
  }

  Widget _statTile(String emoji, String value, String label, Color color) =>
    Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(
          color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label, style: AppTextStyles.caption),
      ]),
    ));

  Widget _skillSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('COMPÉTENCE', style: AppTextStyles.label),
      const SizedBox(height: 10),
      SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _skills.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final s = _skills[i];
            final sel = _selectedSkill == s;
            return GestureDetector(
              onTap: () => setState(() => _selectedSkill = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: sel ? AppColors.orangeGradient : null,
                  color: sel ? null : AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? Colors.transparent : AppColors.border)),
                child: Text(s, style: TextStyle(
                  color: sel ? Colors.white : AppColors.textSecondary,
                  fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            );
          },
        ),
      ),
    ],
  );

  Widget _modeCards() => Row(children: [
    Expanded(child: _modeCard(
      icon: '👥',
      title: 'Joueur\nRéel',
      subtitle: 'Matchmaking\nen ligne',
      gradient: AppColors.orangeGradient,
      onTap: () => _startDuel(vsBot: false),
    )),
    const SizedBox(width: 12),
    Expanded(child: _botCard()),
  ]);

  Widget _modeCard({
    required String icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _matchmaking ? null : onTap,
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16, offset: const Offset(0, 6))]),
        child: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.inter(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800,
              height: 1.2)),
            Text(subtitle, style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.7), fontSize: 11, height: 1.3)),
          ]),
          if (_matchmaking)
            const Positioned.fill(child: Center(
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
        ]),
      ),
    );
  }

  Widget _botCard() {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🤖', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 8),
          Text('Robot IA', style: GoogleFonts.inter(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 8),
        // Bot level slider
        Row(children: [
          Text('Niv. $_botLevel', style: TextStyle(
            color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w700)),
          Expanded(child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.accent,
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: _botLevel.toDouble(),
              min: 1, max: 5, divisions: 4,
              onChanged: (v) => setState(() => _botLevel = v.round()),
            ),
          )),
        ]),
        SizedBox(
          width: double.infinity, height: 32,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.blueGradient,
              borderRadius: BorderRadius.circular(10)),
            child: ElevatedButton(
              onPressed: _matchmaking ? null : () => _startDuel(vsBot: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
              child: Text(_matchmaking ? '…' : 'Jouer',
                style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _historySection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Historique', style: AppTextStyles.heading3),
      const SizedBox(height: 12),
      if (_loading)
        ...List.generate(3, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ShimmerCard(height: 64, radius: 14)))
      else if (_recentDuels.isEmpty)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border)),
          child: Center(child: Text('Aucun duel joué.', style: AppTextStyles.body)))
      else
        ..._recentDuels.map(_duelHistoryTile),
    ],
  );

  Widget _duelHistoryTile(Duel d) {
    final myId = supabase.auth.currentUser?.id;
    final won = d.winnerId == myId;
    final myScore = d.player1Id == myId ? d.player1Score : d.player2Score;
    final oppScore= d.player1Id == myId ? d.player2Score : d.player1Score;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: won ? AppColors.success.withOpacity(0.15)
                       : Colors.red.withOpacity(0.15),
            shape: BoxShape.circle),
          child: Center(child: Text(won ? '🏆' : '💀',
            style: const TextStyle(fontSize: 18)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.isBot ? '🤖 Robot Niv.${d.botLevel}' : 'Joueur en ligne',
            style: const TextStyle(color: Colors.white, fontSize: 13,
              fontWeight: FontWeight.w700)),
          Text('${d.skillType} · $myScore pts vs $oppScore pts',
            style: AppTextStyles.body.copyWith(fontSize: 11)),
        ])),
        Text(won ? '+${d.xpReward} XP' : '+50 XP',
          style: TextStyle(
            color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}
