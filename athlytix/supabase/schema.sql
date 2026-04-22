-- =============================================
-- ATHLYTIX - Supabase Schema (v2)
-- Run this in your Supabase SQL Editor
-- =============================================

-- ── PROFILES ──────────────────────────────────
CREATE TABLE public.profiles (
  id                UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email             TEXT NOT NULL,
  username          TEXT,
  xp                INTEGER NOT NULL DEFAULT 0,
  level             INTEGER NOT NULL DEFAULT 1,
  streak            INTEGER NOT NULL DEFAULT 0,
  last_workout_date DATE,
  avatar_url        TEXT,
  is_premium        BOOLEAN NOT NULL DEFAULT false,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile"   ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, username)
  VALUES (NEW.id, NEW.email, SPLIT_PART(NEW.email, '@', 1));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ── WORKOUTS ──────────────────────────────────
CREATE TABLE public.workouts (
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
CREATE POLICY "Workouts viewable by all" ON public.workouts FOR SELECT USING (true);

-- ── CHALLENGES ────────────────────────────────
CREATE TABLE public.challenges (
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
CREATE POLICY "Challenges viewable by all" ON public.challenges FOR SELECT USING (true);

-- ── COMPLETED_WORKOUTS ─────────────────────────
CREATE TABLE public.completed_workouts (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  workout_id   UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, workout_id)
);

ALTER TABLE public.completed_workouts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own completions"
  ON public.completed_workouts FOR ALL USING (auth.uid() = user_id);

-- ── STREAK FUNCTION ───────────────────────────
CREATE OR REPLACE FUNCTION public.update_streak(p_user_id UUID)
RETURNS void AS $$
DECLARE
  v_last DATE;
  v_today DATE := CURRENT_DATE;
BEGIN
  SELECT last_workout_date INTO v_last FROM public.profiles WHERE id = p_user_id;
  IF v_last = v_today - INTERVAL '1 day' THEN
    UPDATE public.profiles SET streak = streak + 1, last_workout_date = v_today WHERE id = p_user_id;
  ELSIF v_last IS NULL OR v_last < v_today - INTERVAL '1 day' THEN
    UPDATE public.profiles SET streak = 1, last_workout_date = v_today WHERE id = p_user_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── SEED: WORKOUTS ────────────────────────────
INSERT INTO public.workouts (title, description, difficulty, type, duration_min, xp_reward, emoji) VALUES
('Dribbles Fondamentaux', 'Maitrise les bases du dribble basse-main et crossover.', 'Debutant',      'Dribble',  20,  50,  'ball'),
('Tirs en Suspension',    'Travail du jump shot depuis differentes zones.',          'Intermediaire', 'Tir',      40,  75,  'target'),
('Defense 1-contre-1',    'Positionnement et footwork defensif.',                    'Intermediaire', 'Defense',  35,  75,  'shield'),
('Crossover Elite',       'Enchainements avances balle en main.',                   'Avance',        'Dribble',  45, 100,  'bolt'),
('3 Points Precision',    'Serie de 200 tentatives au-dela de l arc.',              'Avance',        'Tir',      60, 100,  'fire'),
('Athletisme Court',      'Plyometrie et explosivite pour le basket.',               'Elite',         'Physique', 50, 150,  'muscle'),
('Floater & Mid-Range',   'Maitrise des tirs intermediaires et flotteurs.',         'Intermediaire', 'Tir',      30,  75,  'star'),
('Post Game Debutant',    'Jeu dos au panier, pivot et drop step.',                 'Debutant',      'Post',     25,  50,  'cycle');

INSERT INTO public.challenges (title, description, objective, xp_reward, difficulty, emoji, deadline) VALUES
('Sniper du Week-end',    'Shoote 100 tirs libres en 2 jours.',        'Reussir 70/100 tirs libres',     200, 'Argent',  'target', CURRENT_DATE + INTERVAL '2 days'),
('Dribbleur Fou',         'Complete 5 sessions dribble consecutives.', '5 workouts dribble en 7 jours',  350, 'Or',      'bolt',   CURRENT_DATE + INTERVAL '7 days'),
('Iron Man',              'Ne rate aucun workout cette semaine.',       '7 workouts en 7 jours',          500, 'Platine', 'fire',   CURRENT_DATE + INTERVAL '7 days'),
('Premier Pas',           'Complete ton premier workout.',              '1 workout termine',               100, 'Bronze',  'shoe',   CURRENT_DATE + INTERVAL '30 days'),
('Tireur Elite',          'Maitrise 3 types de tirs differents.',      '3 workouts Tir completes',       300, 'Or',      'trophy', CURRENT_DATE + INTERVAL '14 days'),
('Defenseur de l Annee',  'Termine tous les workouts defense.',         'Tous workouts Defense termines', 400, 'Platine', 'shield', CURRENT_DATE + INTERVAL '30 days');
