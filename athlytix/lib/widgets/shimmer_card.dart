import 'package:flutter/material.dart';
import '../main.dart';

/// Shimmer skeleton used across list screens while loading from Supabase.
class ShimmerCard extends StatefulWidget {
  final double height;
  final double? width;
  final double radius;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.width,
    this.radius = 20,
  });

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + _anim.value * 3, 0),
              end: Alignment(-0.5 + _anim.value * 3, 0),
              colors: const [
                Color(0xFF12121E),
                Color(0xFF1E1E32),
                Color(0xFF12121E),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Full workout list skeleton
class WorkoutListShimmer extends StatelessWidget {
  const WorkoutListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: 5,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const ShimmerCard(height: 100),
    );
  }
}

/// Challenge list skeleton
class ChallengeListShimmer extends StatelessWidget {
  const ChallengeListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: 4,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const ShimmerCard(height: 140),
    );
  }
}

/// Row of small shimmer stat tiles
class StatsRowShimmer extends StatelessWidget {
  const StatsRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
          child: const ShimmerCard(height: 76, radius: 16),
        ),
      )),
    );
  }
}
