import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/user_model.dart';
import '../../services/coach_service.dart';
import '../../services/token_service.dart';
import 'token_purchase_screen.dart';

class CoachIaScreen extends StatefulWidget {
  final UserProfile? profile;
  final Function(UserProfile) onUpdate;

  const CoachIaScreen({super.key, required this.profile, required this.onUpdate});

  @override State<CoachIaScreen> createState() => _CoachIaScreenState();
}

class _CoachIaScreenState extends State<CoachIaScreen>
    with TickerProviderStateMixin {
  AnalysisType _selectedType = AnalysisType.match;
  final _notesCtrl = TextEditingController();
  final _statsCtrl = <String, TextEditingController>{};

  bool _loading = false;
  String? _result;
  List<AiAnalysis> _history = [];

  late AnimationController _shimmerCtrl;
  late AnimationController _resultCtrl;
  late Animation<double> _resultAnim;

  // Match stats fields
  static const _matchFields = [
    ('pts',  'Points', '24'),
    ('reb',  'Rebonds', '8'),
    ('ast',  'Passes', '5'),
    ('tov',  'Pertes de balle', '3'),
    ('fg%',  'Taux de tir', '45%'),
  ];

  @override
  void initState() {
    super.initState();
    for (final f in _matchFields) {
      _statsCtrl[f.$1] = TextEditingController();
    }
    _shimmerCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 1400))..repeat();
    _resultCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 600));
    _resultAnim = CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOutCubic);
    _loadHistory();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final c in _statsCtrl.values) { c.dispose(); }
    _shimmerCtrl.dispose();
    _resultCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final h = await TokenService.getHistory();
    if (mounted) setState(() => _history = h);
  }

  Future<void> _analyze() async {
    final profile = widget.profile;
    if (profile == null) return;

    if (profile.aiTokens <= 0) {
      _showNoTokens();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() { _loading = true; _result = null; });
    _resultCtrl.reset();

    // Spend token
    final ok = await TokenService.spendToken(profile);
    if (!ok) { setState(() => _loading = false); _showNoTokens(); return; }

    // Update profile
    final updated = profile.copyWith(aiTokens: profile.aiTokens - 1);
    widget.onUpdate(updated);

    // Build request
    final stats = <String, String>{};
    if (_selectedType == AnalysisType.match) {
      for (final f in _matchFields) {
        final v = _statsCtrl[f.$1]?.text.trim();
        if (v?.isNotEmpty ?? false) stats[f.$2] = v!;
      }
    }

    final request = CoachAnalysisRequest(
      type: _selectedType,
      stats: stats,
      notes: _notesCtrl.text.trim(),
    );

    try {
      final result = await CoachService.analyze(
        request: request, profile: profile);

      await TokenService.saveAnalysis(
        prompt: _notesCtrl.text.trim().isEmpty
          ? _selectedType.label
          : _notesCtrl.text.trim(),
        response: result,
        analysisType: _selectedType.name,
      );

      if (mounted) {
        setState(() { _result = result; _loading = false; });
        _resultCtrl.forward();
        await _loadHistory();
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showNoTokens() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NoTokensSheet(
        onBuy: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => TokenPurchaseScreen(
              profile: widget.profile,
              onUpdate: widget.onUpdate)));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                const SizedBox(height: 8),
                _typeSelector(),
                const SizedBox(height: 20),
                _inputSection(),
                const SizedBox(height: 20),
                _analyzeButton(),
                const SizedBox(height: 24),
                if (_loading) _loadingCard(),
                if (_result != null && !_loading) _resultCard(),
                if (_history.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _historySection(),
                ],
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final tokens = widget.profile?.aiTokens ?? 0;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      title: Row(children: [
        ShaderMask(
          shaderCallback: (b) => AppColors.purpleGradient.createShader(b),
          child: Text('Coach IA', style: GoogleFonts.inter(
            fontSize: 24, fontWeight: FontWeight.w900,
            letterSpacing: -1, color: Colors.white)),
        ),
        const SizedBox(width: 8),
        Text('✨', style: const TextStyle(fontSize: 18)),
      ]),
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => TokenPurchaseScreen(
              profile: widget.profile, onUpdate: widget.onUpdate))),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: tokens > 0
                ? AppColors.purpleGradient
                : const LinearGradient(colors: [Color(0xFF1C1C30), Color(0xFF1C1C30)]),
              borderRadius: BorderRadius.circular(20),
              border: tokens == 0
                ? Border.all(color: AppColors.border) : null,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('✨', style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
              Text('$tokens tokens',
                style: GoogleFonts.inter(
                  color: tokens > 0 ? Colors.white : AppColors.textMuted,
                  fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _typeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TYPE D\'ANALYSE', style: AppTextStyles.label),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: AnalysisType.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final t = AnalysisType.values[i];
              final sel = _selectedType == t;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedType = t;
                  _result = null;
                  _resultCtrl.reset();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: sel ? AppColors.purpleGradient : null,
                    color: sel ? null : AppColors.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: sel ? Colors.transparent : AppColors.border)),
                  child: Center(child: Text(t.label, style: TextStyle(
                    color: sel ? Colors.white : AppColors.textSecondary,
                    fontSize: 13, fontWeight: FontWeight.w600))),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _inputSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(_selectedType),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match stats fields
            if (_selectedType == AnalysisType.match) ...[
              Text('Stats du match', style: AppTextStyles.heading3),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: _matchFields.map((f) => SizedBox(
                  width: (MediaQuery.of(context).size.width - 76) / 2,
                  child: _statField(f.$1, f.$2, f.$3),
                )).toList(),
              ),
              const SizedBox(height: 14),
            ],
            // Notes textarea
            Text(
              _selectedType == AnalysisType.match
                ? 'Contexte / ressenti' : 'Décris ta demande',
              style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: _hintFor(_selectedType),
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                filled: true,
                fillColor: AppColors.bgDeep,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.secondary)),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statField(String key, String label, String hint) => TextField(
    controller: _statsCtrl[key],
    style: GoogleFonts.inter(color: Colors.white, fontSize: 14,
      fontWeight: FontWeight.w600),
    keyboardType: TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 11),
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.5), fontSize: 12),
      filled: true,
      fillColor: AppColors.bgDeep,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.secondary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
  );

  Widget _analyzeButton() {
    final tokens = widget.profile?.aiTokens ?? 0;
    return Column(children: [
      GradientButton(
        label: tokens > 0
          ? 'Analyser — 1 token ✨'
          : 'Acheter des tokens',
        gradient: tokens > 0
          ? AppColors.purpleGradient
          : AppColors.orangeGradient,
        shadows: tokens > 0
          ? AppColors.purpleShadow : AppColors.orangeShadow,
        height: 58,
        loading: _loading,
        onTap: _loading ? null : _analyze,
      ),
      if (tokens == 0) ...[
        const SizedBox(height: 8),
        Text('Plus de tokens — rechargez pour continuer',
          style: AppTextStyles.caption.copyWith(color: AppColors.error),
          textAlign: TextAlign.center),
      ] else ...[
        const SizedBox(height: 8),
        Text('$tokens analyse${tokens > 1 ? "s" : ""} restante${tokens > 1 ? "s" : ""}',
          style: AppTextStyles.caption, textAlign: TextAlign.center),
      ],
    ]);
  }

  Widget _loadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3))),
      child: Column(children: [
        AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, __) => ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppColors.secondary, AppColors.accent, AppColors.secondary],
              stops: [
                (_shimmerCtrl.value - 0.3).clamp(0.0, 1.0),
                _shimmerCtrl.value.clamp(0.0, 1.0),
                (_shimmerCtrl.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds),
            child: Text('✨', style: const TextStyle(fontSize: 40, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 14),
        Text('Analyse en cours…', style: AppTextStyles.heading3.copyWith(
          color: AppColors.secondary)),
        const SizedBox(height: 6),
        Text('Le Coach IA analyse ton profil', style: AppTextStyles.body),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          backgroundColor: AppColors.border,
          valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
          borderRadius: BorderRadius.circular(4),
        ),
      ]),
    );
  }

  Widget _resultCard() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(_resultAnim),
      child: FadeTransition(
        opacity: _resultAnim,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary.withOpacity(0.12),
                AppColors.background,
              ],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    shape: BoxShape.circle),
                  child: const Center(child: Text('✨', style: TextStyle(fontSize: 18)))),
                const SizedBox(width: 10),
                Text('Coach BALLVYN', style: AppTextStyles.heading3
                  .copyWith(color: AppColors.secondary)),
              ]),
              const SizedBox(height: 16),
              _buildFormattedText(_result!),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _result!));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Copié ✓'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1)));
                },
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Icon(Icons.copy_rounded, color: AppColors.textMuted, size: 14),
                  const SizedBox(width: 5),
                  Text('Copier', style: AppTextStyles.caption),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Parse **bold** and emoji formatting
  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.isEmpty) return const SizedBox(height: 8);
        final isBold = line.startsWith('**') && line.contains('**', 2);
        final clean  = line.replaceAll('**', '');
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(clean, style: isBold
            ? AppTextStyles.body.copyWith(
                color: Colors.white, fontWeight: FontWeight.w700)
            : AppTextStyles.body.copyWith(height: 1.6)),
        );
      }).toList(),
    );
  }

  Widget _historySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader('Historique', action: 'Tout voir'),
        ..._history.take(3).map((a) => _HistoryTile(analysis: a)),
      ],
    );
  }

  String _hintFor(AnalysisType t) {
    switch (t) {
      case AnalysisType.match:
        return 'Ex: "Bonne première mi-temps mais j\'ai perdu le fil en 3ème quart..."';
      case AnalysisType.training:
        return 'Ex: "Session de tir 60 min, intensité 8/10, grosse fatigue sur les 3pts..."';
      case AnalysisType.weaknesses:
        return 'Ex: "Mon tir à mi-distance est inconsistant et je perds trop de balles..."';
      case AnalysisType.program:
        return 'Ex: "Objectif: améliorer mon explosivité et mon tir à 3pts en 30 jours"';
    }
  }
}

class _HistoryTile extends StatelessWidget {
  final AiAnalysis analysis;
  const _HistoryTile({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final type = AnalysisType.values
      .firstWhere((t) => t.name == analysis.analysisType,
        orElse: () => AnalysisType.match);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient, shape: BoxShape.circle),
          child: const Center(child: Text('✨', style: TextStyle(fontSize: 16)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(type.label, style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          Text(analysis.prompt.isNotEmpty
            ? analysis.prompt.substring(0, analysis.prompt.length.clamp(0, 50))
            : 'Analyse automatique',
            style: AppTextStyles.caption,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
      ]),
    );
  }
}

// ── No tokens bottom sheet ─────────────────────────────────
class _NoTokensSheet extends StatelessWidget {
  final VoidCallback onBuy;
  const _NoTokensSheet({required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('✨', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 14),
        Text('Plus de tokens', style: AppTextStyles.heading2),
        const SizedBox(height: 8),
        Text('Rechargez pour continuer à utiliser le Coach IA',
          style: AppTextStyles.body, textAlign: TextAlign.center),
        const SizedBox(height: 22),
        GradientButton(
          label: 'Voir les packs de tokens',
          gradient: AppColors.purpleGradient,
          shadows: AppColors.purpleShadow,
          onTap: onBuy),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Plus tard', style: AppTextStyles.body)),
      ]),
    );
  }
}
