// lib/screens/auth/register_screen.dart
// Inscription en 2 étapes : compte → choix de langue

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {

  // ── Étapes ──────────────────────────────────────────
  int _step = 0; // 0 = compte, 1 = langue

  // ── Étape 0 — Compte ────────────────────────────────
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  bool _loading  = false;
  bool _obscure  = true;
  String? _error;

  // ── Étape 1 — Langue ────────────────────────────────
  AppLanguage _selectedLang = kSupportedLanguages.first; // français par défaut
  bool _savingLang = false;

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnim = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────

  Future<void> _nextStep() async {
    // Validation étape 0
    if (_emailCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.isEmpty ||
        _usernameCtrl.text.trim().isEmpty) {
      setState(() => _error = _t('fill_all'));
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      setState(() => _error = _t('password_short'));
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        username: _usernameCtrl.text.trim(),
      );
      if (mounted) {
        HapticFeedback.mediumImpact();
        setState(() { _step = 1; _loading = false; });
        _slideCtrl.forward(from: 0);
      }
    } catch (e) {
      if (mounted) setState(() {
        _error = _t('signup_error') + ': ${e.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _finishWithLanguage() async {
    setState(() => _savingLang = true);
    HapticFeedback.mediumImpact();
    await LanguageService.instance.setLanguage(_selectedLang);
    if (mounted) setState(() => _savingLang = false);
    // La navigation est gérée par AuthGate (stream Supabase)
  }

  // ── Traductions minimales (avant localisation complète) ──────
  String _t(String key) {
    final lang = _step == 1 ? _selectedLang.code : 'fr';
    const Map<String, Map<String, String>> translations = {
      'fill_all': { 'fr': 'Remplis tous les champs.', 'en': 'Fill in all fields.', 'es': 'Rellena todos los campos.', 'pt': 'Preencha todos os campos.', 'de': 'Fülle alle Felder aus.', 'it': 'Compila tutti i campi.', 'ar': 'أكمل جميع الحقول.', 'ja': 'すべての項目を入力してください。', 'zh': '请填写所有字段。', 'tr': 'Tüm alanları doldurun.', 'ru': 'Заполните все поля.', 'ko': '모든 항목을 입력하세요.' },
      'password_short': { 'fr': 'Mot de passe trop court (6 min).', 'en': 'Password too short (6 min).', 'es': 'Contraseña demasiado corta.', 'pt': 'Senha muito curta.', 'de': 'Passwort zu kurz (min. 6).', 'it': 'Password troppo corta.', 'ar': 'كلمة المرور قصيرة جداً.', 'ja': 'パスワードが短すぎます。', 'zh': '密码太短。', 'tr': 'Şifre çok kısa.', 'ru': 'Пароль слишком короткий.', 'ko': '비밀번호가 너무 짧습니다.' },
      'signup_error': { 'fr': 'Erreur à l\'inscription', 'en': 'Sign up error', 'es': 'Error al registrarse', 'pt': 'Erro ao se registrar', 'de': 'Anmeldefehler', 'it': 'Errore di registrazione', 'ar': 'خطأ في التسجيل', 'ja': '登録エラー', 'zh': '注册错误', 'tr': 'Kayıt hatası', 'ru': 'Ошибка регистрации', 'ko': '가입 오류' },
    };
    return translations[key]?[lang] ?? translations[key]?['fr'] ?? key;
  }

  // ── UI ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _step == 0
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: SafeArea(
        child: _step == 0 ? _buildStep0() : _buildStep1(),
      ),
    );
  }

  // ─── ÉTAPE 0 — Formulaire d'inscription ──────────────────────
  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 24),

        // Logo + titre
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: Text('🏀', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BALLVYN', style: GoogleFonts.inter(
              color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900,
              letterSpacing: 1)),
            Text('Crée ton compte', style: AppTextStyles.caption),
          ]),
        ]),

        const SizedBox(height: 32),
        Text('Rejoins la communauté', style: AppTextStyles.heading2),
        const SizedBox(height: 6),
        Text('Une dernière étape : le choix de ta langue.', style: AppTextStyles.body),
        const SizedBox(height: 32),

        // Indicateurs d'étapes
        _stepIndicator(),
        const SizedBox(height: 32),

        // Champs
        _field(_usernameCtrl, 'Pseudo', Icons.person_outline),
        const SizedBox(height: 14),
        _field(_emailCtrl, 'Email', Icons.email_outlined,
            keyboard: TextInputType.emailAddress),
        const SizedBox(height: 14),
        _field(_passwordCtrl, 'Mot de passe', Icons.lock_outline,
            obscure: _obscure,
            suffix: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textMuted, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            )),
        const SizedBox(height: 16),

        if (_error != null) _banner(_error!, Colors.red, Icons.error_outline),
        const SizedBox(height: 8),

        // Bouton suivant
        SizedBox(
          width: double.infinity, height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20, offset: const Offset(0, 8),
              )],
            ),
            child: ElevatedButton(
              onPressed: _loading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _loading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Continuer', style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ]),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  // ─── ÉTAPE 1 — Sélection de langue ───────────────────────────
  Widget _buildStep1() {
    return SlideTransition(
      position: _slideAnim,
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [const Color(0xFF1A0A3A), AppColors.background],
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Badge "Étape 2"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Étape 2 / 2', style: GoogleFonts.inter(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 14),
            Text('Choisis ta langue', style: AppTextStyles.heading2),
            const SizedBox(height: 6),
            Text(
              'L\'app s\'adaptera à ta langue.\nTu pourras la changer à tout moment dans les paramètres.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            _stepIndicator(step: 1),
          ]),
        ),

        // Grille de langues
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: kSupportedLanguages.length,
              itemBuilder: (_, i) => _langTile(kSupportedLanguages[i]),
            ),
          ),
        ),

        // Bouton Terminer
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(children: [
            // Langue sélectionnée
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Row(children: [
                Text(_selectedLang.flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_selectedLang.name, style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(_selectedLang.nativeName, style: AppTextStyles.caption),
                ]),
                const Spacer(),
                Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 20),
              ]),
            ),

            // CTA
            SizedBox(
              width: double.infinity, height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                    color: AppColors.secondary.withOpacity(0.4),
                    blurRadius: 20, offset: const Offset(0, 8),
                  )],
                ),
                child: ElevatedButton(
                  onPressed: _savingLang ? null : _finishWithLanguage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _savingLang
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(_selectedLang.flag, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Text('Démarrer BALLVYN', style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(width: 8),
                          const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 18),
                        ]),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Tuile langue ─────────────────────────────────────────────
  Widget _langTile(AppLanguage lang) {
    final selected = _selectedLang.code == lang.code;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedLang = lang);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary.withOpacity(0.15)
              : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.secondary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(
                  color: AppColors.secondary.withOpacity(0.2),
                  blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Stack(children: [
          Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(lang.flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(lang.nativeName, style: GoogleFonts.inter(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              Text(lang.name, style: GoogleFonts.inter(
                color: selected ? AppColors.secondary : AppColors.textMuted,
                fontSize: 9, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
          // Checkmark
          if (selected)
            Positioned(
              top: 6, right: 6,
              child: Container(
                width: 18, height: 18,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 11),
              ),
            ),
        ]),
      ),
    );
  }

  // ── Indicateur d'étapes ──────────────────────────────────────
  Widget _stepIndicator({int step = 0}) {
    return Row(children: [
      _stepDot(0, 'Compte', step),
      Expanded(child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: step >= 1 ? AppColors.purpleGradient : const LinearGradient(colors: [Color(0xFF1E1E32), Color(0xFF1E1E32)]),
          borderRadius: BorderRadius.circular(2),
        ),
      )),
      _stepDot(1, 'Langue', step),
    ]);
  }

  Widget _stepDot(int index, String label, int current) {
    final done   = current > index;
    final active = current == index;
    return Column(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28, height: 28,
        decoration: BoxDecoration(
          gradient: done || active ? AppColors.purpleGradient : null,
          color: done || active ? null : AppColors.card,
          shape: BoxShape.circle,
          border: Border.all(
            color: done || active ? Colors.transparent : AppColors.border,
          ),
        ),
        child: Center(child: done
            ? const Icon(Icons.check, color: Colors.white, size: 14)
            : Text('${index + 1}', style: GoogleFonts.inter(
                color: active ? Colors.white : AppColors.textMuted,
                fontSize: 12, fontWeight: FontWeight.w700))),
      ),
      const SizedBox(height: 4),
      Text(label, style: GoogleFonts.inter(
        color: active || done ? AppColors.secondary : AppColors.textMuted,
        fontSize: 10, fontWeight: FontWeight.w600)),
    ]);
  }

  // ── Champ texte ──────────────────────────────────────────────
  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType? keyboard, bool obscure = false, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _banner(String msg, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg, style: TextStyle(color: color, fontSize: 13))),
      ]),
    );
  }
}
