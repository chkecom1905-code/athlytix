import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/move_model.dart';
import '../../models/user_model.dart';

class ProgramDetailScreen extends StatelessWidget {
  final Program program;
  final UserProfile? profile;
  final Function(UserProfile) onUpdate;

  const ProgramDetailScreen({
    super.key,
    required this.program,
    required this.profile,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _appBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _chips(),
                  const SizedBox(height: 14),
                  Text(program.title, style: AppTextStyles.heading1),
                  if (program.proPlayer != null) ...[
                    const SizedBox(height: 8),
                    _proBadge(),
                  ],
                  const SizedBox(height: 12),
                  Text(program.description.isNotEmpty
                    ? program.description
                    : 'Un programme structuré pour progresser rapidement et durablement.',
                    style: AppTextStyles.body),
                  const SizedBox(height: 20),
                  _statsGrid(),
                  const SizedBox(height: 24),
                  _weeklyPlan(),
                  const SizedBox(height: 24),
                  _cta(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black38, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                program.isPro
                    ? AppColors.secondary.withOpacity(0.6)
                    : AppColors.primary.withOpacity(0.6),
                AppColors.background,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 20),
              Text(program.emoji.isNotEmpty ? program.emoji : '📋',
                style: const TextStyle(fontSize: 72)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _chips() => Row(children: [
    _chip(program.category, AppColors.accent),
    const SizedBox(width: 8),
    _chip(program.difficulty, _diffColor()),
    if (program.isFree) ...[const SizedBox(width: 8), _chip('🆓 Gratuit', AppColors.success)],
  ]);

  Widget _proBadge() => Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient, borderRadius: BorderRadius.circular(10)),
      child: Text('👑 Programme de ${program.proPlayer}',
        style: const TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
  ]);

  Widget _statsGrid() => Row(children: [
    _statCard('⏱️', '${program.durationWeeks} sem.', 'Durée'),
    const SizedBox(width: 10),
    _statCard('🔁', '${program.sessionsPerWeek}x/sem', 'Fréquence'),
    const SizedBox(width: 10),
    _statCard('💪', '${program.totalSessions}', 'Sessions'),
  ]);

  Widget _statCard(String emoji, String value, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.inter(
          color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w800)),
        Text(label, style: AppTextStyles.caption),
      ]),
    ),
  );

  Widget _weeklyPlan() {
    final weeks = List.generate(
      program.durationWeeks.clamp(1, 4),
      (i) => _weekPlan(i + 1),
    );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Plan hebdomadaire', style: AppTextStyles.heading3),
      const SizedBox(height: 14),
      ...weeks,
    ]);
  }

  Widget _weekPlan(int week) {
    final days = List.generate(program.sessionsPerWeek, (i) => i + 1);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient, borderRadius: BorderRadius.circular(8)),
            child: Text('Semaine $week', style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
          const SizedBox(width: 10),
          Text(_weekTitle(week, program.category), style: AppTextStyles.body),
        ]),
        const SizedBox(height: 12),
        ...days.map((d) => _dayTile(week, d)),
      ]),
    );
  }

  Widget _dayTile(int week, int day) {
    final sessions = _sessionContent(week, day, program.category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: AppColors.primaryGlow, shape: BoxShape.circle),
          child: Center(child: Text('J$day', style: TextStyle(
            color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(sessions['title']!, style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(sessions['desc']!, style: AppTextStyles.body.copyWith(fontSize: 11)),
        ])),
      ]),
    );
  }

  Widget _cta(BuildContext context) {
    if (program.isPro) {
      return Column(children: [
        SizedBox(width: double.infinity, height: 58,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(
                color: AppColors.secondary.withOpacity(0.4),
                blurRadius: 20, offset: const Offset(0, 8))]),
            child: ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('💳 Stripe à configurer — voir README'))),
              icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
              label: Text('Débloquer — ${program.priceEur.toStringAsFixed(2)}€',
                style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18))),
            ),
          )),
        const SizedBox(height: 8),
        Text('Accès à vie · ${program.durationWeeks} semaines de contenu',
          style: AppTextStyles.caption, textAlign: TextAlign.center),
      ]);
    }
    return SizedBox(width: double.infinity, height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.orangeGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20, offset: const Offset(0, 8))]),
        child: ElevatedButton.icon(
          onPressed: () async {
            await supabase.from('program_enrollments').upsert({
              'user_id':    supabase.auth.currentUser?.id,
              'program_id': program.id,
            });
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('✅ Programme démarré !')));
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
          label: Text('Démarrer gratuitement',
            style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18))),
        ),
      ));
  }

  Widget _chip(String l, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
    child: Text(l, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w700)));

  Color _diffColor() {
    switch (program.difficulty) {
      case 'Debutant': return AppColors.success;
      case 'Intermediaire': return AppColors.warning;
      case 'Avance': return AppColors.primary;
      case 'Elite': return AppColors.secondary;
      default: return AppColors.textMuted;
    }
  }

  String _weekTitle(int w, String cat) {
    const titles = {
      'Tir': ['Fondamentaux', 'Précision', 'Création + Off-ball', 'Situations de match'],
      'Dribble': ['Mains', 'Combos', 'Vitesse', 'Moves avancés'],
      'General': ['Bases', 'Développement', 'Intensification', 'Consolidation'],
    };
    return (titles[cat] ?? titles['General']!)[(w - 1) % 4];
  }

  Map<String, String> _sessionContent(int week, int day, String cat) {
    final sessions = <Map<String, String>>[
      {'title': 'Échauffement + fondamentaux', 'desc': '10 min warm-up · 25 min technique'},
      {'title': 'Répétitions et drill', 'desc': '30 min drills intensifs · 10 min cool-down'},
      {'title': 'Application en situation', 'desc': '15 min drill · 20 min mise en situation'},
      {'title': 'Cardio + technique légère', 'desc': '20 min cardio · 15 min révisions'},
      {'title': 'Session compétitive', 'desc': '35 min contre la montre · bilan'},
    ];
    return sessions[((week - 1) * program.sessionsPerWeek + day - 1) % sessions.length];
  }
}
