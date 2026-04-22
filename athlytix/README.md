# ATHLYTIX v4.0 — Basketball Progression App

> Flutter + Supabase · Duels en ligne · Moves NBA + Scan IA · Programmes structurés

---

## Démarrage rapide

**1. Supabase**
1. Créez un projet sur [supabase.com](https://supabase.com)
2. Remplissez `lib/supabase_config.dart` (URL + anon key)
3. Exécutez `supabase/schema_v3.sql` dans l'éditeur SQL

**2. Flutter**
```bash
flutter pub get && flutter run
```

---

## Features v4

- **Accueil** — XP card, streak, stats, actions rapides
- **Workouts** — 8 sessions + timer circulaire + XP/level-up
- **Moves** — 5 gratuits + 15 pros NBA (5€/move) + Scan IA ML Kit
- **Duels** — Matchmaking Realtime vs joueurs réels ou 5 niveaux de robots
- **Programmes** — 4 gratuits + 6 pros (Curry, LeBron, KD, Harden, Giannis, Doncic)
- **Profil** — Stats complètes, win rate, moves appris

---

## Scan IA — ML Kit Pose Detection

Le scan analyse 15 frames à 200ms via `google_mlkit_pose_detection`, vote majoritaire → score 0–100%, seuil de validation à 66%.

**Moves validés par règles de pose :**
Crossover, Behind the Back, Between the Legs, Spin Move, Curry Shake, LeBron Euro Step, Doncic Step-Back, KD Fadeaway + 7 autres génériques.

---

## Publication App Store (iOS)

### Prérequis
- Apple Developer Account ($99/an)
- `gem install fastlane`
- Xcode 15+

### Étapes
```bash
# 1. Certificats (une seule fois)
cd ios && fastlane match init && fastlane match appstore

# 2. Remplir ios/fastlane/Appfile avec votre apple_id, team_id, itc_team_id

# 3. TestFlight
flutter build ios --release
cd ios && fastlane beta

# 4. Production
cd ios && fastlane release
```

**Screenshots requis** : 6.7" iPhone + 12.9" iPad → `ios/fastlane/screenshots/fr-FR/`

---

## Publication Play Store (Android)

### Prérequis
- Google Play Developer Account ($25 une fois)
- Service Account JSON (Google Cloud IAM → Release Manager)

### Étapes
```bash
# 1. Générer keystore
keytool -genkey -v -keystore athlytix-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias athlytix-key

# 2. Remplir android/key.properties (storePassword, keyPassword, storeFile)

# 3. Copier service-account.json → android/fastlane/service-account.json

# 4. Internal testing
flutter build appbundle --release
cd android && fastlane internal

# 5. Production
cd android && fastlane release
```

---

## Stripe — Paiements

```bash
supabase secrets set STRIPE_SECRET_KEY=sk_live_XXXXX
supabase functions deploy create-payment-intent
```

Remplacer les `TODO Stripe` dans `move_detail_screen.dart` et `program_detail_screen.dart`.

---

## Supabase Realtime (Duels)

```sql
-- À exécuter une fois après schema_v3.sql
ALTER TABLE public.duels REPLICA IDENTITY FULL;
```

---

## .gitignore — Fichiers à ne JAMAIS commiter

```
android/key.properties
android/athlytix-release-key.jks
android/fastlane/service-account.json
lib/supabase_config.dart
ios/fastlane/Matchfile
.env*
```

---

## Architecture

```
lib/
├── main.dart + main_navigation.dart   (6 onglets)
├── models/   user · workout · challenge · move · program · duel
├── services/ auth · xp · pose (ML Kit) · duel (Realtime)
├── widgets/  shimmer · levelup_dialog
└── screens/  auth · onboarding · home · workouts · moves · duels · programs · profile
```
