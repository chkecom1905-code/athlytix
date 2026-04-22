import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/workouts_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/moves/moves_screen.dart';
import 'screens/duels/duels_screen.dart';
import 'screens/programs/programs_screen.dart';
import 'screens/coach/coach_ia_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  UserProfile? _profile;
  bool _loadingProfile = true;
  late AnimationController _badgeCtrl;

  @override
  void initState() {
    super.initState();
    _badgeCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 300));
    _fetchProfile();
  }

  @override void dispose() { _badgeCtrl.dispose(); super.dispose(); }

  Future<void> _fetchProfile() async {
    try {
      final data = await supabase
          .from('profiles').select()
          .eq('id', supabase.auth.currentUser!.id)
          .single();
      if (mounted) setState(() => _profile = UserProfile.fromMap(data));
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  void _onUpdate(UserProfile updated) {
    final prevTokens = _profile?.aiTokens ?? 0;
    setState(() => _profile = updated);
    if (updated.aiTokens != prevTokens) _badgeCtrl.forward(from: 0);
  }

  List<Widget> get _screens => [
    HomeScreen(profile: _profile, onUpdate: _onUpdate),
    WorkoutsScreen(profile: _profile, onUpdate: _onUpdate),
    MovesScreen(profile: _profile, onUpdate: _onUpdate),
    DuelsScreen(profile: _profile, onUpdate: _onUpdate),
    ProgramsScreen(profile: _profile, onUpdate: _onUpdate),
    CoachIaScreen(profile: _profile, onUpdate: _onUpdate),
    ProfileScreen(profile: _profile),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _index = i);
        },
        profile: _profile,
        badgeCtrl: _badgeCtrl,
      ),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int index;
  final Function(int) onTap;
  final UserProfile? profile;
  final AnimationController badgeCtrl;

  const _BottomNav({
    required this.index,
    required this.onTap,
    this.profile,
    required this.badgeCtrl,
  });

  static const _items = [
    _NavItem(icon: Icons.home_rounded,           label: 'Accueil'),
    _NavItem(icon: Icons.fitness_center_rounded, label: 'Train'),
    _NavItem(icon: Icons.videocam_rounded,        label: 'Moves'),
    _NavItem(icon: Icons.swords_rounded,          label: 'Duels'),
    _NavItem(icon: Icons.menu_book_rounded,       label: 'Progs'),
    _NavItem(icon: Icons.auto_awesome_rounded,    label: 'Coach IA', isCoach: true),
    _NavItem(icon: Icons.person_rounded,          label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(
          color: AppColors.border, width: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4),
            blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: _items.asMap().entries.map((e) {
              final i   = e.key;
              final sel = i == index;
              final item= e.value;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: sel
                                ? (item.isCoach
                                  ? AppColors.secondaryGlow
                                  : AppColors.primaryGlow)
                                : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(item.icon, size: 20,
                              color: sel
                                ? (item.isCoach
                                  ? AppColors.secondary : AppColors.primary)
                                : AppColors.textMuted),
                          ),
                          // Token badge for Coach IA
                          if (item.isCoach && (profile?.aiTokens ?? 0) > 0)
                            Positioned(
                              top: -4, right: -8,
                              child: ScaleTransition(
                                scale: Tween(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(parent: badgeCtrl,
                                    curve: Curves.elasticOut)),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.purpleGradient,
                                    borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    '${profile?.aiTokens ?? 0}',
                                    style: const TextStyle(
                                      color: Colors.white, fontSize: 8,
                                      fontWeight: FontWeight.w800))),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel
                            ? (item.isCoach
                              ? AppColors.secondary : AppColors.primary)
                            : AppColors.textMuted,
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final bool isCoach;
  const _NavItem({required this.icon, required this.label, this.isCoach = false});
}
