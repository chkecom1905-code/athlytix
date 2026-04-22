// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';

// ── Auth ──────────────────────────────────────
class AuthService {
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String username = '',
    String language = 'fr',
  }) async {
    final response = await supabase.auth.signUp(email: email, password: password);

    // Mettre à jour le profil avec username et langue dès la création
    final uid = response.user?.id;
    if (uid != null) {
      await supabase.from('profiles').upsert({
        'id': uid,
        'email': email,
        'username': username.isNotEmpty ? username : email.split('@').first,
        'language': language,
        'ai_tokens': 10,
      });
    }
    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async =>
      await supabase.auth.signInWithPassword(email: email, password: password);

  static Future<void> signOut() async => await supabase.auth.signOut();

  static Future<UserProfile?> getCurrentProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final data = await supabase.from('profiles').select().eq('id', userId).single();
    return UserProfile.fromMap(data);
  }
}

// ── XP & Streak ───────────────────────────────
class XpService {
  static Future<UserProfile?> addXp(int amount, UserProfile current) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final newXp    = current.xp + amount;
    final newLevel = (newXp / 500).floor() + 1;

    await supabase.from('profiles').update({
      'xp': newXp,
      'level': newLevel,
    }).eq('id', userId);

    // Update streak via DB function
    await supabase.rpc('update_streak', params: {'p_user_id': userId});

    // Fetch updated profile (streak may have changed)
    final updated = await AuthService.getCurrentProfile();
    return updated ?? current.copyWith(xp: newXp, level: newLevel);
  }

  static Future<void> markWorkoutComplete(String workoutId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    await supabase.from('completed_workouts').upsert({
      'user_id': userId,
      'workout_id': workoutId,
    });
  }

  static Future<Set<String>> getCompletedWorkoutIds() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return {};
    final data = await supabase
        .from('completed_workouts')
        .select('workout_id')
        .eq('user_id', userId);
    return (data as List).map((e) => e['workout_id'] as String).toSet();
  }

  static Future<int> getCompletedCount() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return 0;
    final data = await supabase
        .from('completed_workouts')
        .select('id')
        .eq('user_id', userId);
    return (data as List).length;
  }
}

// ── Data ──────────────────────────────────────
class DataService {
  static Future<List<Workout>> getWorkouts() async {
    final data = await supabase.from('workouts').select().order('created_at');
    return (data as List).map((e) => Workout.fromMap(e)).toList();
  }

  static Future<List<Challenge>> getChallenges() async {
    final data = await supabase.from('challenges').select().order('xp_reward');
    return (data as List).map((e) => Challenge.fromMap(e)).toList();
  }
}
