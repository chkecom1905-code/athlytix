// lib/data/programs_catalog.dart
// 50 programmes — 5 catégories × 10 (5 gratuits + 5 premium)

class ProgramsCatalog {
  static List<ProgramData> get all => [
    ..._shoot, ..._dribble, ..._defense, ..._detente, ..._physique,
  ];
  static List<ProgramData> byCategory(ProgramCategory cat) =>
      all.where((p) => p.category == cat).toList();
  static List<ProgramData> get free    => all.where((p) => p.isFree).toList();
  static List<ProgramData> get premium => all.where((p) => !p.isFree).toList();

  // ══ 🎯 SHOOT — 5 gratuits + 5 premium ══════════════════
  static final _shoot = <ProgramData>[
    ProgramData(id:'shoot-foundations', title:'Foundations du Tir',
      category:ProgramCategory.shoot, durationWeeks:3, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.debutant, isFree:true, xpTotal:800, emoji:'🎯',
      objective:'Mécanique reproductible à 60%+ de réussite',
      description:'Le programme fondamental pour construire un tir solide et reproductible. 3 semaines pour installer la mécanique correcte.',
      weekPlan:['Sem 1 : Mécanique de base — position pieds, main guide, follow-through. 150 tirs par séance.','Sem 2 : Ajout du mouvement — pull-up basique depuis 3 zones. 200 tirs par séance.','Sem 3 : Intégration défenseur — tir sur feinte, catch & shoot. 250 tirs par séance.']),

    ProgramData(id:'three-point-sniper', title:'Three-Point Sniper',
      category:ProgramCategory.shoot, durationWeeks:5, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:1400, emoji:'🎯',
      objective:'35%+ de réussite aux 3 points',
      description:'5 semaines pour devenir une menace réelle derrière l\'arc. Travail du corner, du dribble-pull, des catches en mouvement.',
      weekPlan:['Sem 1 : Corner 3pts — 100 tirs gauche + 100 tirs droit par séance','Sem 2 : Wing 3pts — angle 45° gauche et droit, 200 tirs/séance','Sem 3 : Top of the key + catch en mouvement','Sem 4 : Pull-up 3pts sur dribble — 2 dribbles max','Sem 5 : Simulation match — 25 tentatives par zone × 4 zones']),

    ProgramData(id:'mid-range-mastery', title:'Mid-Range Mastery',
      category:ProgramCategory.shoot, durationWeeks:4, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:900, emoji:'📐',
      objective:'Mi-distance redoutable, 50%+ depuis les elbows',
      description:'Le mid-range revient en force au basket moderne. Ce programme construit un arsenal complet depuis les zones intermédiaires.',
      weekPlan:['Sem 1 : Elbow jumper — droit et gauche, 100 tirs par zone','Sem 2 : Short corner et baseline — feintes incluses','Sem 3 : Pull-up mid-range sur dribble latéral','Sem 4 : Intégration post-up — catch au poste, tir face au panier']),

    ProgramData(id:'free-throw-elite', title:'Free Throw Elite',
      category:ProgramCategory.shoot, durationWeeks:3, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.debutant, isFree:true, xpTotal:600, emoji:'🏀',
      objective:'80%+ de réussite aux lancers-francs',
      description:'Les LF se travaillent seul, n\'importe quand. 80% de réussite est atteignable pour tout le monde avec une routine solide.',
      weekPlan:['Sem 1 : Construire le rituel — 50 LF par séance, chaque répétition identique','Sem 2 : Pression simulée — LF après sprint, après effort physique, 75 LF/séance','Sem 3 : Simulation match — 2 LF × 30 séquences, score et objectif par séance']),

    ProgramData(id:'floater-specialist', title:'Floater Specialist',
      category:ProgramCategory.shoot, durationWeeks:4, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:900, emoji:'💧',
      objective:'Maîtriser le floater des deux mains',
      description:'Le floater est l\'arme des petits gardes contre les grands défenseurs. Ce programme construit un floater des deux mains.',
      weekPlan:['Sem 1 : Floater main dominante — droit au cercle, 60 répétitions','Sem 2 : Floater main faible — même exercice côté opposé','Sem 3 : Floater en mouvement — drive gauche/droit avec angle','Sem 4 : Floater sous pression — défenseur simulé, timing réel']),

    // ── PREMIUM ──────────────────────────────────────────
    ProgramData(id:'curry-system', title:'The Curry System',
      category:ProgramCategory.shoot, durationWeeks:8, sessionsPerWeek:5,
      difficulty:ProgramDifficulty.avance, isFree:false, priceEur:9.99, xpTotal:3500, emoji:'⚡',
      proPlayer:'Stephen Curry',
      objective:'Quick release + volume extrême off-screen',
      description:'Curry tire 20+ tirs par match en sortie d\'écrans à pleine vitesse. Ce programme reproduit son processus d\'entraînement — volume, vitesse et mécanique ultra-rapide.',
      weekPlan:['Sem 1-2 : Quick release — mains en position avant réception, 300 tirs/séance','Sem 3-4 : Off-screen catch & shoot — simuler écrans avec plot ou partenaire','Sem 5-6 : Dribble pull-up 3pts — 2 dribbles max, 400 tentatives/séance','Sem 7-8 : Vol work — enchaînements 30 secondes, duel chronométré']),

    ProgramData(id:'mamba-shooting', title:'Mamba Mentality Shooting',
      category:ProgramCategory.shoot, durationWeeks:8, sessionsPerWeek:5,
      difficulty:ProgramDifficulty.elite, isFree:false, priceEur:9.99, xpTotal:3800, emoji:'🐍',
      proPlayer:'Kobe Bryant',
      objective:'Fadeaway + clutch isolation scoring',
      description:'Kobe s\'entraînait 3× plus que n\'importe qui. Ce programme suit sa philosophie : maîtrise totale du tir mid-range, du fadeaway et de l\'isolation clutch.',
      weekPlan:['Sem 1-2 : Mid-range fondamental — turnaround basique, 200 tirs/séance','Sem 3-4 : Fadeaway technique — introduction du recul en tirant','Sem 5-6 : Isolation footwork — pivot fake, head fake, tir','Sem 7-8 : Clutch training — simulation 24" clock, dernier tir du match']),

    ProgramData(id:'durant-scoring', title:'KD Scoring System',
      category:ProgramCategory.shoot, durationWeeks:6, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.elite, isFree:false, priceEur:9.99, xpTotal:2800, emoji:'🌠',
      proPlayer:'Kevin Durant',
      objective:'Arsenal complet : 3pts, mid-range, post-up',
      description:'KD score depuis toutes les zones avec la même efficacité. Ce programme construit un arsenal complet — 3pts, pull-up, post-up — avec transitions fluides entre les zones.',
      weekPlan:['Sem 1 : 3pts pull-up — isolation, 2 dribbles, tir','Sem 2 : Mid-range — elbow et wing, fadeaway léger','Sem 3 : Post-up — dos au panier, turnaround et fadeaway','Sem 4 : Transitions — enchaîner les 3 zones sans pause','Sem 5 : Volume — 600 tirs en 90 minutes','Sem 6 : Match simulation — 7 spots × défenseur live']),

    ProgramData(id:'harden-creation', title:'Harden Scoring Creation',
      category:ProgramCategory.shoot, durationWeeks:6, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.avance, isFree:false, priceEur:9.99, xpTotal:2600, emoji:'↩️',
      proPlayer:'James Harden',
      objective:'Step-back 3pts + free-throw creation',
      description:'Harden a révolutionné la création de tir. Step-backs, pump fakes pour provoquer la faute, floaters — tout y est.',
      weekPlan:['Sem 1-2 : Step-back 3pts — mécanique et timing', 'Sem 3 : Pump fake → faute — provoquer le contact légalement','Sem 4 : Floater vs grands — angle droit, angle gauche','Sem 5-6 : Combo complet — step-back + floater + pull-up selon défense']),

    ProgramData(id:'dirk-methodology', title:'The Dirk Methodology',
      category:ProgramCategory.shoot, durationWeeks:7, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.elite, isFree:false, priceEur:9.99, xpTotal:3200, emoji:'🦅',
      proPlayer:'Dirk Nowitzki',
      objective:'One-legged fadeaway + post-up shooting',
      description:'Dirk a inventé le one-legged fadeaway — un tir physiologiquement impossible à contester. Ce programme déconstruit et rebuild cette mécanique unique.',
      weekPlan:['Sem 1-2 : Post-up fondamental — pivot face et dos','Sem 3-4 : Fadeaway introduction — recul classique d\'abord','Sem 5-6 : One-legged technique — pied d\'appel unique, maintien de l\'équilibre','Sem 7 : Match integration — créer le match pour ce tir']),
  ];

  // ══ 🏀 DRIBBLE — 5 gratuits + 5 premium ══════════════
  static final _dribble = <ProgramData>[
    ProgramData(id:'ball-handling-fundamentals', title:'Ball Handling Fundamentals',
      category:ProgramCategory.dribble, durationWeeks:3, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.debutant, isFree:true, xpTotal:700, emoji:'🏀',
      objective:'Dribble sans regarder la balle, les 2 mains',
      description:'Programme de base pour contrôler le ballon des deux mains sans baisser les yeux. Exercices classiques et progressifs.',
      weekPlan:['Sem 1 : Dribble main dominante — statique, différentes hauteurs, 5 min/main','Sem 2 : Dribble main faible — mêmes exercices côté gauche','Sem 3 : Dribble alterné + crossover basique — 10 min par séance']),

    ProgramData(id:'guard-skills-basics', title:'Guard Skills Basics',
      category:ProgramCategory.dribble, durationWeeks:4, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:1000, emoji:'🎮',
      objective:'Crossover, BTL, BTB maîtrisés',
      description:'Le trio fondamental du guard : crossover, between the legs, behind the back. 4 semaines pour les intégrer naturellement.',
      weekPlan:['Sem 1 : Crossover statique puis en mouvement','Sem 2 : Between the legs en marche puis en course','Sem 3 : Behind the back — statique, marche, course','Sem 4 : Combos — enchaîner les 3 en séquences']),

    ProgramData(id:'two-ball-training', title:'Two-Ball Mastery',
      category:ProgramCategory.dribble, durationWeeks:4, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:900, emoji:'⚽⚽',
      objective:'Ambidextrie complète, indépendance des mains',
      description:'S\'entraîner avec deux ballons simultanément force l\'indépendance des mains. Méthode utilisée par tous les grands ball-handlers.',
      weekPlan:['Sem 1 : Two-ball statique — dribble simultané même hauteur','Sem 2 : Alterné — une balle haute, une basse, alterner','Sem 3 : Marche et dribble à deux ballons simultanément','Sem 4 : Jeu de réaction — partenaire annonce changement de hauteur']),

    ProgramData(id:'speed-dribble-program', title:'Speed Dribble',
      category:ProgramCategory.dribble, durationWeeks:3, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:750, emoji:'💨',
      objective:'Dribble pleine vitesse sans perte de contrôle',
      description:'La vitesse d\'exécution change tout. Ce programme travaille le dribble à 100% de vitesse pour simuler les conditions réelles de match.',
      weekPlan:['Sem 1 : Sprint avec dribble — 20m aller-retour, 10 séries','Sem 2 : Changement de direction à pleine vitesse — crossover en course','Sem 3 : Dribble obstacle course — contourner 5 cônes à max vitesse']),

    ProgramData(id:'combo-builder', title:'Combo Builder',
      category:ProgramCategory.dribble, durationWeeks:4, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.avance, isFree:true, xpTotal:1100, emoji:'🔀',
      objective:'Créer ses propres combos instinctivement',
      description:'Un bon ball-handler ne pense pas ses combos — ils viennent instinctivement. Ce programme construit 5 combos fondamentaux puis laisse improviser.',
      weekPlan:['Sem 1 : Apprendre 5 combos de base (cross-BTL-hesi, etc.)','Sem 2 : Drill chaque combo 50× par séance','Sem 3 : Enchaîner au choix — décision en 0.5 seconde','Sem 4 : Défenseur réel — appliquer les combos sous pression']),

    // ── PREMIUM ──────────────────────────────────────────
    ProgramData(id:'kyrie-handle-system', title:'The Kyrie Handle System',
      category:ProgramCategory.dribble, durationWeeks:8, sessionsPerWeek:5,
      difficulty:ProgramDifficulty.elite, isFree:false, priceEur:9.99, xpTotal:4000, emoji:'🪄',
      proPlayer:'Kyrie Irving',
      objective:'Combos avancés + ambidextrie parfaite',
      description:'Kyrie Irving possède le ball-handling le plus avancé de l\'histoire. Ce programme décortique ses combos signature et les rend apprenables étape par étape.',
      weekPlan:['Sem 1-2 : Kyrie BTL combos — gauche et droite','Sem 3-4 : Hesi-cross-BTB séquences — 30 min/séance','Sem 5-6 : Crossover bas ultra-rapide — vitesse maximum','Sem 7-8 : Combos libres sur défenseur — improvisation guidée']),

    ProgramData(id:'iverson-ankle-system', title:'Allen Iverson Ankle Breaker System',
      category:ProgramCategory.dribble, durationWeeks:6, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.avance, isFree:false, priceEur:9.99, xpTotal:2700, emoji:'💀',
      proPlayer:'Allen Iverson',
      objective:'Crossover ultra-basse main + explosion',
      description:'Le crossover d\'Iverson était le plus bas et rapide de l\'histoire NBA. Ce programme reconstruit sa mécanique de A à Z.',
      weekPlan:['Sem 1 : Position ultra-basse — dribble cheville, 20 min/séance','Sem 2 : Cross basse main — statique puis en marche','Sem 3 : Pause avant cross — le timing crucial','Sem 4 : Explosion post-cross — chaque rep = sprint 5m après','Sem 5-6 : Simulation adversaire — ankle breaker en conditions réelles']),

    ProgramData(id:'cp3-control-program', title:'Chris Paul Control Program',
      category:ProgramCategory.dribble, durationWeeks:5, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.avance, isFree:false, priceEur:9.99, xpTotal:2200, emoji:'🎓',
      proPlayer:'Chris Paul',
      objective:'IQ dribble — contrôle du tempo de jeu',
      description:'CP3 ne dribble pas plus vite — il dribble MIEUX. Ce programme travaille la lecture du jeu, le changement de tempo et l\'utilisation de l\'écran pick & roll.',
      weekPlan:['Sem 1 : Haute-basse-haute — changer le rythme du dribble à la demande','Sem 2 : Isolation footwork — placer l\'adversaire sur la hanche','Sem 3 : Pick & roll lecture — quand pénétrer, quand ressortir','Sem 4-5 : Prise de décision — drill 3 options en 2 secondes']),

    ProgramData(id:'luka-ball-iq', title:'Luka Dončić Ball IQ',
      category:ProgramCategory.dribble, durationWeeks:7, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.elite, isFree:false, priceEur:9.99, xpTotal:3200, emoji:'🧠',
      proPlayer:'Luka Dončić',
      objective:'Step-backs, creation, lecture défense',
      description:'Luka n\'est pas le plus rapide mais il lit la défense comme un grand maître aux échecs. Ce programme développe l\'IQ offensive autour du dribble.',
      weekPlan:['Sem 1-2 : Step-back fondamental — technique sans défenseur','Sem 3 : Lecture défense — quand step-back vs quand drive','Sem 4-5 : Isolation moves — hesi, cross, step-back en séquence','Sem 6-7 : Film study + application — copier 5 possessions Luka par semaine']),

    ProgramData(id:'westbrook-aggressive', title:'Aggressive Handle — Westbrook',
      category:ProgramCategory.dribble, durationWeeks:5, sessionsPerWeek:5,
      difficulty:ProgramDifficulty.avance, isFree:false, priceEur:9.99, xpTotal:2400, emoji:'🌪️',
      proPlayer:'Russell Westbrook',
      objective:'Drive agressif + physicalité au dribble',
      description:'Westbrook attaquait la raquette avec une intensité que peu ont égalée. Ce programme développe l\'agressivité au dribble et la finition sous contact.',
      weekPlan:['Sem 1 : Drive droit — explosion pied dominant, sans hésitation','Sem 2 : Drive croisant — changer de côté en pleine vitesse','Sem 3 : Contact drill — finir malgré la résistance physique','Sem 4-5 : Dribble-penetration-kick — lire les aides et ressortir']),
  ];

  // ══ 🛡️ DEFENSE — 5 gratuits + 5 premium ══════════════
  static final _defense = <ProgramData>[
    ProgramData(id:'defense-fundamentals', title:'Defensive Fundamentals',
      category:ProgramCategory.defense, durationWeeks:3, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.debutant, isFree:true, xpTotal:600, emoji:'🛡️',
      objective:'Stance, slide et closeout maîtrisés',
      description:'La défense commence par 3 fondamentaux que 90% des joueurs amateurs ne maîtrisent pas. Ce programme les inculque correctement.',
      weekPlan:['Sem 1 : Stance — position de défense, 100 slides latéraux par séance','Sem 2 : Closeout — sortir sur shooteur sans fauter, 30 répétitions','Sem 3 : Box out — rebond défensif, 20 séquences par séance']),

    ProgramData(id:'perimeter-defense', title:'Perimeter Defender',
      category:ProgramCategory.defense, durationWeeks:4, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:900, emoji:'🔒',
      objective:'Défendre le porteur de balle en périmètre',
      description:'Défendre les guards et ailiers en périmètre — anticiper les drives, contester les tirs, ne pas se faire swinguer.',
      weekPlan:['Sem 1 : On-ball defense — suivre le dribble sans se faire déborder','Sem 2 : Contest du tir — timing du closeout et de la main haute','Sem 3 : Navigation des écrans — passer par-dessus ou par-dessous','Sem 4 : Drill complet 1v1 périmètre — 30 possessions par séance']),

    ProgramData(id:'help-defense-intro', title:'Help Defense Introduction',
      category:ProgramCategory.defense, durationWeeks:3, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:700, emoji:'🤝',
      objective:'Être au bon endroit pour aider',
      description:'La défense collective commence par savoir où se positionner quand la balle n\'est pas sur ton joueur. Ce programme enseigne les principes de base.',
      weekPlan:['Sem 1 : Triangle défensif — voir balle et joueur simultanément','Sem 2 : Rotation help-and-recover — aider et revenir sur son joueur','Sem 3 : Communication — call screens, call drivers']),

    ProgramData(id:'rebounding-program', title:'Rebounding Machine',
      category:ProgramCategory.defense, durationWeeks:4, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:800, emoji:'📦',
      objective:'Dominer le rebond défensif et offensif',
      description:'Le rebond se joue avant que la balle touche l\'anneau. Ce programme développe la lecture de trajectoire, la position et l\'explosivité.',
      weekPlan:['Sem 1 : Box out technique — se retourner sur adversaire, garder contact','Sem 2 : Lecture de trajectoire — rebond depuis différents angles de tir','Sem 3 : Rebond offensif — timing d\'approche, putback','Sem 4 : Rebond sous pression — 2v2 et 3v3 rebond uniquement']),

    ProgramData(id:'steal-anticipation', title:'Steal & Anticipation',
      category:ProgramCategory.defense, durationWeeks:3, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:650, emoji:'🦅',
      objective:'Voler la balle sans fauter',
      description:'Le steal ne se pratique pas — il s\'anticipe. Ce programme développe la lecture des passes et des dribbles pour créer des interceptions.',
      weekPlan:['Sem 1 : Reading passes — anticiper la trajectoire par lecture des épaules','Sem 2 : Dribble deflections — frapper la balle en descente sur le dribble','Sem 3 : Intercept drill — partenaire passe, toi tu interceptes (timing)']),

    // ── PREMIUM ──────────────────────────────────────────
    ProgramData(id:'klaw-defense-system', title:'The Klaw Defense System',
      category:ProgramCategory.defense, durationWeeks:8, sessionsPerWeek:5,
      difficulty:ProgramDifficulty.elite, isFree:false, priceEur:9.99, xpTotal:4000, emoji:'🦁',
      proPlayer:'Kawhi Leonard',
      objective:'Lockdown défense — mains actives, anticipation',
      description:'Kawhi Leonard est considéré le meilleur défenseur de sa génération. Ce programme reproduit sa méthode — position, mains et anticipation.',
      weekPlan:['Sem 1-2 : Position ultra-serrée — 50-60cm de l\'adversaire en permanence','Sem 3-4 : Mains actives — conteste chaque dribble et chaque passe','Sem 5-6 : Anticipation — lire l\'épaule, anticiper à droite ou gauche','Sem 7-8 : Full lockdown drill — 5 possessions où l\'adversaire ne score pas']),

    ProgramData(id:'draymond-iq-defense', title:'Draymond Green IQ Defense',
      category:ProgramCategory.defense, durationWeeks:6, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.avance, isFree:false, priceEur:9.99, xpTotal:2800, emoji:'🎯',
      proPlayer:'Draymond Green',
      objective:'Orchestrer la défense collective',
      description:'Draymond est le cerveau défensif des Warriors. Ce programme enseigne la défense en tant que chef d\'orchestre — communication, couverture, rotation.',
      weekPlan:['Sem 1-2 : Lecture du jeu adverse — identifier le plan d\'attaque','Sem 3 : Communication constante — call chaque mouvement à voix haute','Sem 4 : Switch defense — changer d\'adversaire sur écran intelligemment','Sem 5-6 : 5-on-5 defensive mastery — diriger la défense depuis le milieu']),

    ProgramData(id:'gary-payton-pest', title:'Gary Payton On-Ball System',
      category:ProgramCategory.defense, durationWeeks:5, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.elite, isFree:false, priceEur:9.99, xpTotal:2600, emoji:'🧤',
      proPlayer:'Gary Payton',
      objective:'Harcèlement on-ball du début à la fin',
      description:'Gary Payton n\'accordait pas un seul dribble facile. Ce programme développe la pression constante et le mental défensif d\'élite.',
      weekPlan:['Sem 1 : Position ultra-proche — 50cm, mains en mouvement permanent','Sem 2 : Suivi du dribble — ne jamais laisser un angle de drive facile','Sem 3 : Talks défensifs — déstabiliser mentalement (légalement)','Sem 4-5 : Drill 1v1 — zéro drive facile sur 24 secondes, 30 possessions']),

    ProgramData(id:'ben-wallace-interior', title:'Ben Wallace Interior Defense',
      category:ProgramCategory.defense, durationWeeks:5, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.avance, isFree:false, priceEur:9.99, xpTotal:2400, emoji:'🧱',
      proPlayer:'Ben Wallace',
      objective:'Dominer la raquette, bloquer sans fauter',
      description:'Ben Wallace protégeait la raquette avec une intensité légendaire. Ce programme développe le shot-blocking, le box-out et la présence physique en raquette.',
      weekPlan:['Sem 1 : Shot blocking technique — timing et bras vertical','Sem 2 : Box out dominant — 3 positions de rebond, drill 50 rép/séance','Sem 3 : Raquette defense — rester debout, ne pas sauter sur feinte','Sem 4-5 : Post defense — défendre le poste bas sans fauter']),

    ProgramData(id:'tony-allen-intensity', title:'Tony Allen Intensity Program',
      category:ProgramCategory.defense, durationWeeks:4, sessionsPerWeek:5,
      difficulty:ProgramDifficulty.elite, isFree:false, priceEur:9.99, xpTotal:2200, emoji:'🐝',
      proPlayer:'Tony Allen',
      objective:'Intensité défensive maximale sur toute la durée',
      description:'Tony Allen était le meilleur défenseur d\'utilité NBA — jamais en faute, toujours là. Ce programme développe l\'intensité défensive sur la durée d\'un match.',
      weekPlan:['Sem 1 : Cardio défensif — slides 30 secondes, 10 séries, sans pause','Sem 2 : Pression constante — 4 minutes de défense on-ball sans break','Sem 3 : Help-and-recover — aller aider et revenir sur son joueur 20 fois','Sem 4 : Match intensity — simuler 4 quarts de défense à intensité max']),
  ];

  // ══ 🦘 DÉTENTE — 5 gratuits + 5 premium ══════════════
  static final _detente = <ProgramData>[
    ProgramData(id:'jump-foundations', title:'Jump Training Foundations',
      category:ProgramCategory.detente, durationWeeks:4, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.debutant, isFree:true, xpTotal:800, emoji:'📦',
      objective:'Base plyométrique — +5cm de détente',
      description:'Avant de sauter haut, il faut construire les fondations. Programme de base plyométrique pour développer la détente verticale.',
      weekPlan:['Sem 1 : Box jumps — 4 × 10 sauts sur box 50cm','Sem 2 : Squat jumps — 4 × 15, explosivité à chaque répétition','Sem 3 : Depth jumps — tomber d\'une box et ressauter immédiatement','Sem 4 : Evaluation + progression — test saut et ajustement']),

    ProgramData(id:'vertical-jump-beginner', title:'Vertical Jump Starter',
      category:ProgramCategory.detente, durationWeeks:6, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:1300, emoji:'⬆️',
      objective:'+10cm de détente en 6 semaines',
      description:'Programme progressif pour développer la détente verticale de 10cm minimum en 6 semaines.',
      weekPlan:['Sem 1 : Jump squats 4×20, calf raises 3×30','Sem 2 : Broad jumps 5×8, lateral jumps 5×10','Sem 3 : Single leg jumps — alternance jambe dominante et faible','Sem 4 : Depth drops et reactive jumps','Sem 5 : Sprint et jump — vitesse horizontale convertie en vertical','Sem 6 : Peak week — volume réduit, intensité max, repos 48h avant test']),

    ProgramData(id:'lower-body-strength', title:'Lower Body Strength',
      category:ProgramCategory.detente, durationWeeks:5, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:1000, emoji:'🏋️',
      objective:'Renforcer les jambes pour mieux sauter',
      description:'Un saut est une expression de force. Sans base musculaire solide, la plyométrie seule ne suffit pas. Programme de renforcement des jambes ciblé basket.',
      weekPlan:['Sem 1 : Squat bodyweight + fentes — 4×20 chaque','Sem 2 : Squat sauté + Bulgarian split squat','Sem 3 : Romanian deadlift + hip thrust pour les ischio-jambiers','Sem 4 : Step-ups explosifs + lunges avec saut','Sem 5 : Intégration — circuit force + plyométrie']),

    ProgramData(id:'calf-program', title:'Calf & Ankle Power',
      category:ProgramCategory.detente, durationWeeks:3, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.debutant, isFree:true, xpTotal:600, emoji:'🦵',
      objective:'Renforcer mollets et chevilles pour la détente',
      description:'Les mollets et les chevilles contribuent à 20-30% de la hauteur du saut. Ce programme les cible spécifiquement.',
      weekPlan:['Sem 1 : Calf raises — 4×30, unilatéral et bilatéral','Sem 2 : Single leg jumps courts — répétitions rapides, hauteur modérée','Sem 3 : Ankle stiffness drills — double-leg quick jumps, rebonds sur pointes']),

    ProgramData(id:'approach-jump', title:'Approach Jump Mastery',
      category:ProgramCategory.detente, durationWeeks:4, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:900, emoji:'🏃‍♂️',
      objective:'Convertir la vitesse horizontale en verticalité',
      description:'Le saut d\'approche (avec élan) est plus efficace que le saut statique. Ce programme optimise les 2-3 dernières foulées avant décollage.',
      weekPlan:['Sem 1 : Penultimate step drill — les 2 derniers pas accélérés','Sem 2 : Stride length optimization — trouver la bonne longueur d\'approche','Sem 3 : Approach + basket touch — toucher progressivement plus haut','Sem 4 : Dunk simulation — approche complète, hauteur max']),

    // ── PREMIUM ──────────────────────────────────────────
    ProgramData(id:'ja-explosive-athlete', title:'The Explosive Athlete — Ja Morant',
      category:ProgramCategory.detente, durationWeeks:10, sessionsPerWeek:5,
      difficulty:ProgramDifficulty.elite, isFree:false, priceEur:9.99, xpTotal:4500, emoji:'🚀',
      proPlayer:'Ja Morant',
      objective:'Explosivité maximale — +20cm de détente',
      description:'Ja Morant saute plus haut que presque tout le monde en NBA malgré sa taille de 1,88m. Son programme secret d\'athlétisme, reconstitué.',
      weekPlan:['Sem 1-2 : Base plyométrique — box jumps, depth jumps, 5×10','Sem 3-4 : Squat jump 120% — sauts avec léger lest puis sans','Sem 5-6 : Speed-strength circuit — sprint 20m + jump + squat, no rest','Sem 7-8 : Reactive jumps — depth drops ultra-rapides, < 0.15s contact','Sem 9-10 : Peak et test — 48h repos, test hauteur, dunk evaluation']),

    ProgramData(id:'zach-lavine-jump', title:'Zach LaVine Jump Program',
      category:ProgramCategory.detente, durationWeeks:8, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.elite, isFree:false, priceEur:9.99, xpTotal:3800, emoji:'🌪️',
      proPlayer:'Zach LaVine',
      objective:'Détente acrobatique + contrôle en l\'air',
      description:'LaVine ne saute pas seulement haut — il contrôle son corps en l\'air. Ce programme développe la hauteur ET la coordination aérienne.',
      weekPlan:['Sem 1-2 : Vertical max — 6×5 sauts avec récupération complète','Sem 3-4 : Air coordination — attraper, changer de main en l\'air','Sem 5-6 : 360° jump — rotation en saut, terrain de basket','Sem 7-8 : Dunk training — approche + rotation + finition']),

    ProgramData(id:'lebron-athleticism', title:'LeBron Athleticism Program',
      category:ProgramCategory.detente, durationWeeks:10, sessionsPerWeek:5,
      difficulty:ProgramDifficulty.elite, isFree:false, priceEur:9.99, xpTotal:4800, emoji:'👑',
      proPlayer:'LeBron James',
      objective:'Explosivité + endurance athlétique complète',
      description:'LeBron combine détente, vitesse et endurance — il joue 35 minutes à 100%. Ce programme développe l\'athlétisme complet.',
      weekPlan:['Sem 1-2 : Base force — squat, hip thrust, single leg press','Sem 3-4 : Explosion — power cleans, box jumps avec charge légère','Sem 5-6 : Vitesse — 40-yard dash, agility drills, court sprints','Sem 7-8 : Endurance athlétique — circuit 45 minutes haute intensité','Sem 9-10 : Combiné complet — force + explosion + endurance tous les jours']),

    ProgramData(id:'vince-carter-vertical', title:'Vince Carter Vertical System',
      category:ProgramCategory.detente, durationWeeks:8, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.avance, isFree:false, priceEur:9.99, xpTotal:3500, emoji:'💨',
      proPlayer:'Vince Carter',
      objective:'Détente spectaculaire + dunks acrobatiques',
      description:'Vince Carter avait l\'une des meilleures verticalités jamais vues. Ce programme combine sa méthode de saut avec les techniques acrobatiques.',
      weekPlan:['Sem 1-2 : Pure vertical — 8×3 sauts maximum avec récupération 3 minutes','Sem 3-4 : Approach jumps — touch progressivement plus haut chaque séance','Sem 5-6 : Wind-up technique — bras, timing et synchronisation corps','Sem 7-8 : Dunk artistic — windmill basics, tomahawk approach']),

    ProgramData(id:'dwight-power-jump', title:'Dwight Howard Power Jump',
      category:ProgramCategory.detente, durationWeeks:6, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.avance, isFree:false, priceEur:9.99, xpTotal:2800, emoji:'💪',
      proPlayer:'Dwight Howard',
      objective:'Saut de puissance + domination raquette',
      description:'Dwight Howard ne sautait pas le plus haut mais sa puissance et son explosivité proche du cercle étaient légendaires. Programme axé force-détente.',
      weekPlan:['Sem 1 : Max strength — squat heavy 5×5, Romanian deadlift','Sem 2 : Power conversion — hang cleans, jump squats avec charge','Sem 3 : Approach power — full speed approach + slam','Sem 4 : Contact jumps — sauter avec résistance physique légère','Sem 5-6 : Interior finishing — putbacks, alley-oops, rebond offensif']),
  ];

  // ══ 💪 PHYSIQUE — 5 gratuits + 5 premium ══════════════
  static final _physique = <ProgramData>[
    ProgramData(id:'basketball-conditioning', title:'Basketball Conditioning',
      category:ProgramCategory.physique, durationWeeks:4, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.debutant, isFree:true, xpTotal:800, emoji:'🏃',
      objective:'Tenir 4 quarts-temps sans perdre en niveau',
      description:'Le conditionnement physique de base pour tenir un match complet à bon niveau. Cardio et force musculaire spécifiques au basket.',
      weekPlan:['Sem 1 : Suicides (sprints aller-retour sur terrain) × 10, repos 1 min','Sem 2 : Intervalles — 30s sprint, 30s marche × 20','Sem 3 : Circuit musculaire — push-up, squat, lunge × 3 rounds','Sem 4 : Simulation match — 4 × 12 min d\'effort à intensité modérée']),

    ProgramData(id:'core-stability', title:'Core Stability for Basketball',
      category:ProgramCategory.physique, durationWeeks:3, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.debutant, isFree:true, xpTotal:600, emoji:'⚡',
      objective:'Tronc solide pour le contact et l\'équilibre',
      description:'Un tronc fort améliore tout : le tir, le dribble, la finition au contact. Ce programme cible spécifiquement le core pour le basket.',
      weekPlan:['Sem 1 : Planche, russian twists, mountain climbers — 3×30 chaque','Sem 2 : Anti-rotation core — pallof press, single-arm planche','Sem 3 : Core dynamique — med ball rotations, woodchops, anti-lateral flexion']),

    ProgramData(id:'agility-program', title:'Agility & Footwork',
      category:ProgramCategory.physique, durationWeeks:4, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:900, emoji:'⚡',
      objective:'Vitesse de pieds et changements de direction',
      description:'L\'agilité est le moteur du basket. Ce programme développe la vitesse de pieds et la capacité à changer de direction rapidement.',
      weekPlan:['Sem 1 : Ladder drills — 5 exercices différents × 3 séries chacun','Sem 2 : Cone drills — T-drill, 5-10-5 shuttle, 4 corners','Sem 3 : Réaction drills — partenaire annonce la direction 0.5s avant','Sem 4 : Court-specific — defensive slides, closeouts, transition sprints']),

    ProgramData(id:'upper-body-basketball', title:'Upper Body Basketball',
      category:ProgramCategory.physique, durationWeeks:4, sessionsPerWeek:3,
      difficulty:ProgramDifficulty.intermediaire, isFree:true, xpTotal:800, emoji:'💪',
      objective:'Force et endurance du haut du corps',
      description:'Les épaules, le dos et les bras sont sollicités dans chaque action. Ce programme renforce le haut du corps spécifiquement pour le basket.',
      weekPlan:['Sem 1 : Push-up variations (standard, large, serré) 4×15 + shoulder press','Sem 2 : Pulling — rows, pull-ups ou lat pulldown 4×10','Sem 3 : Triceps et biceps — dips, curls, pour stabiliser le tir','Sem 4 : Circuit complet — enchaîner push + pull + core × 4 tours']),

    ProgramData(id:'recovery-maintenance', title:'Recovery & Longevity',
      category:ProgramCategory.physique, durationWeeks:3, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.debutant, isFree:true, xpTotal:500, emoji:'🧘',
      objective:'Récupération et prévention des blessures',
      description:'Jouer longtemps sans se blesser est un art. Ce programme enseigne les techniques de récupération et la mobilité pour durer.',
      weekPlan:['Sem 1 : Étirements dynamiques avant séance + statiques après — routine 20 min','Sem 2 : Foam rolling + mobilité cheville, hanche, épaule — 15 min par zone','Sem 3 : Sleep, nutrition, ice-bath — protocole de récupération complète']),

    // ── PREMIUM ──────────────────────────────────────────
    ProgramData(id:'lebron-body-system', title:'The Body King System — LeBron',
      category:ProgramCategory.physique, durationWeeks:12, sessionsPerWeek:6,
      difficulty:ProgramDifficulty.elite, isFree:false, priceEur:12.99, xpTotal:6000, emoji:'👑',
      proPlayer:'LeBron James',
      objective:'Physique élite + longévité maximale',
      description:'LeBron dépense 1,5M$ par an pour son corps. Ce programme distille sa philosophie : force, explosivité, récupération et nutrition.',
      weekPlan:['Sem 1-2 : Force base — squat, bench, deadlift, 5×5','Sem 3-4 : Explosion — cleans, jumps, sprints','Sem 5-6 : Endurance musculaire — 3 circuits × 45 min','Sem 7-8 : Mobilité et récupération active — yoga flow, stretch', 'Sem 9-10 : Peak physical — tout à haute intensité','Sem 11-12 : Simulation saison — 6 jours/semaine, entraînement + match']),

    ProgramData(id:'giannis-raw-power', title:'Raw Power System — Giannis',
      category:ProgramCategory.physique, durationWeeks:10, sessionsPerWeek:5,
      difficulty:ProgramDifficulty.elite, isFree:false, priceEur:12.99, xpTotal:5200, emoji:'🦁',
      proPlayer:'Giannis Antetokounmpo',
      objective:'Puissance physique + athletisme exceptionnel',
      description:'Giannis est arrivé en NBA maigre et est devenu le joueur le plus musclé et explosif. Sa transformation physique est un modèle de progression.',
      weekPlan:['Sem 1-2 : Mass building — 4×8 heavy compound lifts','Sem 3-4 : Functional strength — kettlebell, médecine ball, mouvements athlétiques','Sem 5-6 : Power development — clean & jerk, snatch partiel, box jumps','Sem 7-8 : Speed-strength — tout à 80% 1RM mais vitesse maximale','Sem 9-10 : Court athleticism — combine vitesse, force et basket en séance']),

    ProgramData(id:'rudy-gobert-wingspan', title:'Wing & Length Program — Gobert',
      category:ProgramCategory.physique, durationWeeks:6, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.intermediaire, isFree:false, priceEur:9.99, xpTotal:2600, emoji:'🦢',
      proPlayer:'Rudy Gobert',
      objective:'Utiliser sa taille et son envergure efficacement',
      description:'Rudy Gobert est le meilleur défenseur NBA grâce à son envergure exceptionnelle. Ce programme maximise l\'utilisation de la longueur de bras.',
      weekPlan:['Sem 1-2 : Reach and block technique — lever les bras au bon moment','Sem 3 : Wingspan awareness — exercices de conscience corporelle','Sem 4 : Longue passe et lob — utiliser les bras pour passer par-dessus','Sem 5-6 : Rebond avec wingspan — attraper à une main aux extrémités']),

    ProgramData(id:'devin-booker-pro', title:'Booker Pro Athlete Program',
      category:ProgramCategory.physique, durationWeeks:8, sessionsPerWeek:5,
      difficulty:ProgramDifficulty.avance, isFree:false, priceEur:9.99, xpTotal:3600, emoji:'🎯',
      proPlayer:'Devin Booker',
      objective:'Athlétisme complet du scoring guard moderne',
      description:'Booker a transformé son corps pour devenir le scoring guard le plus complet de sa génération. Programme complet force + explosivité + endurance.',
      weekPlan:['Sem 1-2 : Force upper et lower — squat + bench + rows','Sem 3-4 : Explosivité ciblée — saut + sprint + changement de direction','Sem 5-6 : Endurance offensive — circuit 45 min dribble + tir + course','Sem 7-8 : Intégration totale — entraînement complet simulant un match']),

    ProgramData(id:'steph-flexibility', title:'Flexibility & Control — Curry',
      category:ProgramCategory.physique, durationWeeks:5, sessionsPerWeek:4,
      difficulty:ProgramDifficulty.intermediaire, isFree:false, priceEur:9.99, xpTotal:2200, emoji:'⚡',
      proPlayer:'Stephen Curry',
      objective:'Mobilité et gainage pour le tir parfait',
      description:'Curry a un programme de mobilité et gainage exceptionnel qui soutient son tir. Ce programme développe la stabilité corporelle pour améliorer la mécanique du tir.',
      weekPlan:['Sem 1 : Mobilité cheville et hanche — circuits de 20 min','Sem 2 : Gainage anti-rotation — maintenir l\'alignement lors du tir','Sem 3 : Équilibre unipodal — tirer sur une jambe, stabiliser','Sem 4 : Fatigué et précis — tirer après effort physique intense','Sem 5 : Routine pré-match Curry — échauffement complet de 45 min']),
  ];
}

// ── ProgramData class ──────────────────────────────────────────
class ProgramData {
  final String id;
  final String title;
  final ProgramCategory category;
  final int durationWeeks;
  final int sessionsPerWeek;
  final ProgramDifficulty difficulty;
  final bool isFree;
  final String? proPlayer;
  final double priceEur;
  final int xpTotal;
  final String emoji;
  final String objective;
  final String description;
  final List<String> weekPlan;

  const ProgramData({
    required this.id,
    required this.title,
    required this.category,
    required this.durationWeeks,
    required this.sessionsPerWeek,
    required this.difficulty,
    required this.isFree,
    this.proPlayer,
    this.priceEur = 0,
    required this.xpTotal,
    required this.emoji,
    required this.objective,
    required this.description,
    this.weekPlan = const [],
  });

  bool get isPro => !isFree;
  int get totalSessions => durationWeeks * sessionsPerWeek;
}

enum ProgramCategory {
  shoot, dribble, defense, detente, physique;
  String get label { switch(this) { case shoot: return 'Shoot'; case dribble: return 'Dribble'; case defense: return 'Défense'; case detente: return 'Détente'; case physique: return 'Physique'; } }
  String get emoji { switch(this) { case shoot: return '🎯'; case dribble: return '🏀'; case defense: return '🛡️'; case detente: return '🦘'; case physique: return '💪'; } }
}

enum ProgramDifficulty { debutant, intermediaire, avance, elite }
