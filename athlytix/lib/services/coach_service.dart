// lib/services/coach_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

/// Calls Anthropic Claude API to generate personalized basketball coaching
class CoachService {
  // Route via your Supabase Edge Function to keep the API key server-side
  static const String _edgeFnUrl =
      'YOUR_SUPABASE_URL/functions/v1/coach-ia';

  static const String _systemPrompt = '''
Tu es COACH ATHLYTIX, un coach basketball IA d'élite.
Tu combines les méthodes des meilleurs coaches NBA (Phil Jackson, Gregg Popovich, etc.) 
avec une analyse biomécanique poussée.

Règles :
- Réponses concises, percutantes, actionnables (style Nike)
- Utilise des emojis sparingly (🏀⚡💪🎯)
- Structure : diagnostic → plan concret → tip mental
- Ton : coach exigeant mais motivant
- Maximum 300 mots par réponse
- Toujours finir par 1 action concrète à faire AUJOURD'HUI
''';

  /// Generate a coaching analysis
  static Future<String> analyze({
    required CoachAnalysisRequest request,
    required UserProfile profile,
  }) async {
    final prompt = _buildPrompt(request, profile);

    // Try Supabase Edge Function first (production)
    try {
      final response = await http.post(
        Uri.parse(_edgeFnUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_SUPABASE_ANON_KEY',
        },
        body: jsonEncode({'prompt': prompt, 'system': _systemPrompt}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'] as String? ?? _fallbackResponse(request);
      }
    } catch (_) {}

    // Fallback: rich local response based on analysis type
    return _fallbackResponse(request);
  }

  static String _buildPrompt(CoachAnalysisRequest req, UserProfile profile) {
    final sb = StringBuffer();
    sb.writeln('JOUEUR : ${profile.username} — Niveau ${profile.level} (${profile.levelTitle})');
    sb.writeln('XP Total : ${profile.xp} | Streak : ${profile.streak} jours');
    sb.writeln('');
    sb.writeln('TYPE D\'ANALYSE : ${req.type.label}');
    sb.writeln('');

    if (req.type == AnalysisType.match) {
      sb.writeln('STATS DU MATCH :');
      for (final e in req.stats.entries) {
        sb.writeln('  ${e.key}: ${e.value}');
      }
    } else if (req.type == AnalysisType.training) {
      sb.writeln('SESSION D\'ENTRAÎNEMENT :');
      sb.writeln('  Type : ${req.stats['type'] ?? 'Général'}');
      sb.writeln('  Durée : ${req.stats['duration'] ?? '60 min'}');
      sb.writeln('  Intensité : ${req.stats['intensity'] ?? '7/10'}');
      sb.writeln('  Notes : ${req.notes}');
    } else if (req.type == AnalysisType.weaknesses) {
      sb.writeln('POINTS FAIBLES DÉCLARÉS : ${req.notes}');
    } else {
      sb.writeln('DEMANDE : ${req.notes}');
    }

    sb.writeln('');
    sb.writeln('Analyse ce joueur et fournis un plan d\'action précis.');
    return sb.toString();
  }

  static String _fallbackResponse(CoachAnalysisRequest req) {
    final responses = <AnalysisType, String>{
      AnalysisType.match: '''⚡ **ANALYSE DE MATCH**

🎯 **Diagnostic**
Tes stats révèlent un déséquilibre : tu crées du jeu mais la conversion reste le maillon faible. C'est souvent un problème de décision dans les 2 dernières secondes.

💪 **Plan 7 jours**
Lun/Mer/Ven : 200 tirs par session depuis tes zones chaudes
Mar/Jeu : Drills de décision (3v3 contraints, shot clock 5s)
Sam : Simulation match complet

🧠 **Tip Mental**
Les meilleurs joueurs ne pensent pas — ils réagissent. Répète jusqu'à automatiser.

**ACTION AUJOURD'HUI →** 50 pull-up jumpers depuis le milieu. Aucun loupé accepté mentalement.''',

      AnalysisType.training: '''🏀 **ANALYSE D'ENTRAÎNEMENT**

🎯 **Diagnostic**
Session correcte mais l'intensité doit monter d'un cran. La progression vient des séances inconfortables, pas des séances confortables.

💪 **Optimisation**
→ Ajoute 20% de volume sur tes points forts
→ Dédie 30% du temps à tes faiblesses (zone de discomfort)
→ Finish TOUJOURS par des sprints — l'endurance se gagne en fin de session

🔥 **Protocole de récupération**
Sommeil 8h minimum · Protéines dans les 30min · Foam rolling 10min

**ACTION AUJOURD'HUI →** Identifie ta faiblesse n°1 et fais 30 min dessus ce soir.''',

      AnalysisType.weaknesses: '''⚡ **PLAN ANTI-FAIBLESSES**

🎯 **La réalité**
Les faiblesses ne disparaissent pas — elles se transforment en forces si tu les travailles correctement.

💪 **Protocole 30 jours**
Semaines 1-2 : Fondamentaux ciblés (répétitions lentes, parfaites)
Semaines 3-4 : Vitesse d'exécution + situations de match

📊 **Mesure ton progrès**
Film-toi chaque semaine au même exercice. Les données ne mentent pas.

🧠 **Mindset**
Kobe Bryant a travaillé son jeu de pied pendant 2 ans entiers. La patience est une compétence.

**ACTION AUJOURD'HUI →** 3 exercices ciblés sur ta faiblesse principale. 45 minutes. Chronomètre.''',

      AnalysisType.program: '''📋 **PROGRAMME PERSONNALISÉ**

🎯 **Évaluation**
Niveau ${req.stats['level'] ?? 'intermédiaire'} · Objectif : progression maximale

💪 **Structure hebdomadaire optimale**
Lun : Tir + Finitions (60 min)
Mar : Dribble + Création (45 min)
Mer : Récupération active
Jeu : Physique + Explosivité (50 min)
Ven : Défense + Lectures (45 min)
Sam : Jeu libre / compétition
Dim : Repos

⚡ **Indicateur de progression**
Mesure 1 stat clé par semaine. Si pas d'amélioration en 2 semaines → change le protocole.

**ACTION AUJOURD'HUI →** Choisis ton objectif n°1 pour les 30 prochains jours. Écris-le.''',
    };

    return responses[req.type] ?? responses[AnalysisType.match]!;
  }
}

// ── Request model ──────────────────────────────────────────
enum AnalysisType {
  match('Analyse de match'),
  training('Analyse d\'entraînement'),
  weaknesses('Améliorer mes faiblesses'),
  program('Créer mon programme');

  final String label;
  const AnalysisType(this.label);
}

class CoachAnalysisRequest {
  final AnalysisType type;
  final Map<String, String> stats;
  final String notes;

  const CoachAnalysisRequest({
    required this.type,
    this.stats = const {},
    this.notes = '',
  });
}
