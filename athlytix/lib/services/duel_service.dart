// lib/services/duel_service.dart
// Duels Realtime + matchmaking par thème + matchs privés avec code

import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../models/duel_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

// Thèmes de duel disponibles
class DuelTheme {
  final String id;
  final String label;
  final String emoji;
  final String description;
  const DuelTheme({required this.id, required this.label, required this.emoji, required this.description});

  static const List<DuelTheme> all = [
    DuelTheme(id:'Tir',      label:'Tir',           emoji:'🎯', description:'Questions sur la mécanique et les techniques de tir'),
    DuelTheme(id:'Dribble',  label:'Dribble',        emoji:'🏀', description:'Ball-handling, moves et creation off dribble'),
    DuelTheme(id:'Defense',  label:'Défense',        emoji:'🛡️', description:'Stance, help defense et anticipation'),
    DuelTheme(id:'IQ',       label:'IQ Basket',      emoji:'🧠', description:'Tactique, lecture du jeu et fondamentaux'),
    DuelTheme(id:'Dunks',    label:'Dunks & Détente', emoji:'🔥', description:'Athletisme, dunks et explosivité'),
    DuelTheme(id:'Mixte',    label:'Mixte',           emoji:'⚡', description:'Toutes les catégories mélangées'),
  ];

  static DuelTheme byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => all.last);
}

// ── Générateur de code privé ───────────────────────────────────
String _generateRoomCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rng = Random.secure();
  return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
}

class DuelService {
  static RealtimeChannel? _channel;

  // ── Créer un match PRIVÉ ───────────────────────────────────
  static Future<({String duelId, String code})?> createPrivateDuel({
    required String skillType,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final code = _generateRoomCode();
    final res = await supabase.from('duels').insert({
      'player1_id': userId,
      'is_bot':     false,
      'status':     'waiting',
      'skill_type': skillType,
      'duel_theme': skillType,
      'room_code':  code,
      'is_private': true,
      'xp_reward':  200,
    }).select().single();

    return (duelId: res['id'] as String, code: code);
  }

  // ── Rejoindre un match PRIVÉ par code ─────────────────────
  static Future<Duel?> joinPrivateDuel({required String code}) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final waiting = await supabase
        .from('duels')
        .select()
        .eq('room_code', code.toUpperCase())
        .eq('status', 'waiting')
        .maybeSingle();

    if (waiting == null) return null;
    if (waiting['player1_id'] == userId) return null; // ne peut pas jouer contre soi

    await supabase.from('duels').update({
      'player2_id': userId,
      'status':     'active',
    }).eq('id', waiting['id']);

    final updated = await supabase
        .from('duels')
        .select()
        .eq('id', waiting['id'])
        .single();
    return Duel.fromMap(updated);
  }

  // ── Trouver ou créer un duel PUBLIC par thème ─────────────
  static Future<Duel?> findOrCreateDuel({
    required bool vsBot,
    int botLevel = 1,
    required String skillType,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    if (vsBot) {
      final res = await supabase.from('duels').insert({
        'player1_id': userId,
        'is_bot':     true,
        'bot_level':  botLevel,
        'status':     'active',
        'skill_type': skillType,
        'duel_theme': skillType,
        'is_private': false,
        'xp_reward':  100 + botLevel * 25,
      }).select().single();
      return Duel.fromMap(res);
    }

    // Chercher un duel en attente avec le MÊME thème
    final waiting = await supabase
        .from('duels')
        .select()
        .eq('status', 'waiting')
        .eq('skill_type', skillType)
        .eq('is_bot', false)
        .eq('is_private', false)
        .neq('player1_id', userId)
        .limit(1)
        .maybeSingle();

    if (waiting != null) {
      await supabase.from('duels').update({
        'player2_id': userId,
        'status':     'active',
      }).eq('id', waiting['id']);

      final updated = await supabase
          .from('duels').select().eq('id', waiting['id']).single();
      return Duel.fromMap(updated);
    }

    // Créer un nouveau duel en attente
    final res = await supabase.from('duels').insert({
      'player1_id': userId,
      'is_bot':     false,
      'status':     'waiting',
      'skill_type': skillType,
      'duel_theme': skillType,
      'is_private': false,
      'xp_reward':  150,
    }).select().single();
    return Duel.fromMap(res);
  }

  // ── Annuler la recherche de duel ──────────────────────────
  static Future<void> cancelSearch(String duelId) async {
    await supabase.from('duels')
        .update({'status': 'cancelled'})
        .eq('id', duelId);
  }

  // ── Soumettre son score ───────────────────────────────────
  static Future<void> submitScore(String duelId, int score, bool isPlayer1) async {
    final field = isPlayer1 ? 'player1_score' : 'player2_score';
    await supabase.from('duels').update({field: score}).eq('id', duelId);
  }

  // ── Terminer le duel ─────────────────────────────────────
  static Future<Duel?> finishDuel(String duelId, UserProfile profile) async {
    final raw = await supabase.from('duels').select().eq('id', duelId).single();
    final duel = Duel.fromMap(raw);
    final myId = supabase.auth.currentUser?.id;
    final isPlayer1 = duel.player1Id == myId;

    int myScore  = isPlayer1 ? duel.player1Score : duel.player2Score;
    int oppScore;

    if (duel.isBot) {
      final botBase = duel.botLevel * 15;
      oppScore = (botBase + Random().nextInt(20)).clamp(0, 100);
    } else {
      oppScore = isPlayer1 ? duel.player2Score : duel.player1Score;
    }

    final winnerId = myScore >= oppScore ? myId : duel.player2Id;

    await supabase.from('duels').update({
      'status':     'finished',
      'winner_id':  winnerId,
      'finished_at': DateTime.now().toIso8601String(),
      if (duel.isBot) 'player2_score': oppScore,
    }).eq('id', duelId);

    final won = winnerId == myId;
    await supabase.from('profiles').update({
      'duels_played': profile.duelsPlayed + 1,
      if (won) 'duels_won': profile.duelsWon + 1,
      if (won) 'duel_points': (profile.duelPoints) + 10,
    }).eq('id', myId!);

    if (won) await XpService.addXp(duel.xpReward, profile);

    final updated = await supabase.from('duels').select().eq('id', duelId).single();
    return Duel.fromMap(updated);
  }

  // ── Realtime listener ────────────────────────────────────
  static void listenToDuel(String duelId, void Function(Duel) onUpdate) {
    _channel = supabase.channel('duel_$duelId')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'duels',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: duelId,
        ),
        callback: (payload) {
          if (payload.newRecord.isNotEmpty) {
            onUpdate(Duel.fromMap(payload.newRecord));
          }
        },
      ).subscribe();
  }

  static void stopListening() {
    _channel?.unsubscribe();
    _channel = null;
  }

  // ── Historique ───────────────────────────────────────────
  static Future<List<Duel>> getRecentDuels({int limit = 10}) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final data = await supabase
        .from('duels')
        .select()
        .or('player1_id.eq.$userId,player2_id.eq.$userId')
        .eq('status', 'finished')
        .order('finished_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => Duel.fromMap(e)).toList();
  }
}
