import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class LevelUpDialog extends StatefulWidget {
  final int newLevel;
  final int xp;

  const LevelUpDialog({super.key, required this.newLevel, required this.xp});

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _fadeCtrl;

  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _scaleCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
    _particleCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
    _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));

    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _fadeCtrl,  curve: Curves.easeIn);

    _scaleCtrl.forward();
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _particleCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 40, spreadRadius: 4),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Particles(controller: _particleCtrl),
                const SizedBox(height: 8),
                _buildBadge(),
                const SizedBox(height: 20),
                Text('NIVEAU SUPÉRIEUR !',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary, letterSpacing: 2)),
                const SizedBox(height: 8),
                Text('Niveau ${widget.newLevel}',
                  style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900,
                    letterSpacing: -2)),
                const SizedBox(height: 8),
                Text('Incroyable ! Tu as débloqué le niveau ${widget.newLevel}.',
                  style: AppTextStyles.body, textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGlow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${widget.xp} XP total',
                    style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700,
                      fontSize: 14)),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.orangeGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                      child: Text('Continuer 🔥',
                        style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (_, child) {
        final glow = 0.3 + (_particleCtrl.value * 0.3);
        return Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.orangeGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(glow),
                blurRadius: 30, spreadRadius: 4),
            ],
          ),
          child: Center(child: Text('${widget.newLevel}',
            style: GoogleFonts.inter(
              color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900))),
        );
      },
    );
  }
}

// Simple CSS-style particle burst around the badge
class _Particles extends StatelessWidget {
  final AnimationController controller;
  const _Particles({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return SizedBox(
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(8, (i) {
              final angle = (i / 8) * 3.14159 * 2;
              final t = (controller.value + i / 8) % 1.0;
              final radius = 40 * t;
              final opacity = (1 - t).clamp(0.0, 1.0);
              return Positioned(
                left: 100 + radius * (1.5 * (i % 2 == 0 ? 1 : -1)),
                top: 30 + radius * (i < 4 ? -1 : 1) * 0.5,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: i % 2 == 0 ? AppColors.primary : AppColors.warning,
                      shape: BoxShape.circle),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
