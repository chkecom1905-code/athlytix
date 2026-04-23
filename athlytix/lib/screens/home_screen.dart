import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../services/xp_service.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile? profile;
  final Function(UserProfile) onUpdate;

  const HomeScreen({super.key, required this.profile, required this.onUpdate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final count = await XpService.getCompletedCount();
    if (mounted) setState(() => _completedCount = count);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _topBar(p),
              const SizedBox(height: 24),
              _xpCard(p),
              const SizedBox(height: 20),
              _statsRow(p),
              const SizedBox(height: 24),
              _sectionTitle('Activité rapide'),
              const SizedBox(height: 12),
              _quickActions(),
              const SizedBox(height: 24),
              _sectionTitle('Conseil du jour'),
              const SizedBox(height: 12),
              _motivationCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(UserProfile? p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Salut, ${p?.username ?? "Athlète"} 👋',
              style: AppTextStyles.heading2),
            const SizedBox(height: 4),
            Text('Continue ta progression !', style: AppTextStyles.body),
          ],
        ),
        Stack(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                  color: AppColors.primary.withOpacity(0.3), blurRadius: 12)],
              ),
              child: const Center(
                child: Text('🏀', style: TextStyle(fontSize: 22))),
            ),
            if ((p?.streak ?? 0) > 0)
              Positioned(
                top: -2, right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9F00),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${p!.streak}🔥',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                      color: Colors.white)),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _xpCard(UserProfile? p) {
    final xp    = p?.xp ?? 0;
    final level = p?.level ?? 1;
    final prog  = p?.xpProgress ?? 0.0;
    final next  = p?.xpForNextLevel ?? 500;
    final cur   = p?.xpProgress ?? 0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.orangeGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(
          color: AppColors.primary.withOpacity(0.35),
          blurRadius: 24, offset: const Offset(0, 10),
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('NIVEAU $level',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.8)),
                const SizedBox(height: 4),
                Text('$xp XP',
                  style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900,
                    letterSpacing: -1)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: [
                  Text('${p?.streak ?? 0}',
                    style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  Text('🔥 jours', style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8), fontSize: 10)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progrès niveau ${level + 1}',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.75), fontSize: 12)),
              Text('$cur / $next XP',
                style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: prog.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.2),
            progressColor: Colors.white,
            barRadius: const Radius.circular(8),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _statsRow(UserProfile? p) {
    return Row(children: [
      _statCard('Workouts', '$_completedCount', '✅', AppColors.success),
      const SizedBox(width: 10),
      _statCard('Niveau',   '${p?.level ?? 1}', '⭐', AppColors.warning),
      const SizedBox(width: 10),
      _statCard('Statut',
        p?.isPremium == true ? 'PRO' : 'FREE',
        '💎', AppColors.secondary),
    ]);
  }

  Widget _statCard(String title, String value, String emoji, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.inter(
            color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(title, style: AppTextStyles.caption, textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String t) =>
    Text(t, style: AppTextStyles.heading3);

  Widget _quickActions() {
    return Row(children: [
      _action('Workout\ndu jour', '🏋️', AppColors.orangeGradient),
      const SizedBox(width: 12),
      _action('Défi\nhebdo', '🏆', AppColors.purpleGradient),
    ]);
  }

  Widget _action(String label, String emoji, LinearGradient g) {
    return Expanded(
      child: Container(
        height: 86,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: g, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: GoogleFonts.inter(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, height: 1.3))),
        ]),
      ),
    );
  }

  Widget _motivationCard() {
    const quotes = [
      '"Hard work beats talent when talent doesn\'t work hard."',
      '"Champions are made in the off-season."',
      '"Be so good they can\'t ignore you."',
      '"Push yourself, because no one else is going to do it for you."',
    ];
    final q = quotes[DateTime.now().day % quotes.length];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGlow, borderRadius: BorderRadius.circular(6)),
            child: Text('💬 MOTIVATION',
              style: AppTextStyles.label.copyWith(color: AppColors.primary)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(q, style: GoogleFonts.inter(
          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic, height: 1.6)),
      ]),
    );
  }
}
