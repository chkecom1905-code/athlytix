import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/move_model.dart';
import '../../models/user_model.dart';
import '../../widgets/shimmer_card.dart';
import 'program_detail_screen.dart';

class ProgramsScreen extends StatefulWidget {
  final UserProfile? profile;
  final Function(UserProfile) onUpdate;

  const ProgramsScreen({super.key, required this.profile, required this.onUpdate});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen>
    with SingleTickerProviderStateMixin {
  List<Program> _programs = [];
  bool _loading = true;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await supabase.from('programs').select().order('is_free', ascending: false).order('created_at');
      if (mounted) {
        setState(() =>
          _programs = (data as List).map((e) => Program.fromMap(e)).toList());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Program> get _free => _programs.where((p) => p.isFree).toList();
  List<Program> get _pro  => _programs.where((p) => p.isPro).toList();

  void _open(Program p) {
    Navigator.push(context,
      MaterialPageRoute(builder: (_) => ProgramDetailScreen(
        program: p, profile: widget.profile, onUpdate: widget.onUpdate)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _header(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.card, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(10)),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              tabs: const [Tab(text: '🆓 Gratuits'), Tab(text: '👑 Programmes Pros')],
            ),
          ),
          Expanded(child: _loading
            ? const WorkoutListShimmer()
            : TabBarView(
                controller: _tabCtrl,
                children: [_freeList(), _proList()],
              )),
        ]),
      ),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Programmes', style: AppTextStyles.heading2),
      const SizedBox(height: 4),
      Text('Entraînements structurés pour progresser rapidement.',
        style: AppTextStyles.body),
    ]),
  );

  Widget _freeList() => ListView.separated(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
    itemCount: _free.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (_, i) => _ProgramCard(program: _free[i], onTap: () => _open(_free[i])),
  );

  Widget _proList() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
    children: [
      // Pro banner
      Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: AppColors.purpleGradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 20, offset: const Offset(0, 8))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('👑', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Programmes de Pros', style: GoogleFonts.inter(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              Text('Curry · LeBron · KD · Harden · Giannis · Doncic',
                style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 11)),
            ])),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _badge('📅 4–12 semaines'),
            const SizedBox(width: 8),
            _badge('⚡ +XP par session'),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _badge('📷 Moves + Scan IA'),
            const SizedBox(width: 8),
            _badge('🎯 Objectifs hebdo'),
          ]),
        ]),
      ),
      ..._pro.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ProgramCard(program: p, onTap: () => _open(p)),
      )),
    ],
  );

  Widget _badge(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8)),
    child: Text(t, style: GoogleFonts.inter(
      color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
  );
}

// ── Program Card ──────────────────────────────────────────
class _ProgramCard extends StatelessWidget {
  final Program program;
  final VoidCallback onTap;
  const _ProgramCard({required this.program, required this.onTap});

  Color get _diffColor {
    switch (program.difficulty) {
      case 'Debutant': return AppColors.success;
      case 'Intermediaire': return AppColors.warning;
      case 'Avance': return AppColors.primary;
      case 'Elite': return AppColors.secondary;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: program.isPro
              ? AppColors.secondary.withOpacity(0.06) : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: program.isPro
                ? AppColors.secondary.withOpacity(0.25) : AppColors.border)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: program.isPro ? AppColors.purpleGradient : null,
                color: program.isPro ? null : AppColors.cardAlt,
                borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(
                program.emoji.isNotEmpty ? program.emoji : '📋',
                style: const TextStyle(fontSize: 24)))),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(program.title, style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
                  if (program.isPro)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(6)),
                      child: const Text('PRO', style: TextStyle(
                        color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
                ]),
                const SizedBox(height: 5),
                if (program.proPlayer != null) ...[
                  Text('👑 ${program.proPlayer}',
                    style: TextStyle(color: AppColors.secondary, fontSize: 10,
                      fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                ],
                Row(children: [
                  _chip(program.difficulty, _diffColor),
                  const SizedBox(width: 6),
                  _chip('${program.durationWeeks} sem.', AppColors.accent),
                  const SizedBox(width: 6),
                  _chip('${program.sessionsPerWeek}x/sem', AppColors.textMuted),
                ]),
                const SizedBox(height: 5),
                if (program.isPro)
                  Text('${program.priceEur.toStringAsFixed(2)}€',
                    style: TextStyle(
                      color: AppColors.secondary, fontSize: 14,
                      fontWeight: FontWeight.w800)),
              ],
            )),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
          ]),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
    child: Text(label, style: TextStyle(
      color: color, fontSize: 9, fontWeight: FontWeight.w700)),
  );
}
