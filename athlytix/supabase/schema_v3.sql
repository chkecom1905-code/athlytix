-- ============================================================
-- ATHLYTIX v4 — Supabase Schema
-- Run in SQL Editor (full reset or incremental)
-- ============================================================

-- ── PROFILES ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.profiles (
  id                UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email             TEXT NOT NULL,
  username          TEXT,
  xp                INTEGER NOT NULL DEFAULT 0,
  level             INTEGER NOT NULL DEFAULT 1,
  streak            INTEGER NOT NULL DEFAULT 0,
  last_workout_date DATE,
  avatar_url        TEXT,
  is_premium        BOOLEAN NOT NULL DEFAULT false,
  duels_won         INTEGER NOT NULL DEFAULT 0,
  duels_played      INTEGER NOT NULL DEFAULT 0,
  moves_unlocked    TEXT[] DEFAULT ARRAY[]::TEXT[],
  programs_enrolled TEXT[] DEFAULT ARRAY[]::TEXT[],
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users view own profile"   ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Auto-create profile trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, username)
  VALUES (NEW.id, NEW.email, SPLIT_PART(NEW.email, '@', 1));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ── WORKOUTS ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.workouts (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title        TEXT NOT NULL,
  description  TEXT,
  difficulty   TEXT NOT NULL CHECK (difficulty IN ('Debutant','Intermediaire','Avance','Elite')),
  type         TEXT NOT NULL,
  duration_min INTEGER NOT NULL DEFAULT 30,
  xp_reward    INTEGER NOT NULL DEFAULT 50,
  emoji        TEXT DEFAULT '?',
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Workouts viewable" ON public.workouts FOR SELECT USING (true);

-- ── COMPLETED WORKOUTS ────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.completed_workouts (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  workout_id   UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, workout_id)
);
ALTER TABLE public.completed_workouts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage completions" ON public.completed_workouts FOR ALL USING (auth.uid() = user_id);

-- ── CHALLENGES ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.challenges (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       TEXT NOT NULL,
  description TEXT,
  objective   TEXT NOT NULL,
  xp_reward   INTEGER NOT NULL DEFAULT 100,
  difficulty  TEXT NOT NULL CHECK (difficulty IN ('Bronze','Argent','Or','Platine')),
  emoji       TEXT DEFAULT '?',
  deadline    DATE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Challenges viewable" ON public.challenges FOR SELECT USING (true);

-- ── MOVES ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.moves (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title         TEXT NOT NULL,
  description   TEXT,
  difficulty    TEXT NOT NULL CHECK (difficulty IN ('Debutant','Intermediaire','Avance','Elite')),
  category      TEXT NOT NULL,
  is_free       BOOLEAN NOT NULL DEFAULT true,
  price_eur     NUMERIC(6,2) DEFAULT 0,
  pro_player    TEXT,
  video_url     TEXT,
  thumbnail_url TEXT,
  xp_reward     INTEGER NOT NULL DEFAULT 100,
  emoji         TEXT DEFAULT '?',
  -- Pose landmarks to validate (JSON array of expected angles/positions)
  pose_rules    JSONB DEFAULT '[]',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.moves ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Moves viewable" ON public.moves FOR SELECT USING (true);

-- ── MOVE COMPLETIONS ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.completed_moves (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  move_id      UUID NOT NULL REFERENCES public.moves(id) ON DELETE CASCADE,
  score        INTEGER NOT NULL DEFAULT 0,  -- 0–100
  attempts     INTEGER NOT NULL DEFAULT 1,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, move_id)
);
ALTER TABLE public.completed_moves ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage move completions" ON public.completed_moves FOR ALL USING (auth.uid() = user_id);

-- ── PROGRAMS ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.programs (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title          TEXT NOT NULL,
  description    TEXT,
  difficulty     TEXT NOT NULL CHECK (difficulty IN ('Debutant','Intermediaire','Avance','Elite')),
  duration_weeks INTEGER NOT NULL DEFAULT 4,
  sessions_week  INTEGER NOT NULL DEFAULT 3,
  is_free        BOOLEAN NOT NULL DEFAULT true,
  price_eur      NUMERIC(6,2) DEFAULT 0,
  pro_player     TEXT,
  emoji          TEXT DEFAULT '?',
  category       TEXT NOT NULL DEFAULT 'General',
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.programs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Programs viewable" ON public.programs FOR SELECT USING (true);

-- ── PROGRAM SESSIONS ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.program_sessions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id  UUID NOT NULL REFERENCES public.programs(id) ON DELETE CASCADE,
  week_number INTEGER NOT NULL,
  day_number  INTEGER NOT NULL,
  title       TEXT NOT NULL,
  description TEXT,
  workout_ids UUID[] DEFAULT ARRAY[]::UUID[],
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.program_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Sessions viewable" ON public.program_sessions FOR SELECT USING (true);

-- ── PROGRAM ENROLLMENTS ───────────────────────────────────
CREATE TABLE IF NOT EXISTS public.program_enrollments (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  program_id      UUID NOT NULL REFERENCES public.programs(id) ON DELETE CASCADE,
  current_week    INTEGER NOT NULL DEFAULT 1,
  current_day     INTEGER NOT NULL DEFAULT 1,
  enrolled_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, program_id)
);
ALTER TABLE public.program_enrollments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage enrollments" ON public.program_enrollments FOR ALL USING (auth.uid() = user_id);

-- ── DUELS ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.duels (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player1_id   UUID NOT NULL REFERENCES public.profiles(id),
  player2_id   UUID REFERENCES public.profiles(id),  -- NULL = bot
  is_bot       BOOLEAN NOT NULL DEFAULT false,
  bot_level    INTEGER DEFAULT 1,  -- 1–5
  status       TEXT NOT NULL DEFAULT 'waiting' CHECK (status IN ('waiting','active','finished')),
  skill_type   TEXT NOT NULL DEFAULT 'Tir',  -- type of challenge
  player1_score INTEGER NOT NULL DEFAULT 0,
  player2_score INTEGER NOT NULL DEFAULT 0,
  winner_id    UUID REFERENCES public.profiles(id),
  xp_reward    INTEGER NOT NULL DEFAULT 150,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at  TIMESTAMPTZ
);
ALTER TABLE public.duels ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Players see own duels"
  ON public.duels FOR ALL
  USING (auth.uid() = player1_id OR auth.uid() = player2_id);

-- ── STREAK FUNCTION ───────────────────────────────────────
CREATE OR REPLACE FUNCTION public.update_streak(p_user_id UUID)
RETURNS void AS $$
DECLARE v_last DATE; v_today DATE := CURRENT_DATE;
BEGIN
  SELECT last_workout_date INTO v_last FROM public.profiles WHERE id = p_user_id;
  IF v_last = v_today - INTERVAL '1 day' THEN
    UPDATE public.profiles SET streak = streak + 1, last_workout_date = v_today WHERE id = p_user_id;
  ELSIF v_last IS NULL OR v_last < v_today - INTERVAL '1 day' THEN
    UPDATE public.profiles SET streak = 1, last_workout_date = v_today WHERE id = p_user_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── SEED: WORKOUTS ────────────────────────────────────────
INSERT INTO public.workouts (title, description, difficulty, type, duration_min, xp_reward, emoji) VALUES
('Dribbles Fondamentaux',  'Maitrise les bases du dribble basse-main et crossover.','Debutant',      'Dribble',  20,  50, 'ball'),
('Tirs en Suspension',     'Travail du jump shot depuis differentes zones.',         'Intermediaire', 'Tir',      40,  75, 'target'),
('Defense 1-contre-1',     'Positionnement et footwork defensif.',                   'Intermediaire', 'Defense',  35,  75, 'shield'),
('Crossover Elite',        'Enchainements avances balle en main.',                  'Avance',        'Dribble',  45, 100, 'bolt'),
('3 Points Precision',     'Serie de 200 tentatives au-dela de larc.',              'Avance',        'Tir',      60, 100, 'fire'),
('Athletisme Court',       'Plyometrie et explosivite pour le basket.',              'Elite',         'Physique', 50, 150, 'muscle'),
('Floater & Mid-Range',    'Maitrise des tirs intermediaires et flotteurs.',        'Intermediaire', 'Tir',      30,  75, 'star'),
('Post Game Debutant',     'Jeu dos au panier, pivot et drop step.',                'Debutant',      'Post',     25,  50, 'cycle');

-- ── SEED: CHALLENGES ──────────────────────────────────────
INSERT INTO public.challenges (title, description, objective, xp_reward, difficulty, emoji, deadline) VALUES
('Sniper du Week-end',   'Shoote 100 tirs libres en 2 jours.',        'Reussir 70/100 tirs libres',     200,'Argent', 'target', CURRENT_DATE + 2),
('Dribbleur Fou',        'Complete 5 sessions dribble consecutives.', '5 workouts dribble en 7 jours',  350,'Or',     'bolt',   CURRENT_DATE + 7),
('Iron Man',             'Ne rate aucun workout cette semaine.',       '7 workouts en 7 jours',          500,'Platine','fire',   CURRENT_DATE + 7),
('Premier Pas',          'Complete ton premier workout.',              '1 workout termine',               100,'Bronze', 'shoe',   CURRENT_DATE + 30),
('Tireur Elite',         'Maitrise 3 types de tirs differents.',      '3 workouts Tir completes',       300,'Or',     'trophy', CURRENT_DATE + 14),
('Dueliste',             'Gagne 5 duels en ligne.',                   '5 victoires en duel',            400,'Platine','sword',  CURRENT_DATE + 30);

-- ── SEED: MOVES ───────────────────────────────────────────
INSERT INTO public.moves (title, description, difficulty, category, is_free, price_eur, pro_player, xp_reward, emoji, pose_rules) VALUES
('Crossover Basique',       'Changement de main simple devant soi.',              'Debutant',      'Dribble', true,  0,    null,      80,  'cross', '[{"joint":"RIGHT_WRIST","check":"below_hip"}]'),
('Behind the Back',         'Dribble dans le dos pour changer de direction.',     'Intermediaire', 'Dribble', true,  0,    null,      120, 'back',  '[{"joint":"RIGHT_WRIST","check":"behind_torso"}]'),
('Between the Legs',        'Dribble entre les jambes en mouvement.',             'Intermediaire', 'Dribble', true,  0,    null,      120, 'legs',  '[{"joint":"RIGHT_WRIST","check":"between_knees"}]'),
('Hesitation Dribble',      'Feinte avec pause pour desequilibrer le defenseur.', 'Intermediaire', 'Dribble', true,  0,    null,      110, 'wait',  '[{"joint":"BODY","check":"slight_lean_forward"}]'),
('Spin Move',               'Rotation complete pour contourner le defenseur.',    'Avance',        'Dribble', true,  0,    null,      140, 'spin',  '[{"joint":"TORSO","check":"full_rotation"}]'),
('Curry Shake',             'Double fausse passe de Stephen Curry.',              'Avance',        'Dribble', false, 5.00, 'Curry',   200, 'shake', '[{"joint":"SHOULDERS","check":"double_fake"},{"joint":"HIPS","check":"lateral_shift"}]'),
('LeBron Euro Step',        'Euro step puissant signature de LeBron James.',      'Avance',        'Drive',   false, 5.00, 'LeBron',  200, 'euro',  '[{"joint":"LEFT_FOOT","check":"lateral_step"},{"joint":"RIGHT_FOOT","check":"plant"}]'),
('Doncic Step-Back 3pts',   'Recul pour tir a 3pts signature de Doncic.',        'Elite',         'Tir',     false, 5.00, 'Doncic',  250, 'step',  '[{"joint":"RIGHT_FOOT","check":"step_back"},{"joint":"ARMS","check":"shooting_form"}]'),
('KD Fadeaway',             'Fadeaway en suspension signature de KD.',            'Elite',         'Tir',     false, 5.00, 'Durant',  250, 'fade',  '[{"joint":"TORSO","check":"backward_lean"},{"joint":"ARMS","check":"high_release"}]'),
('Harden Eurostep',         'Euro step en finger roll de Harden.',                'Avance',        'Drive',   false, 5.00, 'Harden',  200, 'jstep', '[{"joint":"LEFT_FOOT","check":"lateral_step"}]'),
('Kyrie Spin Layup',        'Lay-up en rotation signature de Kyrie.',             'Elite',         'Drive',   false, 5.00, 'Irving',  250, 'kyrie', '[{"joint":"TORSO","check":"spin_contact_point"}]'),
('Giannis Charge',          'Drive en puissance signature de Giannis.',           'Elite',         'Drive',   false, 5.00, 'Giannis', 250, 'gian',  '[{"joint":"TORSO","check":"forward_lean_drive"}]'),
('Jokic Post Hook',         'Crochet main gauche ou droite de Jokic.',            'Avance',        'Post',    false, 5.00, 'Jokic',   200, 'hook',  '[{"joint":"DOMINANT_ARM","check":"hook_motion"}]'),
('Kawhi Mid Pullup',        'Pull-up jumper au mid-range de Kawhi.',              'Intermediaire', 'Tir',     false, 5.00, 'Leonard', 180, 'klaw',  '[{"joint":"KNEES","check":"deep_bend"},{"joint":"ARMS","check":"high_elbow"}]'),
('Tatum Iso Fadeaway',      'Isolation + fadeaway signature de Tatum.',           'Elite',         'Tir',     false, 5.00, 'Tatum',   250, 'tat',   '[{"joint":"HIPS","check":"pivot_fade"},{"joint":"ARMS","check":"extension_form"}]');

-- ── SEED: PROGRAMS ────────────────────────────────────────
INSERT INTO public.programs (title, description, difficulty, duration_weeks, sessions_week, is_free, price_eur, pro_player, emoji, category) VALUES
('Debutant 30 Jours',       'Programme complet pour apprendre les bases du basket.','Debutant',      4, 3, true,  0,    null,      'star',  'General'),
('Shooter Elite',           'Deviens un tireur a 3 pts redoutable.',               'Intermediaire', 6, 4, true,  0,    null,      'target','Tir'),
('Ball Handling Pro',       'Maitrise du dribble niveau pro.',                     'Avance',        8, 4, true,  0,    null,      'bolt',  'Dribble'),
('Defense First',           'Programme axe sur la defense et les reflexes.',       'Intermediaire', 4, 3, true,  0,    null,      'shield','Defense'),
('Methode Curry',           'Off-ball movement et shooting comme Stephen Curry.',  'Avance',        8, 5, false, 9.99, 'Curry',   'curry', 'Tir'),
('LeBron Power Forward',    'Physique, drive et post game de LeBron James.',       'Elite',         10,5, false, 9.99, 'LeBron',  'lebron','Drive'),
('KD Mid-Range Mastery',    'Mid-range et fadeaway avances de Kevin Durant.',      'Elite',         8, 5, false, 9.99, 'Durant',  'kd',    'Tir'),
('Harden Scoring System',   'Isolation, Euro step et free throws de Harden.',     'Avance',        6, 4, false, 9.99, 'Harden',  'harden','Drive'),
('Giannis Athletisme',      'Explosivite et athletisme de Giannis.',               'Elite',         12,6, false,12.99, 'Giannis', 'greek', 'Physique'),
('Doncic IQ Basketball',    'Lecture de jeu et scoring de Luka Doncic.',           'Avance',        8, 4, false, 9.99, 'Doncic',  'luka',  'General');

-- ═══════════════════════════════════════════════════════
-- PATCH v4.1 — Coach IA + Tokens + Duel Points
-- Run after schema_v3.sql
-- ═══════════════════════════════════════════════════════

-- Add new columns to profiles
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS ai_tokens     INTEGER NOT NULL DEFAULT 10,
  ADD COLUMN IF NOT EXISTS duel_points   INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS rewards_unlocked TEXT[] DEFAULT ARRAY[]::TEXT[];

-- AI Analyses history
CREATE TABLE IF NOT EXISTS public.ai_analyses (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  prompt        TEXT NOT NULL DEFAULT '',
  response      TEXT NOT NULL DEFAULT '',
  analysis_type TEXT NOT NULL DEFAULT 'general',
  tokens_used   INTEGER NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.ai_analyses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own analyses"
  ON public.ai_analyses FOR ALL USING (auth.uid() = user_id);

-- Token purchase log
CREATE TABLE IF NOT EXISTS public.token_purchases (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  pack_id     TEXT NOT NULL,
  tokens      INTEGER NOT NULL,
  price_eur   NUMERIC(6,2) NOT NULL,
  stripe_id   TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.token_purchases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users view own purchases"
  ON public.token_purchases FOR SELECT USING (auth.uid() = user_id);

-- Reward programs (échangeables avec duel_points)
CREATE TABLE IF NOT EXISTS public.reward_programs (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id   UUID NOT NULL REFERENCES public.programs(id),
  points_cost  INTEGER NOT NULL DEFAULT 500,
  is_active    BOOLEAN NOT NULL DEFAULT true,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.reward_programs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Rewards viewable" ON public.reward_programs FOR SELECT USING (true);

-- Award duel points after win
CREATE OR REPLACE FUNCTION public.award_duel_points(p_user_id UUID, p_points INTEGER)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET duel_points = duel_points + p_points
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Seed reward_programs (requires programs to exist)
-- INSERT INTO public.reward_programs (program_id, points_cost)
-- SELECT id, 500 FROM public.programs WHERE is_free = false LIMIT 5;

-- ── V7: Ajout colonne langue ────────────────────────────────────
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS language TEXT DEFAULT 'fr';

COMMENT ON COLUMN public.profiles.language IS 'Code langue ISO 639-1 : fr, en, es, pt, de, it, ar, ja, zh, tr, ru, ko';

-- ── V7.1: Duels thématiques et privés ──────────────────────────
ALTER TABLE public.duels
  ADD COLUMN IF NOT EXISTS duel_theme TEXT DEFAULT 'Mixte',
  ADD COLUMN IF NOT EXISTS room_code  TEXT,
  ADD COLUMN IF NOT EXISTS is_private BOOLEAN NOT NULL DEFAULT false;

CREATE UNIQUE INDEX IF NOT EXISTS idx_duels_room_code
  ON public.duels(room_code)
  WHERE room_code IS NOT NULL AND status = 'waiting';

COMMENT ON COLUMN public.duels.duel_theme  IS 'Thème du duel : Tir, Dribble, Défense, IQ, Dunks, Mixte';
COMMENT ON COLUMN public.duels.room_code   IS 'Code 6 caractères pour rejoindre un duel privé';
COMMENT ON COLUMN public.duels.is_private  IS 'Duel privé (par code) ou public (matchmaking)';
