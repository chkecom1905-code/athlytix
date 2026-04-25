import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'main_navigation.dart';
import 'services/language_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await LanguageService.instance.init();
  runApp(const BallvynApp());
}

final supabase = Supabase.instance.client;

class BallvynApp extends StatelessWidget {
  const BallvynApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BALLVYN',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const _StartGate(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.card,
        background: AppColors.background,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: Colors.white, fontSize: 22,
          fontWeight: FontWeight.w800, letterSpacing: -0.8),
        iconTheme: const IconThemeData(color: Colors.white),
        surfaceTintColor: Colors.transparent,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}

class _StartGate extends StatefulWidget {
  const _StartGate();
  @override State<_StartGate> createState() => _StartGateState();
}

class _StartGateState extends State<_StartGate> {
  bool? _onboardingDone;

  @override void initState() { super.initState(); _check(); }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _onboardingDone = prefs.getBool('onboarding_done') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingDone == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    if (!_onboardingDone!) return const OnboardingScreen();
    return const AuthGate();
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (_, __) {
        final session = supabase.auth.currentSession;
        return session != null ? const MainNavigation() : const LoginScreen();
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
// DESIGN SYSTEM — AppColors v2 (glassmorphism + gradients)
// ══════════════════════════════════════════════════════════
class AppColors {
  // Core
  static const Color background  = Color(0xFF060610);
  static const Color bgDeep      = Color(0xFF03030A);
  static const Color card        = Color(0xFF0F0F1E);
  static const Color cardAlt     = Color(0xFF161628);
  static const Color cardGlass   = Color(0x1AFFFFFF);  // glassmorphism base
  static const Color border      = Color(0xFF1C1C30);
  static const Color borderLight = Color(0xFF252540);

  // Brand
  static const Color primary     = Color(0xFFFF6B00);
  static const Color primaryGlow = Color(0x33FF6B00);
  static const Color primarySoft = Color(0x1AFF6B00);
  static const Color secondary   = Color(0xFF7C3AED);
  static const Color secondaryGlow= Color(0x337C3AED);
  static const Color accent      = Color(0xFF00D4FF);
  static const Color accentGlow  = Color(0x2200D4FF);

  // State
  static const Color success     = Color(0xFF22C55E);
  static const Color successGlow = Color(0x2222C55E);
  static const Color warning     = Color(0xFFF59E0B);
  static const Color error       = Color(0xFFEF4444);

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textMuted     = Color(0xFF5A5A78);

  // ── Gradients ─────────────────────────────────────────
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFF9F00)],
    begin: Alignment.topLeft, end: Alignment.bottomRight);

  static const LinearGradient orangeGlow = LinearGradient(
    colors: [Color(0xFFFF8A00), Color(0xFFFF5500)],
    begin: Alignment.topLeft, end: Alignment.bottomRight);

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
    begin: Alignment.topLeft, end: Alignment.bottomRight);

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF0070F3)],
    begin: Alignment.topLeft, end: Alignment.bottomRight);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft, end: Alignment.bottomRight);

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft, end: Alignment.bottomRight);

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F0F1E), Color(0xFF060610)],
    begin: Alignment.topLeft, end: Alignment.bottomRight);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1A0A00), Color(0xFF060610)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter);

  // ── Glassmorphism ──────────────────────────────────────
  static BoxDecoration get glass => BoxDecoration(
    color: const Color(0x14FFFFFF),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
  );

  static BoxDecoration glassCard({double radius = 20, Color? color}) => BoxDecoration(
    color: color ?? const Color(0x0FFFFFFF),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0x15FFFFFF), width: 1),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
    ],
  );

  // ── Elevation shadows ──────────────────────────────────
  static List<BoxShadow> get orangeShadow => [
    BoxShadow(color: primary.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8)),
    BoxShadow(color: primary.withOpacity(0.1),  blurRadius: 8,  offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> get purpleShadow => [
    BoxShadow(color: secondary.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8)),
  ];
}

// ══════════════════════════════════════════════════════════
// TEXT STYLES — Premium Nike/Apple typography
// ══════════════════════════════════════════════════════════
class AppTextStyles {
  static TextStyle get display => GoogleFonts.inter(
    fontSize: 42, fontWeight: FontWeight.w900,
    color: AppColors.textPrimary, letterSpacing: -2.0, height: 1.0);

  static TextStyle get heading1 => GoogleFonts.inter(
    fontSize: 30, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, letterSpacing: -1.2, height: 1.1);

  static TextStyle get heading2 => GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, letterSpacing: -0.8);

  static TextStyle get heading3 => GoogleFonts.inter(
    fontSize: 17, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.3);

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary, height: 1.6);

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.5);

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textMuted);

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 10, fontWeight: FontWeight.w800,
    color: AppColors.textMuted, letterSpacing: 1.5);

  static TextStyle get micro => GoogleFonts.inter(
    fontSize: 9, fontWeight: FontWeight.w700,
    color: AppColors.textMuted, letterSpacing: 1.0);
}

// ══════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ══════════════════════════════════════════════════════════

/// Bouton gradient premium avec animation press
class GradientButton extends StatefulWidget {
  final String label;
  final Widget? icon;
  final LinearGradient gradient;
  final VoidCallback? onTap;
  final double height;
  final double radius;
  final List<BoxShadow>? shadows;
  final bool loading;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.gradient = AppColors.orangeGradient,
    this.onTap,
    this.height = 56,
    this.radius = 18,
    this.shadows,
    this.loading = false,
  });

  @override State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.96)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp:   (_) { _ctrl.reverse(); widget.onTap?.call(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.onTap == null
                ? const LinearGradient(colors: [Color(0xFF1C1C30), Color(0xFF1C1C30)])
                : widget.gradient,
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: widget.onTap == null ? null : (widget.shadows ?? AppColors.orangeShadow),
          ),
          child: Center(child: widget.loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 8)],
                Text(widget.label, style: GoogleFonts.inter(
                  color: widget.onTap == null ? AppColors.textMuted : Colors.white,
                  fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
              ]),
          ),
        ),
      ),
    );
  }
}

/// Chip badge premium
class AppChip extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;

  const AppChip(this.label, this.color, {super.key, this.fontSize = 11});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Text(label, style: TextStyle(
      color: color, fontSize: fontSize, fontWeight: FontWeight.w700)),
  );
}

/// Section header avec action optionnelle
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.heading3),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: TextStyle(
              color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600))),
      ],
    ),
  );
}
