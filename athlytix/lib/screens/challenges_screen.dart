import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../widgets/shimmer_card.dart';

class ChallengesScreen extends StatefulWidget {
  final UserProfile? profile;
  const ChallengesScreen({super.key, required this.profile});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Challenge> _challenges = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await supabase.from('challenges').select().order('xp_reward');
      if (mounted) {
        setState(() => _challenges =
          (data as List).map((e) => Challenge.fromMap(e)).toList());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _header(),
          Expanded(
            child: _loading
                ? const ChallengeListShimmer()
                : RefreshIndicator(
                    onRefresh: _load,
                    color: AppColors.primary,
                    child: _challenges.isEmpty
                        ? _empty()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            itemCount: _challenges.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (_, i) =>
                              _ChallengeCard(challenge: _challenges[i]),
                          ),
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Défis', style: AppTextStyles.heading2),
      const SizedBox(height: 4),
      Text('Relève les défis et multiplie tes XP.', style: AppTextStyles.body),
    ]),
  );

  Widget _empty() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text('🏆', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('Aucun défi disponible', style: AppTextStyles.heading3),
    ],
  ));
}

class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  const _ChallengeCard({required this.challenge});

  LinearGradient get _gradient {
    switch (challenge.difficulty) {
      case 'Bronze':  return const LinearGradient(
        colors: [Color(0xFF7C5E3C), Color(0xFF5C4120)]);
      case 'Argent':  return const LinearGradient(
        colors: [Color(0xFF8E9BB0), Color(0xFF5E6B80)]);
      case 'Or':      return AppColors.orangeGradient;
      case 'Platine': return AppColors.purpleGradient;
      default:        return const LinearGradient(colors: [Color(0xFF1C1C30), Color(0xFF0F0F1E)]);
    }
  }

  Color get _badgeColor {
    switch (challenge.difficulty) {
      case 'Bronze':  return const Color(0xFFCD7F32);
      case 'Argent':  return const Color(0xFFC0C0C0);
      case 'Or':      return AppColors.warning;
      case 'Platine': return AppColors.secondary;
      default:        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = challenge.daysLeft;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Container(
          height: 5,
          decoration: BoxDecoration(
            gradient: _gradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                gradient: _gradient, borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(
                challenge.emoji.isNotEmpty ? challenge.emoji : '🏆',
                style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(challenge.title,
                      style: GoogleFonts.inter(
                        color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.w700))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _badgeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                      child: Text(challenge.difficulty, style: TextStyle(
                        color: _badgeColor, fontSize: 11,
                        fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(challenge.objective,
                  style: AppTextStyles.body.copyWith(fontSize: 13)),
                const SizedBox(height: 10),
                Row(children: [
                  _info('⚡ ${challenge.xpReward} XP', AppColors.primary),
                  const SizedBox(width: 8),
                  if (daysLeft >= 0)
                    _info(
                      daysLeft == 0 ? '⏰ Aujourd\'hui !'
                        : '📅 ${daysLeft}j',
                      daysLeft <= 1 ? Colors.red : AppColors.textSecondary,
                    ),
                ]),
              ],
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _info(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: TextStyle(
      color: color, fontSize: 11, fontWeight: FontWeight.w700)),
  );
}
