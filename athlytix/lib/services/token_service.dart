// lib/services/token_service.dart
import '../main.dart';
import '../models/user_model.dart';

/// Gère les tokens Coach IA : lecture, dépense, achat (Stripe stub)
class TokenService {
  static const int tokensPerAnalysis = 1;

  /// Pack definitions
  static const List<TokenPack> packs = [
    TokenPack(id: 's', label: 'Pack S', tokens: 50,  price: 4.99,  bonus: ''),
    TokenPack(id: 'm', label: 'Pack M', tokens: 120, price: 9.99,  bonus: '+ 20 BONUS'),
    TokenPack(id: 'l', label: 'Pack L', tokens: 300, price: 19.99, bonus: '+ 80 BONUS'),
  ];

  /// Refresh token count from Supabase
  static Future<int> getTokens() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return 0;
    final data = await supabase
        .from('profiles')
        .select('ai_tokens')
        .eq('id', uid)
        .single();
    return (data['ai_tokens'] as int?) ?? 0;
  }

  /// Spend 1 token for an analysis — returns false if no tokens
  static Future<bool> spendToken(UserProfile profile) async {
    if (profile.aiTokens <= 0) return false;
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return false;
    await supabase.from('profiles').update({
      'ai_tokens': profile.aiTokens - tokensPerAnalysis,
    }).eq('id', uid);
    return true;
  }

  /// Award tokens (after purchase) — returns new total
  static Future<int> addTokens(int amount) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return 0;
    final current = await getTokens();
    final newTotal = current + amount;
    await supabase.from('profiles').update({
      'ai_tokens': newTotal,
    }).eq('id', uid);
    return newTotal;
  }

  /// Save an AI analysis to history
  static Future<void> saveAnalysis({
    required String prompt,
    required String response,
    required String analysisType,
  }) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    await supabase.from('ai_analyses').insert({
      'user_id':       uid,
      'prompt':        prompt,
      'response':      response,
      'analysis_type': analysisType,
    });
  }

  /// Load history
  static Future<List<AiAnalysis>> getHistory({int limit = 20}) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];
    final data = await supabase
        .from('ai_analyses')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => AiAnalysis.fromMap(e)).toList();
  }
}

class TokenPack {
  final String id;
  final String label;
  final int tokens;
  final double price;
  final String bonus;

  const TokenPack({
    required this.id,
    required this.label,
    required this.tokens,
    required this.price,
    required this.bonus,
  });

  String get priceLabel => '${price.toStringAsFixed(2)}€';
}

class AiAnalysis {
  final String id;
  final String prompt;
  final String response;
  final String analysisType;
  final DateTime createdAt;

  const AiAnalysis({
    required this.id,
    required this.prompt,
    required this.response,
    required this.analysisType,
    required this.createdAt,
  });

  factory AiAnalysis.fromMap(Map<String, dynamic> m) => AiAnalysis(
    id:           m['id'] as String,
    prompt:       m['prompt'] as String? ?? '',
    response:     m['response'] as String? ?? '',
    analysisType: m['analysis_type'] as String? ?? 'general',
    createdAt:    DateTime.parse(m['created_at'] as String),
  );
}
