import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../data/moves_catalog.dart';
import '../../models/user_model.dart';
import 'move_detail_v2_screen.dart';

class MovesScreen extends StatefulWidget {
  final UserProfile? profile;
  final Function(UserProfile) onUpdate;
  const MovesScreen({super.key, required this.profile, required this.onUpdate});

  @override State<MovesScreen> createState() => _MovesScreenState();
}

class _MovesScreenState extends State<MovesScreen>
    with TickerProviderStateMixin {
  MoveCategory? _selectedCat;
  String _tab = 'all'; // all | free | pro | dunks
  late AnimationController _heroCtrl;
  late Animation<double> _heroAnim;

  final _scrollCtrl = ScrollController();
  bool _showMiniHeader = false;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 600));
    _heroAnim = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroCtrl.forward();
    _scrollCtrl.addListener(() {
      final show = _scrollCtrl.offset > 80;
      if (show != _showMiniHeader) setState(() => _showMiniHeader = show);
    });
  }

  @override void dispose() {
    _heroCtrl.dispose(); _scrollCtrl.dispose(); super.dispose();
  }

  List<MoveData> get _filtered {
    var moves = MovesCatalog.all;
    if (_tab == 'free')  moves = moves.where((m) => m.isFree).toList();
    if (_tab == 'pro')   moves = moves.where((m) => m.isPro && m.category != MoveCategory.dunk).toList();
    if (_tab == 'dunks') moves = moves.where((m) => m.category == MoveCategory.dunk).toList();
    if (_tab == 'all' && _selectedCat != null)
      moves = moves.where((m) => m.category == _selectedCat).toList();
    return moves;
  }

  void _openMove(MoveData m) {
    HapticFeedback.lightImpact();
    Navigator.push(context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MoveDetailV2Screen(
          move: m, profile: widget.profile, onUpdate: widget.onUpdate),
        transitionsBuilder: (_, a, __, c) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: c),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        controller: _scrollCtrl,
        headerSliverBuilder: (_, __) => [_appBar()],
        body: Column(children: [
          _tabBar(),
          if (_tab == 'all') _categoryRow(),
          Expanded(child: _movesList()),
        ]),
      ),
    );
  }

  Widget _appBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      title: AnimatedOpacity(
        opacity: _showMiniHeader ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Text('Moves & Skills', style: AppTextStyles.heading3)),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A0500), Color(0xFF060610)],
              begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: SafeArea(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: FadeTransition(
              opacity: _heroAnim,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 12),
                Row(children: [
                  ShaderMask(
                    shaderCallback: (b) => AppColors.orangeGradient.createShader(b),
                    child: Text('Moves', style: GoogleFonts.inter(
                      fontSize: 38, fontWeight: FontWeight.w900,
                      color: Colors.white, letterSpacing: -2))),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.orangeGradient,
                      borderRadius: BorderRadius.circular(8)),
                    child: Text('${MovesCatalog.all.length}+',
                      style: const TextStyle(color: Colors.white,
                        fontSize: 13, fontWeight: FontWeight.w800))),
                ]),
                const SizedBox(height: 6),
                Text('Techniques NBA • Scan IA • Dunks extrêmes',
                  style: AppTextStyles.body),
                const SizedBox(height: 16),
                // Stats row
                Row(children: [
                  _heroStat(MovesCatalog.all.where((m) => m.isFree).length.toString(),
                    'Gratuits', AppColors.success),
                  const SizedBox(width: 16),
                  _heroStat(MovesCatalog.all.where((m) => m.isPro).length.toString(),
                    'Pro 5€/move', AppColors.secondary),
                  const SizedBox(width: 16),
                  _heroStat('6', 'Catégories', AppColors.accent),
                ]),
              ]),
            ),
          )),
        ),
      ),
    );
  }

  Widget _heroStat(String value, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 6, height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      RichText(text: TextSpan(children: [
        TextSpan(text: '$value ', style: TextStyle(
          color: color, fontSize: 13, fontWeight: FontWeight.w800)),
        TextSpan(text: label, style: AppTextStyles.caption),
      ])),
    ],
  );

  Widget _tabBar() {
    final tabs = [
      ('all',   'Tous',   null),
      ('free',  '🆓 Gratuits', AppColors.success),
      ('pro',   '👑 Pro',  AppColors.secondary),
      ('dunks', '🔥 Dunks', AppColors.primary),
    ];
    return Container(
      height: 46,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
      child: Row(
        children: tabs.map((t) {
          final sel = _tab == t.$1;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() {
              _tab = t.$1; _selectedCat = null; }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: sel ? (t.$3 != null
                  ? LinearGradient(colors: [t.$3!, t.$3!.withOpacity(0.8)])
                  : AppColors.orangeGradient) : null,
                borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(t.$2, style: TextStyle(
                color: sel ? Colors.white : AppColors.textMuted,
                fontSize: 11, fontWeight: FontWeight.w700))),
            ),
          ));
        }).toList(),
      ),
    );
  }

  Widget _categoryRow() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        itemCount: MoveCategory.values.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            final sel = _selectedCat == null;
            return GestureDetector(
              onTap: () => setState(() => _selectedCat = null),
              child: _catChip('Tous', null, sel));
          }
          final cat = MoveCategory.values[i - 1];
          final sel = _selectedCat == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCat = sel ? null : cat),
            child: _catChip('${cat.emoji} ${cat.label}', cat, sel));
        },
      ),
    );
  }

  Widget _catChip(String label, MoveCategory? cat, bool sel) {
    Color accent = cat == MoveCategory.dunk
      ? AppColors.primary : AppColors.accent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: sel ? (cat == MoveCategory.dunk
          ? AppColors.orangeGradient : AppColors.purpleGradient) : null,
        color: sel ? null : AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: sel ? Colors.transparent
            : cat == MoveCategory.dunk
              ? AppColors.primary.withOpacity(0.3) : AppColors.border)),
      child: Text(label, style: TextStyle(
        color: sel ? Colors.white : AppColors.textSecondary,
        fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _movesList() {
    final moves = _filtered;
    if (moves.isEmpty) return _empty();

    // Dunks tab: hero banner at top
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: moves.length + (_tab == 'dunks' ? 1 : 0),
      itemBuilder: (_, i) {
        if (_tab == 'dunks' && i == 0) return _dunksBanner();
        final move = moves[_tab == 'dunks' ? i - 1 : i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _MoveCard(move: move, onTap: () => _openMove(move)));
      },
    );
  }

  Widget _dunksBanner() => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF3D0000), Color(0xFF1A0500)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.primary.withOpacity(0.3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('🔥', style: TextStyle(fontSize: 40)),
      const SizedBox(height: 10),
      Text('Dunks', style: GoogleFonts.inter(
        color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900,
        letterSpacing: -1)),
      const SizedBox(height: 6),
      Text('Du dunk basique au 360° windmill.\nGratuits + Premium extrêmes.',
        style: AppTextStyles.body),
      const SizedBox(height: 14),
      Row(children: [
        AppChip('2 gratuits', AppColors.success),
        const SizedBox(width: 8),
        AppChip('5 moves premium', AppColors.primary),
        const SizedBox(width: 8),
        AppChip('5€/move', AppColors.textMuted),
      ]),
    ]),
  );

  Widget _empty() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text('🎬', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('Aucun move', style: AppTextStyles.heading3),
    ],
  ));
}

// ── Move Card v2 ─────────────────────────────────────────
class _MoveCard extends StatefulWidget {
  final MoveData move;
  final VoidCallback onTap;
  const _MoveCard({required this.move, required this.onTap});
  @override State<_MoveCard> createState() => _MoveCardState();
}

class _MoveCardState extends State<_MoveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.97)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  Color get _diffColor {
    switch (widget.move.difficulty) {
      case MoveDifficulty.debutant:      return AppColors.success;
      case MoveDifficulty.intermediaire: return AppColors.warning;
      case MoveDifficulty.avance:        return AppColors.primary;
      case MoveDifficulty.elite:         return AppColors.secondary;
    }
  }

  bool get _isDunk => widget.move.category == MoveCategory.dunk;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp:   (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _isDunk && widget.move.isPro
              ? const Color(0xFF1A0800)
              : widget.move.isPro
                ? const Color(0xFF0E0820)
                : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isDunk && widget.move.isPro
                ? AppColors.primary.withOpacity(0.35)
                : widget.move.isPro
                  ? AppColors.secondary.withOpacity(0.3)
                  : AppColors.border),
          ),
          child: Row(children: [
            // Icon
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: _isDunk
                  ? AppColors.orangeGradient
                  : widget.move.isPro
                    ? AppColors.purpleGradient : null,
                color: widget.move.isFree && !_isDunk
                  ? AppColors.cardAlt : null,
                borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(widget.move.emoji,
                style: const TextStyle(fontSize: 26)))),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(widget.move.title,
                    style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 14,
                      fontWeight: FontWeight.w700, letterSpacing: -0.2))),
                  if (_isDunk && widget.move.isPro)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: AppColors.orangeGradient,
                        borderRadius: BorderRadius.circular(6)),
                      child: const Text('🔥 DUNK', style: TextStyle(
                        color: Colors.white, fontSize: 8,
                        fontWeight: FontWeight.w800)))
                  else if (widget.move.isPro)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(6)),
                      child: const Text('PRO', style: TextStyle(
                        color: Colors.white, fontSize: 8,
                        fontWeight: FontWeight.w800))),
                ]),
                const SizedBox(height: 5),
                Row(children: [
                  if (widget.move.proPlayer != null) ...[
                    Text('👑 ${widget.move.proPlayer!}',
                      style: TextStyle(color: AppColors.secondary,
                        fontSize: 10, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                  ],
                  AppChip(widget.move.difficultyLabel, _diffColor, fontSize: 9),
                  const SizedBox(width: 6),
                  AppChip('📷 Scan IA', AppColors.accent, fontSize: 9),
                ]),
                const SizedBox(height: 5),
                Row(children: [
                  Text('⚡ +${widget.move.xpReward} XP',
                    style: TextStyle(color: AppColors.primary,
                      fontSize: 11, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (widget.move.isPro)
                    Text('${widget.move.priceEur.toStringAsFixed(0)}€',
                      style: TextStyle(
                        color: _isDunk ? AppColors.primary : AppColors.secondary,
                        fontSize: 13, fontWeight: FontWeight.w800)),
                ]),
              ],
            )),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 18),
          ]),
        ),
      ),
    );
  }
}
