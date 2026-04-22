import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../services/xp_service.dart';
import '../widgets/levelup_dialog.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;
  final UserProfile? profile;
  final Function(UserProfile) onUpdate;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
    required this.profile,
    required this.onUpdate,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen>
    with TickerProviderStateMixin {
  // Timer state
  late int _totalSeconds;
  int _remaining = 0;
  bool _running = false;
  bool _finished = false;
  Timer? _timer;

  // Animations
  late AnimationController _pulseCtrl;
  late AnimationController _checkCtrl;
  late Animation<double> _checkAnim;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.workout.durationMin * 60;
    _remaining = _totalSeconds;

    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _checkCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
    _checkAnim = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    _checkCtrl.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    HapticFeedback.lightImpact();
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remaining <= 1) {
          _timer?.cancel();
          setState(() { _remaining = 0; _running = false; _finished = true; });
          HapticFeedback.heavyImpact();
          _checkCtrl.forward();
        } else {
          setState(() => _remaining--);
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _checkCtrl.reset();
    setState(() { _remaining = _totalSeconds; _running = false; _finished = false; });
  }

  String get _timeDisplay {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress => 1 - (_remaining / _totalSeconds);

  Future<void> _complete() async {
    if (widget.workout.isCompleted || widget.profile == null) return;
    HapticFeedback.heavyImpact();

    final oldLevel = widget.profile!.level;
    await XpService.markWorkoutComplete(widget.workout.id);
    final updated = await XpService.addXp(widget.workout.xpReward, widget.profile!);
    if (updated == null) return;

    widget.onUpdate(updated);
    setState(() => widget.workout.isCompleted = true);

    if (!mounted) return;

    final didLevelUp = updated.level > oldLevel;
    if (didLevelUp) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => LevelUpDialog(
          newLevel: updated.level,
          xp: updated.xp,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Text('⚡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text('+${widget.workout.xpReward} XP gagné !',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildInfo(),
                  const SizedBox(height: 28),
                  _buildTimer(),
                  const SizedBox(height: 28),
                  _buildExercises(),
                  const SizedBox(height: 28),
                  _buildCompleteButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black38, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.7),
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
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, child) => Transform.scale(
                    scale: 1.0 + (_pulseCtrl.value * 0.08),
                    child: child,
                  ),
                  child: Text(widget.workout.emoji.isNotEmpty
                    ? widget.workout.emoji : '🏀',
                    style: const TextStyle(fontSize: 72)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _chip(widget.workout.type, AppColors.accent),
          const SizedBox(width: 8),
          _chip(widget.workout.difficulty, _diffColor()),
          const SizedBox(width: 8),
          _chip('${widget.workout.durationMin} min', AppColors.textMuted),
        ]),
        const SizedBox(height: 12),
        Text(widget.workout.title, style: AppTextStyles.heading1),
        const SizedBox(height: 8),
        Text(widget.workout.description.isNotEmpty
          ? widget.workout.description
          : 'Donne le meilleur de toi-même sur ce workout.',
          style: AppTextStyles.body),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryGlow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('⚡', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text('Récompense : +${widget.workout.xpReward} XP',
              style: TextStyle(
                color: AppColors.primary, fontSize: 14,
                fontWeight: FontWeight.w700)),
          ]),
        ),
      ],
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Text('MINUTEUR', style: AppTextStyles.label),
        const SizedBox(height: 20),
        CircularPercentIndicator(
          radius: 90,
          lineWidth: 10,
          percent: _progress.clamp(0.0, 1.0),
          backgroundColor: AppColors.border,
          linearGradient: AppColors.orangeGradient,
          circularStrokeCap: CircularStrokeCap.round,
          center: _finished
            ? ScaleTransition(
                scale: _checkAnim,
                child: const Icon(Icons.check_rounded,
                  color: AppColors.success, size: 60),
              )
            : Text(_timeDisplay,
                style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 36,
                  fontWeight: FontWeight.w800, letterSpacing: -1)),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_finished) ...[
              _timerBtn(
                icon: _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                gradient: AppColors.orangeGradient,
                size: 64,
                onTap: _toggleTimer,
              ),
              const SizedBox(width: 16),
            ],
            _timerBtn(
              icon: Icons.refresh_rounded,
              gradient: const LinearGradient(colors: [Color(0xFF1E1E32), Color(0xFF1E1E32)]),
              size: 48,
              onTap: _resetTimer,
            ),
          ],
        ),
      ]),
    );
  }

  Widget _timerBtn({
    required IconData icon,
    required LinearGradient gradient,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          gradient: gradient, shape: BoxShape.circle,
          boxShadow: [BoxShadow(
            color: AppColors.primary.withOpacity(0.25), blurRadius: 12)],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }

  Widget _buildExercises() {
    final exercises = _exercisesFor(widget.workout.type, widget.workout.difficulty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Exercices', style: AppTextStyles.heading3),
        const SizedBox(height: 14),
        ...exercises.asMap().entries.map((e) => _ExerciseItem(
          index: e.key + 1,
          exercise: e.value,
        )),
      ],
    );
  }

  Widget _buildCompleteButton() {
    final done = widget.workout.isCompleted;
    return SizedBox(
      width: double.infinity, height: 58,
      child: done
        ? Container(
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.success.withOpacity(0.4)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 22),
              const SizedBox(width: 10),
              Text('Workout terminé !',
                style: GoogleFonts.inter(
                  color: AppColors.success, fontSize: 16,
                  fontWeight: FontWeight.w700)),
            ]),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(
                color: AppColors.primary.withOpacity(0.45),
                blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: ElevatedButton.icon(
              onPressed: _complete,
              icon: const Icon(Icons.check_rounded, color: Colors.white),
              label: Text('Marquer comme terminé',
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

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(
        color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  Color _diffColor() {
    switch (widget.workout.difficulty) {
      case 'Debutant': case 'Débutant': return AppColors.success;
      case 'Intermediaire': case 'Intermédiaire': return AppColors.warning;
      case 'Avance': case 'Avancé': return AppColors.primary;
      case 'Elite': case 'Élite': return AppColors.secondary;
      default: return AppColors.textMuted;
    }
  }

  List<Map<String, String>> _exercisesFor(String type, String diff) {
    final map = {
      'Dribble': [
        {'name': 'Dribble stationnaire', 'reps': '3 x 30s chaque main'},
        {'name': 'Crossover bas', 'reps': '4 x 20 reps'},
        {'name': 'Figure-8', 'reps': '3 x 30s'},
        {'name': 'Spider dribble', 'reps': '3 x 45s'},
      ],
      'Tir': [
        {'name': 'Tirs en lay-up', 'reps': '5 x 10 reps chaque côté'},
        {'name': 'Mid-range face panier', 'reps': '4 x 15 tirs'},
        {'name': 'Corner 3 points', 'reps': '3 x 10 tirs'},
        {'name': 'Pull-up jumper', 'reps': '4 x 12 tirs'},
      ],
      'Defense': [
        {'name': 'Defensive slide', 'reps': '4 x 30s'},
        {'name': 'Close-out', 'reps': '3 x 10 reps'},
        {'name': 'Rotations défensives', 'reps': '3 x 2 min'},
      ],
      'Physique': [
        {'name': 'Box jumps', 'reps': '4 x 10 reps'},
        {'name': 'Lateral bounds', 'reps': '3 x 12 reps'},
        {'name': 'Broad jumps', 'reps': '3 x 8 reps'},
        {'name': 'Sprint 20m', 'reps': '6 x sprints'},
      ],
      'Post': [
        {'name': 'Pivot face panier', 'reps': '4 x 10 reps'},
        {'name': 'Drop step', 'reps': '3 x 10 reps chaque côté'},
        {'name': 'Up & under', 'reps': '3 x 8 reps'},
        {'name': 'Baby hook', 'reps': '4 x 12 reps'},
      ],
    };
    return (map[type] ?? [
      {'name': 'Échauffement', 'reps': '5 min'},
      {'name': 'Exercice principal', 'reps': '4 x 10 reps'},
      {'name': 'Récupération active', 'reps': '5 min'},
    ]).cast<Map<String, String>>();
  }
}

class _ExerciseItem extends StatelessWidget {
  final int index;
  final Map<String, String> exercise;
  const _ExerciseItem({required this.index, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            gradient: AppColors.orangeGradient, shape: BoxShape.circle),
          child: Center(child: Text('$index',
            style: const TextStyle(color: Colors.white, fontSize: 13,
              fontWeight: FontWeight.w800))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise['name'] ?? '', style: GoogleFonts.inter(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            Text(exercise['reps'] ?? '', style: AppTextStyles.body.copyWith(fontSize: 12)),
          ],
        )),
        const Icon(Icons.fitness_center_rounded,
          color: AppColors.textMuted, size: 16),
      ]),
    );
  }
}
