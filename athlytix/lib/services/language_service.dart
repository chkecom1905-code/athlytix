// lib/services/language_service.dart
// Gestion de la langue de l'application

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

// ── Langues disponibles ─────────────────────────────────────────
class AppLanguage {
  final String code;      // 'fr', 'en', 'es'…
  final String name;      // 'Français', 'English'…
  final String nativeName;// nom dans la langue elle-même
  final String flag;      // emoji drapeau
  final String locale;    // 'fr_FR', 'en_US'…

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.locale,
  });
}

const List<AppLanguage> kSupportedLanguages = [
  AppLanguage(code: 'fr', name: 'Français',    nativeName: 'Français',    flag: '🇫🇷', locale: 'fr_FR'),
  AppLanguage(code: 'en', name: 'English',     nativeName: 'English',     flag: '🇬🇧', locale: 'en_GB'),
  AppLanguage(code: 'es', name: 'Espagnol',    nativeName: 'Español',     flag: '🇪🇸', locale: 'es_ES'),
  AppLanguage(code: 'pt', name: 'Portugais',   nativeName: 'Português',   flag: '🇧🇷', locale: 'pt_BR'),
  AppLanguage(code: 'de', name: 'Allemand',    nativeName: 'Deutsch',     flag: '🇩🇪', locale: 'de_DE'),
  AppLanguage(code: 'it', name: 'Italien',     nativeName: 'Italiano',    flag: '🇮🇹', locale: 'it_IT'),
  AppLanguage(code: 'ar', name: 'Arabe',       nativeName: 'العربية',     flag: '🇸🇦', locale: 'ar_SA'),
  AppLanguage(code: 'ja', name: 'Japonais',    nativeName: '日本語',       flag: '🇯🇵', locale: 'ja_JP'),
  AppLanguage(code: 'zh', name: 'Chinois',     nativeName: '中文',        flag: '🇨🇳', locale: 'zh_CN'),
  AppLanguage(code: 'tr', name: 'Turc',        nativeName: 'Türkçe',      flag: '🇹🇷', locale: 'tr_TR'),
  AppLanguage(code: 'ru', name: 'Russe',       nativeName: 'Русский',     flag: '🇷🇺', locale: 'ru_RU'),
  AppLanguage(code: 'ko', name: 'Coréen',      nativeName: '한국어',       flag: '🇰🇷', locale: 'ko_KR'),
];

AppLanguage getLanguageByCode(String code) =>
    kSupportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => kSupportedLanguages.first,
    );

// ── LanguageService ─────────────────────────────────────────────
class LanguageService extends ChangeNotifier {
  static const _key = 'app_language_code';
  static LanguageService? _instance;
  static LanguageService get instance => _instance ??= LanguageService._();
  LanguageService._();

  AppLanguage _current = kSupportedLanguages.first; // défaut : français
  AppLanguage get current => _current;
  Locale get locale => Locale(_current.code, _current.locale.split('_').last);

  // Charger depuis SharedPreferences (au démarrage de l'app)
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) {
      _current = getLanguageByCode(code);
      notifyListeners();
    }
  }

  // Changer et persister la langue
  Future<void> setLanguage(AppLanguage lang) async {
    _current = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, lang.code);
    // Sauvegarder dans Supabase si l'utilisateur est connecté
    final uid = supabase.auth.currentUser?.id;
    if (uid != null) {
      await supabase
          .from('profiles')
          .update({'language': lang.code})
          .eq('id', uid);
    }
    notifyListeners();
  }

  // Charger depuis Supabase (après login)
  Future<void> loadFromProfile() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final data = await supabase
          .from('profiles')
          .select('language')
          .eq('id', uid)
          .single();
      final code = data['language'] as String?;
      if (code != null && code.isNotEmpty) {
        _current = getLanguageByCode(code);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_key, code);
        notifyListeners();
      }
    } catch (_) {}
  }
}
