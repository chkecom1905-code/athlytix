import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/move_model.dart';
import '../../models/user_model.dart';
import 'video_scan_screen.dart';

class MoveDetailScreen extends StatelessWidget {
  final Move move;
  final UserProfile? profile;
  final Function(UserProfile) onUpdate;

  const MoveDetailScreen({
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
          _appBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _chips(),
                  const SizedBox(height: 14),
                  Text(move.title, style: AppTextStyles.heading1),
                  if (move.proPlayer != null) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: AppColors.purpleGradient,
                          borderRadius: BorderRadius.circular(8)),
                        child: Text('👑 Move de ${move.proPlayer}',
                          style: const TextStyle(
                            color: Colors.white, fontSize: 12,
                            fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ],
                  const SizedBox(height: 12),
                  Text(move.description.isNotEmpty
                    ? move.description
                    : 'Maîtrise ce move avec l\'aide du scan IA pour valider chaque détail technique.',
                    style: AppTextStyles.body),
                  const SizedBox(height: 20),
                  _xpCard(),
                  const SizedBox(height: 24),
                  _instructionsCard(),
                  const SizedBox(height: 24),
                  _scanInfo(),
                  const SizedBox(height: 28),
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
                move.isPro
                    ? AppColors.secondary.withOpacity(0.6)
                    : AppColors.primary.withOpacity(0.6),
                AppColors.background,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(move.emoji.isNotEmpty ? move.emoji : '🎬',
                  style: const TextStyle(fontSize: 72)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chips() => Row(children: [
    _chip(move.category, AppColors.accent),
    const SizedBox(width: 8),
    _chip(move.difficulty, _diffColor()),
    const SizedBox(width: 8),
    _chip('📷 Scan IA', AppColors.primary),
  ]);

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: TextStyle(
      color: color, fontSize: 12, fontWeight: FontWeight.w700)),
  );

  Widget _xpCard() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.primaryGlow, borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      const Text('⚡', style: TextStyle(fontSize: 20)),
      const SizedBox(width: 10),
      Text('+${move.xpReward} XP après validation',
        style: TextStyle(color: AppColors.primary, fontSize: 14,
          fontWeight: FontWeight.w700)),
    ]),
  );

  Widget _instructionsCard() {
    final steps = _stepsFor(move.title);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Instructions', style: AppTextStyles.heading3),
        const SizedBox(height: 14),
        ...steps.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(
                gradient: AppColors.orangeGradient, shape: BoxShape.circle),
              child: Center(child: Text('${e.key + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 11,
                  fontWeight: FontWeight.w800)))),
            const SizedBox(width: 12),
            Expanded(child: Text(e.value, style: AppTextStyles.body)),
          ]),
        )),
      ]),
    );
  }

  Widget _scanInfo() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.accent.withOpacity(0.07),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.accent.withOpacity(0.2))),
    child: Row(children: [
      const Text('📷', style: TextStyle(fontSize: 28)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Scan IA activé', style: GoogleFonts.inter(
          color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Le scan détecte tes articulations en temps réel '
          'et valide chaque aspect du mouvement. '
          'Score ≥ 66% requis pour valider.',
          style: AppTextStyles.body.copyWith(fontSize: 12)),
      ])),
    ]),
  );

  Widget _cta(BuildContext context) {
    if (move.isPro && !(profile?.isPremium ?? false)) {
      return _buyButton(context);
    }
    return _scanButton(context);
  }

  Widget _scanButton(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: move.isPro ? AppColors.purpleGradient : AppColors.orangeGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
            color: (move.isPro ? AppColors.secondary : AppColors.primary)
                .withOpacity(0.4),
            blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => VideoScanScreen(
              move: move, profile: profile, onUpdate: onUpdate))),
          icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
          label: Text('Démarrer le Scan IA',
            style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18))),
        ),
      ),
    );
  }

  Widget _buyButton(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: double.infinity, height: 58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(
              color: AppColors.secondary.withOpacity(0.4),
              blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Stripe payment for this move
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('💳 Paiement Stripe à configurer — voir README')));
            },
            icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
            label: Text('Débloquer pour ${move.priceEur.toStringAsFixed(0)}€',
              style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18))),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Text('Accès à vie · Scan IA inclus',
        style: AppTextStyles.caption, textAlign: TextAlign.center),
    ]);
  }

  Color _diffColor() {
    switch (move.difficulty) {
      case 'Debutant': return AppColors.success;
      case 'Intermediaire': return AppColors.warning;
      case 'Avance': return AppColors.primary;
      case 'Elite': return AppColors.secondary;
      default: return AppColors.textMuted;
    }
  }

  List<String> _stepsFor(String title) {
    const defaults = [
      'Adoptez une posture athlétique — genoux fléchis, poids sur les orteils.',
      'Positionnez la balle correctement dans votre main dominante.',
      'Exécutez le mouvement de façon fluide et contrôlée.',
      'Finissez le move en position d\'équilibre.',
    ];
    final map = <String, List<String>>{
      'Crossover Basique': [
        'Tenez la balle basse, poignet en position de dribble.',
        'Poussez la balle vers l\'autre main en croisant devant vous.',
        'Changez le poids du corps dans la direction du crossover.',
        'Repartez en dribble bas du côté opposé.',
      ],
      'Curry Shake': [
        'Commencez par une feinte de passe à droite avec les deux mains.',
        'Faites immédiatement une seconde feinte à gauche — rapide !',
        'Utilisez le décalage des hanches pour destabiliser le défenseur.',
        'Partez en dribble dans la direction opposée à la feinte.',
      ],
      'LeBron Euro Step': [
        'Prenez votre élan en ligne droite vers le panier.',
        'Sur votre pied d\'appel, faites un grand pas latéral à gauche.',
        'Plantez le pied, puis finissez avec le pied droit.',
        'Terminez en lay-up ou floater selon la défense.',
      ],
      'Doncic Step-Back 3pts': [
        'Prenez position à 3 points face au panier.',
        'Créez l\'espace avec un recul franc du pied droit.',
        'Montez immédiatement en position de tir.',
        'Tirez avec les bras complètement étendus vers le haut.',
      ],
    };
    return map[title] ?? defaults;
  }
}
