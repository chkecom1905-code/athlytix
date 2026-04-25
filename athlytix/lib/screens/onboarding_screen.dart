import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  late AnimationController _bgCtrl;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  static const _slides = [
    _Slide(
      emoji: '🏀',
      title: 'Bienvenue\nsur ATHLYTIX',
      subtitle: 'L\'app de progression basket conçue\npour les vrais compétiteurs.',
      gradient: AppColors.orangeGradient,
      accentColor: AppColors.primary,
    ),
    _Slide(
      emoji: '⚡',
      title: 'Gagne de\nl\'XP',
      subtitle: 'Complète des workouts, relève des défis\net monte en niveau chaque jour.',
      gradient: AppColors.purpleGradient,
      accentColor: AppColors.secondary,
    ),
    _Slide(
      emoji: '🏆',
      title: 'Deviens\nÉlite',
      subtitle: 'Suis ta progression, casse tes records\net atteins ton niveau maximum.',
      gradient: AppColors.blueGradient,
      accentColor: AppColors.accent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));
    _slideCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _bgCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_page < _slides.length - 1) {
      _slideCtrl.reset();
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _slideCtrl.forward();
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated gradient background blob
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top: -60,
            right: _page == 0 ? -40 : (_page == 1 ? 40 : -80),
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _slides[_page].gradient,
                // ignore: deprecated_member_use
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 20, 0),
                    child: TextButton(
                      onPressed: _skip,
                      child: Text('Passer',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted)),
                    ),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: _slides.length,
                    itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
                  ),
                ),

                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    final sel = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: sel ? 28 : 8, height: 8,
                      decoration: BoxDecoration(
                        color: sel
                            ? _slides[_page].accentColor
                            : AppColors.textMuted.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 32),

                // CTA button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity, height: 58,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: _slides[_page].gradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(
                          color: _slides[_page].accentColor.withOpacity(0.35),
                          blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18))),
                        child: Text(
                          _page < _slides.length - 1
                              ? 'Suivant →'
                              : 'C\'est parti 🔥',
                          style: GoogleFonts.inter(
                            fontSize: 17, fontWeight: FontWeight.w800,
                            color: Colors.white)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              gradient: slide.gradient,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: slide.accentColor.withOpacity(0.3), blurRadius: 30)],
            ),
            child: Center(
              child: Text(slide.emoji,
                style: const TextStyle(fontSize: 56))),
          ),
          const SizedBox(height: 36),
          Text(slide.title,
            style: GoogleFonts.inter(
              color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900,
              letterSpacing: -1.2, height: 1.1),
            textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(slide.subtitle,
            style: AppTextStyles.body.copyWith(fontSize: 16, height: 1.6),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Slide {
  final String emoji;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final Color accentColor;

  const _Slide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.accentColor,
  });
}
