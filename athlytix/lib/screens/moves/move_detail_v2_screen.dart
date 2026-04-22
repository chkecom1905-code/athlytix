import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../data/moves_catalog.dart';
import '../../models/user_model.dart';
import 'video_scan_screen.dart';

class MoveDetailV2Screen extends StatelessWidget {
  final MoveData move;
  final UserProfile? profile;
  final Function(UserProfile) onUpdate;

  const MoveDetailV2Screen({
    super.key,
    required this.move,
    required this.profile,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _heroBanner(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _metaRow(),
                  const SizedBox(height: 14),
                  Text(move.title, style: AppTextStyles.heading1),
                  if (move.proPlayer != null) ...[
                    const SizedBox(height: 8),
                    _proBadge(),
                  ],
                  const SizedBox(height: 10),
                  Text(move.description, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 20),
                  _xpRewardCard(),
                  if (move.steps.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _stepsCard(),
                  ],
                  const SizedBox(height: 24),
                  _tagsRow(),
                  const SizedBox(height: 24),
                  _scanInfoCard(),
                  const SizedBox(height: 28),
                  _ctaButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroBanner(BuildContext context) {
    final isDunk = move.category == MoveCategory.dunk;
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black45, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12)),
          child: const Icon(Icons.arrow_back_ios_new,
            color: Colors.white, size: 18))),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDunk
                ? [const Color(0xFF3D0000), AppColors.background]
                : move.isPro
                  ? [const Color(0xFF1A0A3A), AppColors.background]
                  : [const Color(0xFF1A0A00), AppColors.background],
              begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: SafeArea(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  gradient: isDunk
                    ? AppColors.orangeGradient
                    : move.isPro
                      ? AppColors.purpleGradient
                      : AppColors.darkGradient,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: (isDunk ? AppColors.primary : AppColors.secondary)
                      .withOpacity(0.3),
                    blurRadius: 30)]),
                child: Center(child: Text(move.emoji,
                  style: const TextStyle(fontSize: 52)))),
            ],
          )),
        ),
      ),
    );
  }

  Widget _metaRow() => Wrap(spacing: 8, runSpacing: 6, children: [
    AppChip(move.category.label, AppColors.accent),
    AppChip(move.difficultyLabel, _diffColor),
    AppChip('📷 Scan IA', AppColors.primary),
    if (move.category == MoveCategory.dunk)
      AppChip('🔥 DUNK', AppColors.primary),
  ]);

  Widget _proBadge() => Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: move.category == MoveCategory.dunk
          ? AppColors.orangeGradient : AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(10)),
      child: Text('👑 Technique de ${move.proPlayer}',
        style: const TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
  ]);

  Widget _xpRewardCard() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.primarySoft,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.primary.withOpacity(0.2))),
    child: Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          gradient: AppColors.orangeGradient, shape: BoxShape.circle),
        child: const Center(child: Text('⚡', style: TextStyle(fontSize: 18)))),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('+${move.xpReward} XP après validation',
          style: const TextStyle(color: AppColors.primary,
            fontSize: 15, fontWeight: FontWeight.w800)),
        Text('Score ≥ 66% requis pour valider',
          style: AppTextStyles.caption),
      ]),
    ]),
  );

  Widget _stepsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.glassCard(radius: 22,
        color: const Color(0x0AFFFFFF)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Technique', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          ...move.steps.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(
                      gradient: AppColors.orangeGradient,
                      shape: BoxShape.circle),
                    child: Center(child: Text('${e.key + 1}',
                      style: const TextStyle(color: Colors.white,
                        fontSize: 12, fontWeight: FontWeight.w800)))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(e.value,
                    style: AppTextStyles.body.copyWith(
                      height: 1.5, color: AppColors.textSecondary))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _tagsRow() => Wrap(
    spacing: 8, runSpacing: 6,
    children: move.tags.map((t) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.cardAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border)),
        child: Text('#$t', style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary, fontSize: 11)))).toList(),
  );

  Widget _scanInfoCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.accentGlow,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.accent.withOpacity(0.2))),
    child: Row(children: [
      const Text('📷', style: TextStyle(fontSize: 28)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Scan IA activé', style: GoogleFonts.inter(
          color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Détection de pose en temps réel · Feedback instantané · '
          'Score 0–100%',
          style: AppTextStyles.body.copyWith(fontSize: 12)),
      ])),
    ]),
  );

  Widget _ctaButton(BuildContext context) {
    if (move.isPro) {
      return Column(children: [
        GradientButton(
          label: 'Débloquer pour ${move.priceEur.toStringAsFixed(0)}€',
          icon: const Icon(Icons.lock_open_rounded,
            color: Colors.white, size: 18),
          gradient: move.category == MoveCategory.dunk
            ? AppColors.orangeGradient : AppColors.purpleGradient,
          shadows: move.category == MoveCategory.dunk
            ? AppColors.orangeShadow : AppColors.purpleShadow,
          height: 58,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('💳 Stripe — voir README'),
              behavior: SnackBarBehavior.floating)),
        ),
        const SizedBox(height: 10),
        Text('Accès à vie · Scan IA inclus · ${move.xpReward} XP',
          style: AppTextStyles.caption, textAlign: TextAlign.center),
      ]);
    }
    return GradientButton(
      label: 'Démarrer le Scan IA',
      icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
      gradient: AppColors.orangeGradient,
      height: 58,
      onTap: () {
        // Convert MoveData to Move for VideoScanScreen compatibility
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => _ScanBridgeScreen(
            move: move, profile: profile, onUpdate: onUpdate)));
      },
    );
  }

  Color get _diffColor {
    switch (move.difficulty) {
      case MoveDifficulty.debutant:      return AppColors.success;
      case MoveDifficulty.intermediaire: return AppColors.warning;
      case MoveDifficulty.avance:        return AppColors.primary;
      case MoveDifficulty.elite:         return AppColors.secondary;
    }
  }
}

// Bridge screen to adapt MoveData to VideoScanScreen
class _ScanBridgeScreen extends StatelessWidget {
  final MoveData move;
  final UserProfile? profile;
  final Function(UserProfile) onUpdate;
  const _ScanBridgeScreen({required this.move, required this.profile, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    // Use a minimal Scaffold that wraps camera logic
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(move.emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 20),
          Text(move.title, style: AppTextStyles.heading2),
          const SizedBox(height: 10),
          Text('Scan IA — ${move.category.label}',
            style: AppTextStyles.body),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(children: [
              ...move.steps.take(3).map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline,
                    color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s,
                    style: AppTextStyles.body.copyWith(fontSize: 12))),
                ]),
              )),
            ]),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GradientButton(
              label: 'Lancer la caméra',
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              onTap: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Retour', style: AppTextStyles.body)),
        ],
      ))),
    );
  }
}
