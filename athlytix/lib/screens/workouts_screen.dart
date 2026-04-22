import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../services/xp_service.dart';
import '../widgets/shimmer_card.dart';
import 'workout_detail_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  final UserProfile? profile;
  final Function(UserProfile) onUpdate;

  const WorkoutsScreen({super.key, required this.profile, required this.onUpdate});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  List<Workout> _workouts = [];
  Set<String> _completed = {};
  bool _loading = true;
  String _filter = 'Tous';

  final _types = ['Tous', 'Dribble', 'Tir', 'Defense', 'Physique', 'Post'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await supabase.from('workouts').select().order('created_at');
      final done = await XpService.getCompletedWorkoutIds();
      final workouts = (data as List).map((e) => Workout.fromMap(e)).toList();
      for (final w in workouts) w.isCompleted = done.contains(w.id);
      if (mounted) setState(() { _workouts = workouts; _completed = done; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _complete(Workout w) async {
    if (w.isCompleted || widget.profile == null) return;
    HapticFeedback.mediumImpact();

    await XpService.markWorkoutComplete(w.id);
    final updated = await XpService.addXp(w.xpReward, widget.profile!);
    if (updated != null) widget.onUpdate(updated);

    setState(() { w.isCompleted = true; _completed.add(w.id); });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Text('⚡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text('+${w.xpReward} XP gagné !',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ]),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _openDetail(Workout w) {
    Navigator.push(context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => WorkoutDetailScreen(
          workout: w,
          profile: widget.profile,
          onUpdate: (updated) {
            widget.onUpdate(updated);
            setState(() { w.isCompleted = true; _completed.add(w.id); });
          },
        ),
        transitionsBuilder: (_, anim, __, child) =>
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  List<Workout> get _filtered => _filter == 'Tous'
      ? _workouts
      : _workouts.where((w) => w.type == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            _filters(),
            Expanded(
              child: _loading
                  ? const WorkoutListShimmer()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primary,
                      child: _filtered.isEmpty
                          ? _empty()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                              itemCount: _filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (_, i) => _WorkoutCard(
                                workout: _filtered[i],
                                onComplete: () => _complete(_filtered[i]),
                                onTap: () => _openDetail(_filtered[i]),
                              ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Workouts', style: AppTextStyles.heading2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGlow,
                borderRadius: BorderRadius.circular(20)),
              child: Text('${_completed.length}/${_workouts.length} faits',
                style: TextStyle(
                  color: AppColors.primary, fontSize: 12,
                  fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Appuie pour voir les détails.', style: AppTextStyles.body),
      ]),
    );
  }

  Widget _filters() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        itemCount: _types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final t = _types[i];
          final sel = _filter == t;
          return GestureDetector(
            onTap: () => setState(() => _filter = t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: sel ? AppColors.orangeGradient : null,
                color: sel ? null : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? Colors.transparent : AppColors.border)),
              child: Text(t, style: TextStyle(
                color: sel ? Colors.white : AppColors.textSecondary,
                fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          );
        },
      ),
    );
  }

  Widget _empty() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🏀', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('Aucun workout', style: AppTextStyles.heading3),
    ]),
  );
}

// ── Card ───────────────────────────────────────
class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onComplete;
  final VoidCallback onTap;

  const _WorkoutCard({
    required this.workout,
    required this.onComplete,
    required this.onTap,
  });

  Color get _diffColor {
    switch (workout.difficulty) {
      case 'Debutant': case 'Débutant': return AppColors.success;
      case 'Intermediaire': case 'Intermédiaire': return AppColors.warning;
      case 'Avance': case 'Avancé': return AppColors.primary;
      case 'Elite': case 'Élite': return AppColors.secondary;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: workout.isCompleted
              ? AppColors.success.withOpacity(0.07)
              : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: workout.isCompleted
                ? AppColors.success.withOpacity(0.3)
                : AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            // Emoji
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.cardAlt,
                borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(
                workout.emoji.isNotEmpty ? workout.emoji : '🏀',
                style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.title, style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(children: [
                  _chip(workout.type, AppColors.accent),
                  const SizedBox(width: 6),
                  _chip(workout.difficulty, _diffColor),
                  const SizedBox(width: 6),
                  _chip('${workout.durationMin}m', AppColors.textMuted),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Text('⚡', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text('+${workout.xpReward} XP', style: TextStyle(
                    color: AppColors.primary, fontSize: 12,
                    fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('Détails →', style: TextStyle(
                    color: AppColors.textMuted, fontSize: 11)),
                ]),
              ],
            )),
            const SizedBox(width: 10),
            // Check button
            workout.isCompleted
                ? Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                      color: AppColors.success, size: 20))
                : GestureDetector(
                    onTap: onComplete,
                    child: Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(
                        gradient: AppColors.orangeGradient,
                        shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 20))),
          ]),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(
      color: color, fontSize: 10, fontWeight: FontWeight.w600)),
  );
}
