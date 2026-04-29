import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/xp_service.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? profile;
  const ProfileScreen({super.key, required this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    XpService.getCompletedCount().then((c) {
      if (mounted) setState(() => _completedCount = c);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            const SizedBox(height: 28),
            _header(p),
            const SizedBox(height: 22),
            _xpBar(p),
            const SizedBox(height: 16),
            _statsGrid(p),
            const SizedBox(height: 20),
            if (p?.isPremium != true) ...[_premiumBanner(context), const SizedBox(height: 20)],
            _settings(context),
            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }

  Widget _header(UserProfile? p) {
    return Column(children: [
      Container(
        width: 90, height: 90,
        decoration: BoxDecoration(
          gradient: AppColors.orangeGradient, shape: BoxShape.circle,
          boxShadow: [BoxShadow(
            color: AppColors.primary.withOpacity(0.35), blurRadius: 22)],
        ),
        child: const Center(child: Text('🏀', style: TextStyle(fontSize: 42))),
      ),
      const SizedBox(height: 14),
      Text(p?.username ?? 'Athlète', style: AppTextStyles.heading2),
      const SizedBox(height: 4),
      Text(p?.email ?? '', style: AppTextStyles.body.copyWith(fontSize: 13)),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: p?.isPremium == true
              ? AppColors.secondary.withOpacity(0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: p?.isPremium == true ? AppColors.secondary : AppColors.border),
        ),
        child: Text(p?.isPremium == true ? '💎 Membre Premium' : '🆓 Compte Free',
          style: TextStyle(
            color: p?.isPremium == true ? AppColors.secondary : AppColors.textMuted,
            fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    ]);
  }

  Widget _xpBar(UserProfile? p) {
    final xp   = p?.xp ?? 0;
    final lvl  = p?.level ?? 1;
    final prog = p?.xpProgress ?? 0.0;
    final cur  = p?.xpProgress ?? 0;
    final next = p?.xpForNextLevel ?? 500;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Niveau $lvl', style: AppTextStyles.heading3),
            Text('$xp XP', style: TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Lvl $lvl', style: AppTextStyles.caption),
          Text('Lvl ${lvl + 1}', style: AppTextStyles.caption),
        ]),
        const SizedBox(height: 6),
        LinearPercentIndicator(
          lineHeight: 10,
          percent: prog.clamp(0.0, 1.0),
          backgroundColor: AppColors.border,
          linearGradient: AppColors.orangeGradient,
          barRadius: const Radius.circular(10),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 6),
        Align(alignment: Alignment.centerRight,
          child: Text('$cur / $next XP', style: AppTextStyles.caption)),
      ]),
    );
  }

  Widget _statsGrid(UserProfile? p) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Statistiques', style: AppTextStyles.heading3),
      const SizedBox(height: 14),
      Row(children: [
        _tile('XP Total', '${p?.xp ?? 0}',   '⚡', AppColors.primary),
        const SizedBox(width: 10),
        _tile('Niveau',   '${p?.level ?? 1}', '⭐', AppColors.warning),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _tile('Streak',   '${p?.streak ?? 0}','🔥', Colors.orange),
        const SizedBox(width: 10),
        _tile('Workouts', '$_completedCount',  '✅', AppColors.success),
      ]),
    ]);
  }

  Widget _tile(String label, String value, String emoji, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: GoogleFonts.inter(
              color: color, fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label, style: AppTextStyles.caption),
          ])),
        ]),
      ),
    );
  }

  Widget _premiumBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPremium(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.purpleGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          const Text('💎', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Passe Premium', style: GoogleFonts.inter(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Workouts exclusifs, analyses IA.', style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12)),
            child: Text('4,99€/mois', style: GoogleFonts.inter(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }

  void _showPremium(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 22),
          const Text('💎', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 14),
          Text('Premium BALLVYN', style: AppTextStyles.heading2, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Accède à tous les contenus premium et analyses détaillées.',
            style: AppTextStyles.body, textAlign: TextAlign.center),
          const SizedBox(height: 22),
          ...[
            'Workouts illimités + exclusifs',
            'Analyses de performance IA',
            'Défis exclusifs mensuels',
            'Support prioritaire 24/7',
          ].map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded,
                color: AppColors.secondary, size: 20),
              const SizedBox(width: 10),
              Text(f, style: AppTextStyles.body.copyWith(color: Colors.white)),
            ]))),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(16)),
              child: ElevatedButton(
                // TODO: flutter pub add flutter_stripe
                // → Call Edge Function 'create-payment-intent'
                // → Stripe.instance.initPaymentSheet(clientSecret: ...)
                // → Stripe.instance.presentPaymentSheet()
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('💳 Stripe à configurer — voir README')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
                child: Text('Commencer — 4,99€/mois', style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            )),
          const SizedBox(height: 10),
          Text('Annulation à tout moment · Aucun engagement',
            style: AppTextStyles.caption, textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _settings(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Compte', style: AppTextStyles.heading3),
      const SizedBox(height: 14),
      _row(Icons.logout_rounded, 'Se déconnecter', Colors.red,
        () => AuthService.signOut()),
    ]);
  }

  Widget _row(IconData icon, String label, Color? color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Icon(icon, color: color ?? AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(
            color: color ?? Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
        ]),
      ),
    );
  }
}
