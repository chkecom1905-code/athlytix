// lib/data/moves_catalog.dart
// 50 moves — 5 catégories × 10 (5 gratuits + 5 premium NBA)

class MovesCatalog {
  static List<MoveData> get all => [
    ..._shoot, ..._dribble, ..._finish, ..._defense, ..._dunks,
  ];
  static List<MoveData> byCategory(MoveCategory cat) =>
      all.where((m) => m.category == cat).toList();
  static List<MoveData> get free    => all.where((m) => m.isFree).toList();
  static List<MoveData> get premium => all.where((m) => !m.isFree).toList();

  // ══ 🎯 SHOOT — 5 gratuits + 5 premium ══════════════════
  static final _shoot = <MoveData>[
    MoveData(id:'catch-shoot', title:'Catch & Shoot',
      description:'La base du shooteur moderne : réception déjà en position, supprimer le temps mort entre catch et release.',
      category:MoveCategory.shoot, difficulty:MoveDifficulty.debutant, isFree:true, xpReward:80, emoji:'🎯',
      tags:['Spot-up','Fondamental'],
      steps:['Pieds déjà orientés panier avant la réception','Mains en pocket à hauteur des hanches','Genoux pré-fléchis pour exploser vers le haut','Monter-tirer en un seul mouvement','Follow-through complet, poignet cassé']),

    MoveData(id:'pull-up-basic', title:'Pull-Up Jumper',
      description:'Stopper son dribble et sauter immédiatement. Arme principale des guards pour créer du tir sur dribble.',
      category:MoveCategory.shoot, difficulty:MoveDifficulty.intermediaire, isFree:true, xpReward:100, emoji:'⬆️',
      tags:['Off-dribble','Mid-range'],
      steps:['Drive à pleine vitesse sur 2-3 dribbles','Planter fermement le pied d\'appel','Bloquer les hanches face au panier','Monter balle haute, coude aligné','Lâcher au pic du saut']),

    MoveData(id:'corner-3', title:'Corner Three',
      description:'Le tir le plus efficace du basket moderne. Depuis le corner, l\'angle est optimal et la ligne de 3pts est plus proche.',
      category:MoveCategory.shoot, difficulty:MoveDifficulty.debutant, isFree:true, xpReward:90, emoji:'📐',
      tags:['3 points','Spot-up','Corner'],
      steps:['Se positionner dans le corner, pieds larges','Rester alert, couper vers le corner sur la passe','Viser le carré arrière de la planche','Follow-through haut, poignet cassé vers le bas','Rester en position après le tir']),

    MoveData(id:'floater-basic', title:'Floater / Teardrop',
      description:'Tir lobé à une main utilisé pour passer par-dessus les intérieurs. Indispensable pour les petits gardes.',
      category:MoveCategory.shoot, difficulty:MoveDifficulty.intermediaire, isFree:true, xpReward:110, emoji:'💧',
      tags:['Finition','Layup avancé','Anti-bloc'],
      steps:['Drive en ligne droite vers le cercle','Réduire la vitesse à 1 foulée du cercle','Lancer à une main, trajectoire haute et lobée','Viser l\'anneau arrière','Pratiquer des deux mains']),

    MoveData(id:'free-throw-routine', title:'Free Throw Mastery',
      description:'La ligne des LF représente ~20% des points NBA. Un rituel parfait garantit la reproductibilité sous pression.',
      category:MoveCategory.shoot, difficulty:MoveDifficulty.debutant, isFree:true, xpReward:70, emoji:'🏀',
      tags:['Lancer-franc','Mental','Routine'],
      steps:['Même rituel à chaque lancer (dribbles, respiration)','Pieds à largeur d\'épaules, pied dominant légèrement avancé','Aligner pied → genou → coude → poignet','Fléchir légèrement les genoux','Suivre le ballon des yeux 2 secondes après le lâcher']),

    // ── PREMIUM ──────────────────────────────────────────
    MoveData(id:'curry-quick-release', title:'Quick Release — Curry',
      description:'Stephen Curry tire en 0.4 seconde. Son release ultra-rapide part dès que le ballon arrive en hand, avant même d\'être stabilisé.',
      category:MoveCategory.shoot, difficulty:MoveDifficulty.avance, isFree:false, priceEur:4.99, xpReward:220,
      emoji:'⚡', proPlayer:'Stephen Curry', tags:['Quick release','Off-screen','Volume'],
      steps:['Couper en sprint sur l\'écran, pieds coordonnés','Mains en position AVANT la réception','Initier le mouvement de tir dès le contact balle','Lâcher à 3/4 d\'extension bras — pas au pic','Répéter 100 fois par session avec écrans simulés']),

    MoveData(id:'kd-pull-up-fadeaway', title:'Long Fadeaway — KD',
      description:'Kevin Durant utilise sa taille (2,08m) et son extension pour tirer par-dessus n\'importe quel défenseur. Le fadeaway long est sa signature.',
      category:MoveCategory.shoot, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:260,
      emoji:'🌠', proPlayer:'Kevin Durant', tags:['Fadeaway','Post','Isolation'],
      steps:['Isolation — forcer le défenseur à choisir son côté','Dernier dribble puissant pour créer de l\'espace','Légère bascule en arrière en sautant','Bras complètement étendus au lâcher','Viser le fond du filet, pas le bord']),

    MoveData(id:'kobe-midrange-fadeaway', title:'Turnaround Fadeaway — Kobe',
      description:'La signature de Kobe Bryant. Dos au panier, pivot rapide, fadeaway. Impossible à contester proprement.',
      category:MoveCategory.shoot, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:270,
      emoji:'🐍', proPlayer:'Kobe Bryant', tags:['Fadeaway','Mid-range','Post'],
      steps:['Recevoir dos au panier, pied pivot gauche','Head fake pour faire sauter le défenseur','Pivoter 180° sur le pied gauche, vite','Sauter en reculant légèrement','Extension maximale des bras au lâcher']),

    MoveData(id:'harden-stepback-3', title:'Step-Back 3pts — Harden',
      description:'James Harden a popularisé le step-back 3pts comme arme principale. Un drive simulé suivi d\'un recul foudroyant.',
      category:MoveCategory.shoot, difficulty:MoveDifficulty.avance, isFree:false, priceEur:4.99, xpReward:240,
      emoji:'↩️', proPlayer:'James Harden', tags:['Step-back','3 points','Création'],
      steps:['Drive agressif sur 2 dribbles pour faire reculer le défenseur','Planter le pied d\'appel extérieur (gauche pour un droitier)','Reculer 2 grands pas en contrôle','Pieds orientés panier naturellement au recul','Monter-tirer immédiatement sans dribble supplémentaire']),

    MoveData(id:'dirk-one-leg-fadeaway', title:'One-Legged Fadeaway — Dirk',
      description:'Le move signature de Dirk Nowitzki. Tirer sur un seul pied en basculant — physiologiquement très difficile à contester.',
      category:MoveCategory.shoot, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:280,
      emoji:'🦅', proPlayer:'Dirk Nowitzki', tags:['Fadeaway','One-leg','Post'],
      steps:['Recevoir côté gauche du cercle, légèrement dos au panier','Pivoter sur le pied droit vers le panier','Lever le genou gauche en initiant le tir','Sauter sur le pied droit uniquement','Extension bras complète — mécanique identique à chaque fois']),
  ];

  // ══ 🏀 DRIBBLE — 5 gratuits + 5 premium ══════════════
  static final _dribble = <MoveData>[
    MoveData(id:'crossover-basic', title:'Crossover',
      description:'Le move de base du ball-handler. Changer de main devant soi pour déborder le défenseur.',
      category:MoveCategory.dribble, difficulty:MoveDifficulty.debutant, isFree:true, xpReward:80, emoji:'✖️',
      tags:['Fondamental','Changement de direction'],
      steps:['Position athlétique basse, genou fléchis','Dribble ferme côté dominant à hauteur de cheville','Push diagonal rapide vers l\'autre main','Protéger la balle avec le corps en changeant','Repartir en explosion côté opposé']),

    MoveData(id:'behind-back', title:'Behind the Back',
      description:'Dribble dans le dos pour changer de direction sans exposer la balle. Efficace en mouvement.',
      category:MoveCategory.dribble, difficulty:MoveDifficulty.intermediaire, isFree:true, xpReward:110, emoji:'🔙',
      tags:['Changement','Protection'],
      steps:['Drive latéral à bonne vitesse','Avancer la jambe opposée à la balle','Pousser la balle dans le dos, coude en arrière','Réceptionner de l\'autre main basse','Repartir immédiatement sans pause']),

    MoveData(id:'between-legs', title:'Between the Legs',
      description:'Dribble entre les jambes, très efficace en mouvement ou à l\'arrêt pour changer de rythme.',
      category:MoveCategory.dribble, difficulty:MoveDifficulty.intermediaire, isFree:true, xpReward:110, emoji:'🦵',
      tags:['Changement','Mixte'],
      steps:['Avancer le pied du même côté que la balle','Pousser la balle entre les deux jambes, coude tourné vers l\'intérieur','La balle doit rebondir à hauteur de cheville de l\'autre côté','Réceptionner main basse','Répéter en marchant puis en courant']),

    MoveData(id:'hesitation', title:'Hesitation (Hesi)',
      description:'Feinte de tir ou de pause brutale pour faire reculer ou se lever le défenseur.',
      category:MoveCategory.dribble, difficulty:MoveDifficulty.intermediaire, isFree:true, xpReward:110, emoji:'⏸️',
      tags:['Feinte','Rythme','Créateur'],
      steps:['Drive normal à mi-vitesse','Stopper net, épaules et torse de face','Simuler un tir ou une passe (sans exécuter)','Attendre la réaction du défenseur','Repartir côté opposé en explosion dès qu\'il bouge']),

    MoveData(id:'spin-move', title:'Spin Move',
      description:'Rotation complète autour du défenseur pour le contourner en gardant le contrôle de la balle.',
      category:MoveCategory.dribble, difficulty:MoveDifficulty.avance, isFree:true, xpReward:130, emoji:'🌀',
      tags:['Drive','Finition','Rotation'],
      steps:['Drive direct vers le défenseur','Planter fermement le pied pivot (pied intérieur)','Tourner dos au défenseur rapidement','Garder la balle collée contre soi pendant la rotation','Finir face au panier, repartir immédiatement']),

    // ── PREMIUM ──────────────────────────────────────────
    MoveData(id:'iverson-crossover', title:'Ankle Breaker — Iverson',
      description:'Allen Iverson a brisé plus de chevilles que tout autre joueur. Son crossover basse-main, ultra-rapide, est inimitable.',
      category:MoveCategory.dribble, difficulty:MoveDifficulty.avance, isFree:false, priceEur:4.99, xpReward:230,
      emoji:'💀', proPlayer:'Allen Iverson', tags:['Ankle breaker','Low dribble','Explosion'],
      steps:['Position ultra-basse, balle à hauteur de cheville','Cross simulé droit — rendre crédible','Pause brutale d\'une demi-seconde','Cross BAS et RAPIDE main gauche','Explosion avant que le défenseur réagisse — sans reprise de dribble']),

    MoveData(id:'kyrie-handles', title:'Signature Handle — Kyrie',
      description:'Kyrie Irving possède le contrôle de balle le plus avancé de l\'histoire NBA. Ses combos BTL-cross-BTB-hesi sont fluides comme de l\'eau.',
      category:MoveCategory.dribble, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:280,
      emoji:'🪄', proPlayer:'Kyrie Irving', tags:['Combo','Elite','Ambidextre'],
      steps:['BTL (between the legs) main gauche','Crossover G→D bas et rapide','BTB (behind the back) D→G en reculant','Hesitation face au défenseur','Explosion drive ou step-back']),

    MoveData(id:'crawford-combo', title:'Jamal Crawford Combo',
      description:'Crawford était maître des combos off-dribble. Son through-the-legs-hesi-pull-up est un chef-d\'oeuvre de ball-handling.',
      category:MoveCategory.dribble, difficulty:MoveDifficulty.avance, isFree:false, priceEur:4.99, xpReward:210,
      emoji:'🎩', proPlayer:'Jamal Crawford', tags:['Combo','Pull-up','Créateur'],
      steps:['Dribble main droite en avançant','BTL main droite vers main gauche','Hesi immédiat — corps de face','Cross G→D bas','Pull-up jumper ou drive selon la défense']),

    MoveData(id:'cp3-control', title:'High IQ Control — Chris Paul',
      description:'Chris Paul n\'est pas le plus athlétique, mais son contrôle du rythme est légendaire. Change le tempo en permanence pour piéger les défenseurs.',
      category:MoveCategory.dribble, difficulty:MoveDifficulty.avance, isFree:false, priceEur:4.99, xpReward:200,
      emoji:'🎓', proPlayer:'Chris Paul', tags:['IQ','Rythme','Pick & Roll'],
      steps:['Dribble haut-bas alterné pour varier le rebond','Isolation — placer le défenseur sur la hanche','Changer de vitesse 3× en 5 secondes','BTB ou cross au moment où le défenseur se penche','Pénétration ou stop-and-pop selon la lecture']),

    MoveData(id:'luka-read-react', title:'Read & React — Luka Dončić',
      description:'Luka Dončić lit la défense comme personne. Ses step-backs et combos sont décidés en temps réel selon la position du défenseur.',
      category:MoveCategory.dribble, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:260,
      emoji:'🧠', proPlayer:'Luka Dončić', tags:['Lecture','Step-back','Isolation'],
      steps:['Isolation côté dominant, lire la position du défenseur','Si défenseur haut : step-back pour 3pts','Si défenseur bas : drive et finition','Cross ou BTL selon le côté ouvert','Euro step si les aides arrivent dans la raquette']),
  ];

  // ══ 🏁 FINISH — 5 gratuits + 5 premium ═══════════════
  static final _finish = <MoveData>[
    MoveData(id:'basic-layup', title:'Layup Fondamental',
      description:'La finition de base. 2 pas réglementaires, pied d\'appel opposé à la main, balle posée sur la planche.',
      category:MoveCategory.finish, difficulty:MoveDifficulty.debutant, isFree:true, xpReward:70, emoji:'🏃',
      tags:['Finition','Fondamental'],
      steps:['Dribble d\'approche, 2 derniers pas élastiques','Pied d\'appel = pied opposé à la main de finition','Monter le genou de la jambe libre haut','Poser la balle sur le carré de la planche à 45°','Finir avec la main, ne pas lancer']),

    MoveData(id:'reverse-layup', title:'Reverse Layup',
      description:'Finir de l\'autre côté du panneau pour protéger la balle et éviter le contre. Essentiel pour les drives baseline.',
      category:MoveCategory.finish, difficulty:MoveDifficulty.intermediaire, isFree:true, xpReward:100, emoji:'🔄',
      tags:['Finition','Baseline','Anti-bloc'],
      steps:['Drive baseline en longeant la raquette','Dépasser le cercle d\'un pied','Dernier pas sous le panneau','Finir de la main faible côté opposé','Viser le carré du haut de la planche']),

    MoveData(id:'finger-roll', title:'Finger Roll',
      description:'Finition légère du bout des doigts. La balle roule sur les doigts au lieu d\'être posée. Impossible à contrer proprement.',
      category:MoveCategory.finish, difficulty:MoveDifficulty.intermediaire, isFree:true, xpReward:100, emoji:'👆',
      tags:['Finition','Doux','Layup avancé'],
      steps:['Approche standard en layup','Réduire la poussée vers le haut','Balle qui roule de la paume vers les doigts','Relâcher du bout des doigts, balle en rotation','Trajectoire courbe, pas directe vers le panneau']),

    MoveData(id:'up-and-under', title:'Up & Under',
      description:'Feinte de tir pour faire sauter le défenseur, puis passer en-dessous et finir. La mécanique classique du post.',
      category:MoveCategory.finish, difficulty:MoveDifficulty.intermediaire, isFree:true, xpReward:100, emoji:'⬆️⬇️',
      tags:['Feinte','Post','Finition'],
      steps:['Position post, pivot pour faire face au panier','Simuler un tir convaincant — balle haute','Attendre que le défenseur saute','Faire un pas en-dessous de lui (step under)','Finir de l\'autre côté avec une main']),

    MoveData(id:'layup-contact', title:'Layup au Contact',
      description:'Provoquer le contact avec le défenseur pour obtenir la faute tout en finissant le layup. Le "and-one".',
      category:MoveCategory.finish, difficulty:MoveDifficulty.avance, isFree:true, xpReward:120, emoji:'💥',
      tags:['Contact','Faute','And-one'],
      steps:['Drive décidé vers la raquette','Attaquer l\'épaule du défenseur (pas sa poitrine)','Absorber le contact avec les hanches et le torse','Garder les bras hauts, finir le geste','Crier et regarder l\'arbitre']),

    // ── PREMIUM ──────────────────────────────────────────
    MoveData(id:'parker-euro-step', title:'Euro Step — Tony Parker',
      description:'Tony Parker a popularisé l\'euro step en NBA. Deux pas en L pour contourner le défenseur et les aides.',
      category:MoveCategory.finish, difficulty:MoveDifficulty.avance, isFree:false, priceEur:4.99, xpReward:230,
      emoji:'🕺', proPlayer:'Tony Parker', tags:['Euro step','Finition','Contournement'],
      steps:['Drive pleine vitesse vers la raquette','Pied d\'appel latéral (premier pas)','Deuxième pas côté opposé, simuler le défenseur','Finir à une main sous le cercle','Appliquer avec les deux mains']),

    MoveData(id:'jordan-switch-hands', title:'Reverse Underhand — Michael Jordan',
      description:'Le move emblématique des Finals 1991. Jordan contourne le panier en changeant de main en l\'air — poétique et impossible à défendre.',
      category:MoveCategory.finish, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:280,
      emoji:'🐐', proPlayer:'Michael Jordan', tags:['Switch-hands','Air','Légendaire'],
      steps:['Drive côté droit à pleine vitesse','Décollage pied gauche face au panneau','Passer sous le cercle tout en étant en l\'air','Changer la balle de main droite à gauche en vol','Finir de la main gauche côté opposé']),

    MoveData(id:'giannis-charge', title:'Controlled Charge — Giannis',
      description:'Giannis Antetokounmpo combine vitesse et force pour charger la raquette en absorbant tout contact.',
      category:MoveCategory.finish, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:260,
      emoji:'🦁', proPlayer:'Giannis Antetokounmpo', tags:['Contact','Force','Drive puissant'],
      steps:['Position basse, balle à 2 mains','Explosion violente vers la raquette en 2-3 dribbles','Bras protégeant la balle côté défenseur','Absorber le contact avec les hanches','Finir haut ou alley-oop si aide']),

    MoveData(id:'jokic-post-hook', title:'Post Hook — Nikola Jokić',
      description:'Jokić a le meilleur hook du basket moderne. Pivot doux, lecture de la défense, crochet des deux mains.',
      category:MoveCategory.finish, difficulty:MoveDifficulty.avance, isFree:false, priceEur:4.99, xpReward:200,
      emoji:'🎣', proPlayer:'Nikola Jokić', tags:['Hook','Post','Lecture'],
      steps:['Recevoir bas dans le poste, dos au panier','Lire le défenseur sur quelle épaule il est','Pivot sur le pied opposé à la main de tir','Bras dominant en arc de cercle, balle haute','Lâcher du bout des doigts, viser le carré']),

    MoveData(id:'wade-layup-tear', title:'Tearful Layup — Dwyane Wade',
      description:'Wade finissait avec une élégance hors norme au cercle : changements de mains en l\'air, corps en rotation, balle posée comme une plume.',
      category:MoveCategory.finish, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:250,
      emoji:'🌊', proPlayer:'Dwyane Wade', tags:['Finition','Élégance','Ambidextre'],
      steps:['Drive droit vers le cercle à grande vitesse','Décollage à 1m du cercle, corps en torsion','Changer de main en l\'air selon l\'aide','Finir du côté opposé à la défense','Atterrissage équilibré, prêt à défendre']),
  ];

  // ══ 🛡️ DEFENSE — 5 gratuits + 5 premium ══════════════
  static final _defense = <MoveData>[
    MoveData(id:'defensive-stance', title:'Defensive Stance',
      description:'La base de toute défense individuelle. Une position incorrecte rend toute technique défensive inefficace.',
      category:MoveCategory.defense, difficulty:MoveDifficulty.debutant, isFree:true, xpReward:70, emoji:'🛡️',
      tags:['Fondamental','Position','Footwork'],
      steps:['Pieds à largeur d\'épaules, légèrement plus','Genoux fléchis à 90°, dos droit','Poids sur les avant-pieds','Bras tendus latéralement à hauteur de hanche','Yeux sur le nombril de l\'attaquant, pas sur la balle']),

    MoveData(id:'defensive-slide', title:'Defensive Slide',
      description:'Se déplacer latéralement sans croiser les pieds. Le fondement du footwork défensif.',
      category:MoveCategory.defense, difficulty:MoveDifficulty.debutant, isFree:true, xpReward:80, emoji:'↔️',
      tags:['Footwork','Latéral','Mobilité'],
      steps:['Position athlétique basse','Pousser avec le pied côté déplacement','Ramener l\'autre pied — ne jamais croiser','Garder la même hauteur tout au long','Exercice : 3 slides droite, 3 slides gauche × 10']),

    MoveData(id:'closeout', title:'Close-Out',
      description:'Sortir sur un shooteur ouvert en contrôlant sa vitesse. Mal exécuté, tu donnes un layup ; bien exécuté, tu contestes sans fauter.',
      category:MoveCategory.defense, difficulty:MoveDifficulty.intermediaire, isFree:true, xpReward:100, emoji:'🏃‍♂️',
      tags:['Closeout','Shooteur','Conteste'],
      steps:['Sprint vers le shooteur jusqu\'à 2m','Réduire la vitesse à 2m : pas courts et rapides','Lever LA main du côté de la balle (pas les deux)','Corps de biais, pas face à lui — éviter la faute','Rester sur ses pieds, ne pas sauter sur la feinte']),

    MoveData(id:'box-out', title:'Box Out',
      description:'Bloquer physiquement l\'adversaire pour capter le rebond. La moitié des rebonds se gagne avant que le ballon touche le cercle.',
      category:MoveCategory.defense, difficulty:MoveDifficulty.intermediaire, isFree:true, xpReward:90, emoji:'📦',
      tags:['Rebond','Post','Physique'],
      steps:['Localiser ton adversaire dès que le tir part','Se retourner vers lui avec un pivot','Placer le dos contre lui, fesses en arrière','Bras à largeur d\'épaules pour élargir la zone','Aller chercher le ballon à deux mains']),

    MoveData(id:'steal-technique', title:'Steal — Technique du Vol',
      description:'Voler la balle sans fauter demande du timing et de la lecture. Frapper sur la balle, jamais sur le bras.',
      category:MoveCategory.defense, difficulty:MoveDifficulty.intermediaire, isFree:true, xpReward:110, emoji:'🦅',
      tags:['Steal','Anticipation','Timing'],
      steps:['Lire les yeux et les épaules de l\'attaquant','Attendre que la balle commence à descendre lors du dribble','Frapper la main inférieure, pas le bras','Main du côté de la balle, pas en travers','Ne pas plonger si non sûr — mieux vaut rester en position']),

    // ── PREMIUM ──────────────────────────────────────────
    MoveData(id:'kawhi-lockdown', title:'Lockdown Defense — Kawhi',
      description:'Kawhi Leonard est le meilleur défenseur de sa génération. Sa prise de position, mains actives et anticipation créent un mur physique.',
      category:MoveCategory.defense, difficulty:MoveDifficulty.avance, isFree:false, priceEur:4.99, xpReward:230,
      emoji:'🦁', proPlayer:'Kawhi Leonard', tags:['Lockdown','1-on-1','Élite'],
      steps:['Coller à 60cm de l\'attaquant dès la réception','Mains actives — frapper les passes, pas le corps','Lire l\'épaule pour anticiper la direction','Sur catch : mains immédiatement sur le tir','Ne jamais laisser le dribble facile — toujours résistance']),

    MoveData(id:'draymond-help-defense', title:'Help Defense — Draymond',
      description:'Draymond Green orchestre la défense des Warriors depuis le poste 3/4. Sa couverture des espaces est révolutionnaire.',
      category:MoveCategory.defense, difficulty:MoveDifficulty.avance, isFree:false, priceEur:4.99, xpReward:210,
      emoji:'🎯', proPlayer:'Draymond Green', tags:['Aide','IQ','Couverture'],
      steps:['Toujours voir la balle ET ton adversaire','Se positionner à mi-chemin entre les deux','Communiquer les écrans à la voix','Sur drive adverse : plonger dans la raquette à temps','Sortir sur son adversaire si la balle lui arrive']),

    MoveData(id:'payton-on-ball', title:'On-Ball Defense — Gary Payton',
      description:'Gary Payton "The Glove" — le meilleur défenseur sur porteur de balle de l\'histoire. Pression constante, physique, harcèlement.',
      category:MoveCategory.defense, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:250,
      emoji:'🧤', proPlayer:'Gary Payton', tags:['On-ball','Pression','Harceleur'],
      steps:['Rester à 50cm — pression dès la réception','Main basse sur le dribble, main haute sur les passes','Parler sur le terrain — distraction mentale','Anticiper le côté dominant, surcharger ce côté','Conserver la position 24 secondes — pas de relâchement']),

    MoveData(id:'wallace-interior', title:'Interior Defense — Ben Wallace',
      description:'Ben Wallace protégeait la raquette avec une intensité rare. Sa technique de contre sans fauter est un art.',
      category:MoveCategory.defense, difficulty:MoveDifficulty.avance, isFree:false, priceEur:4.99, xpReward:220,
      emoji:'🧱', proPlayer:'Ben Wallace', tags:['Contre','Raquette','Physique'],
      steps:['Rester debout jusqu\'au dernier moment','Attendre que l\'attaquant soit en extension','Bloquer la balle vers le haut, pas en-dehors','Garder les pieds par terre jusqu\'au lâcher','Récupérer ou sécuriser le rebond défensif']),

    MoveData(id:'tony-allen-pest', title:'Pest Defense — Tony Allen',
      description:'Tony Allen était le meilleur paria défensif — toujours dans la tête de l\'adversaire, jamais en faute.',
      category:MoveCategory.defense, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:240,
      emoji:'🐝', proPlayer:'Tony Allen', tags:['Pression','Mental','Harcèlement'],
      steps:['Posture BASSE — jamais se redresser','Mains en mouvement constant — jamais statiques','Coller sur chaque cut et déplacement','Sur balle morte : maintenir la pression — ne pas reculer','Célébrer chaque stop défensif — mental collectif']),
  ];

  // ══ 🔥 DUNKS — 5 gratuits + 5 premium ════════════════
  static final _dunks = <MoveData>[
    MoveData(id:'basic-dunk', title:'Dunk Fondamental (2 mains)',
      description:'Le dunk de base — deux mains, approche droite, tenu. Première étape pour tout aspirant dunker.',
      category:MoveCategory.dunk, difficulty:MoveDifficulty.intermediaire, isFree:true, xpReward:150, emoji:'🔥',
      tags:['Fondamental','Force','Saut'],
      steps:['Approche en 3-4 foulées, rythme crescendo','Pied d\'appel opposé à la main dominante','Bras en balancier pour maximiser le saut','Lever les deux bras en simultané vers le cercle','Tenir l\'anneau — ne pas se laisser tomber brutalement']),

    MoveData(id:'one-hand-dunk', title:'Dunk à une main',
      description:'Première évolution : une seule main sur le cercle. Requiert plus de détente et d\'extension latérale.',
      category:MoveCategory.dunk, difficulty:MoveDifficulty.avance, isFree:true, xpReward:180, emoji:'☝️',
      tags:['Détente','Extension','Style'],
      steps:['Approche légèrement diagonale','Décollage puissant, bras libre vers le haut','Extension maximale du bras dominant','Passer la balle au-dessus du cercle','Tenir l\'anneau, main ouverte vers le bas']),

    MoveData(id:'alley-oop', title:'Alley-Oop Reception',
      description:'Recevoir une passe lobée et la convertir en dunk dans la même impulsion. La jouissance collective du basket.',
      category:MoveCategory.dunk, difficulty:MoveDifficulty.avance, isFree:true, xpReward:180, emoji:'🏌️',
      tags:['Alley-oop','Timing','Teamwork'],
      steps:['Lire la trajectoire de la passe dès le départ','Couper au bon moment vers le cercle','Décollage en synchro avec la balle en descente','Attraper et dunker en une seule action','Communiquer avec le passeur avant — signal verbal']),

    MoveData(id:'putback-dunk', title:'Putback Dunk',
      description:'Capturer un rebond offensif en l\'air et le convertir en dunk immédiatement. Pure explosivité.',
      category:MoveCategory.dunk, difficulty:MoveDifficulty.avance, isFree:true, xpReward:180, emoji:'🔃',
      tags:['Rebond offensif','Explosivité','Athletisme'],
      steps:['Positionner au bon endroit selon la trajectoire du tir','Sauter AVANT que la balle touche l\'anneau','Attraper en l\'air à deux mains','Dunker en continuité — sans retomber au sol entre les deux','Garder les bras tendus pour protéger la balle des blocs']),

    MoveData(id:'dunk-off-screen', title:'Dunk sur Écran',
      description:'Utiliser un écran pour prendre de la vitesse et dunker dans la foulée. Essentiel dans un système de jeu.',
      category:MoveCategory.dunk, difficulty:MoveDifficulty.avance, isFree:true, xpReward:160, emoji:'🚂',
      tags:['Pick','Action collective','Sprint'],
      steps:['Lire l\'écran posé par ton coéquipier','Couper au ras de l\'écran — le plus serré possible','Sprint maximum dès la sortie d\'écran','Recevoir la balle au moment du décollage','Convertir en dunk pleine vitesse']),

    // ── PREMIUM ──────────────────────────────────────────
    MoveData(id:'lebron-tomahawk', title:'Tomahawk Slam — LeBron',
      description:'Le dunk signature de LeBron James. Une main, trajectoire en arc de cercle, tenu violemment. Coupe le souffle à chaque fois.',
      category:MoveCategory.dunk, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:320,
      emoji:'👑', proPlayer:'LeBron James', tags:['Tomahawk','Force','Signature'],
      steps:['Approche diagonale côté droit, 5-6 foulées accélérées','Balle tenue à une main derrière la tête en arc','Décollage puissant pied gauche','Arc complet du bras — coude derrière la tête','Abaisser le bras VIOLEMMENT, tenir l\'anneau 1 seconde']),

    MoveData(id:'vince-windmill', title:'Windmill — Vince Carter',
      description:'Vince Carter lors du Concours de Dunks 2000 — le dunk windmill parfait. Le bras fait un cercle complet avant de rentrer.',
      category:MoveCategory.dunk, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:370,
      emoji:'💨', proPlayer:'Vince Carter', tags:['Windmill','Acrobatique','Showtime'],
      steps:['Approche droite, décollage pied gauche','Bras dominant part en bas, vers l\'extérieur','Arc complet haut→côté→bas→haut (windmill)','Balle au-dessus de l\'anneau lors du pic','Tenir fermement l\'anneau pour l\'effet dramatique']),

    MoveData(id:'lavine-360', title:'360° Dunk — Zach LaVine',
      description:'Zach LaVine au Slam Dunk Contest — rotation complète du corps en l\'air, dunk à une main. Un des dunks les plus techniques jamais vus.',
      category:MoveCategory.dunk, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:420,
      emoji:'🌪️', proPlayer:'Zach LaVine', tags:['360°','Acrobatique','Concours'],
      steps:['Approche diagonale, pick up balle bas','Décollage fort, corps commence à tourner','Rotation 360° complète du corps en l\'air','Aligner la main avec l\'anneau au retour','Tenir à une main — contrôle total']),

    MoveData(id:'dominique-power', title:'Power Slam — Dominique Wilkins',
      description:'Dominique "Human Highlight Film" Wilkins. Deux mains, force pure, hurlant dans l\'effort. L\'image même du dunk.'  ,
      category:MoveCategory.dunk, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:300,
      emoji:'💪', proPlayer:'Dominique Wilkins', tags:['Power','Force','Classique'],
      steps:['Approche d\'élan maximale — 7-8 foulées','Décollage bi-pied pour plus de hauteur','Balle ramenée derrière la tête à deux mains','Force maximale vers le bas sur l\'anneau','Tenir les deux mains — swing complet']),

    MoveData(id:'jordan-freethrow-dunk', title:'Free Throw Line — Michael Jordan',
      description:'Le dunk légendaire de Jordan lors du Slam Dunk Contest 1988. Décollage depuis la ligne des lancers francs, bras étendu.',
      category:MoveCategory.dunk, difficulty:MoveDifficulty.elite, isFree:false, priceEur:4.99, xpReward:500,
      emoji:'🐐', proPlayer:'Michael Jordan', tags:['Free-throw line','Légendaire','Historique'],
      steps:['Approche de 7-8 foulées en accélération progressive','Décollage DEPUIS la ligne des LF (4,5m du panier)','Corps incliné en avant, bras libre pour l\'équilibre','Bras dominant étendu maximum à l\'horizontale','Tenir l\'anneau, laisser le public digérer']),
  ];
}

// ── MoveData class ─────────────────────────────────────────────
class MoveData {
  final String id;
  final String title;
  final String description;
  final MoveCategory category;
  final MoveDifficulty difficulty;
  final bool isFree;
  final String? proPlayer;
  final double priceEur;
  final int xpReward;
  final String emoji;
  final List<String> tags;
  final List<String> steps;

  const MoveData({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.isFree,
    this.proPlayer,
    this.priceEur = 0,
    required this.xpReward,
    required this.emoji,
    this.tags = const [],
    this.steps = const [],
  });

  bool get isPro => !isFree;
  String get difficultyLabel { switch(difficulty) { case MoveDifficulty.debutant: return "Débutant"; case MoveDifficulty.intermediaire: return "Intermédiaire"; case MoveDifficulty.avance: return "Avancé"; case MoveDifficulty.elite: return "Élite"; } }
  String get categoryLabel => category.label;
}

enum MoveCategory {
  shoot, dribble, finish, defense, dunk;
  String get label { switch(this) { case shoot: return 'Shoot'; case dribble: return 'Dribble'; case finish: return 'Finish'; case defense: return 'Défense'; case dunk: return 'Dunks'; } }
  String get emoji { switch(this) { case shoot: return '🎯'; case dribble: return '🏀'; case finish: return '🏁'; case defense: return '🛡️'; case dunk: return '🔥'; } }
}

enum MoveDifficulty { debutant, intermediaire, avance, elite }
