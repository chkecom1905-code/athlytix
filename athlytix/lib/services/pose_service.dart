// lib/services/pose_service.dart
import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Wraps ML Kit Pose Detection and validates basketball moves.
class PoseService {
  static final PoseDetector _detector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    ),
  );

  static Future<Pose?> detectPose(InputImage image) async {
    final poses = await _detector.processImage(image);
    return poses.isNotEmpty ? poses.first : null;
  }

  static void dispose() => _detector.close();

  // ── Angle between three landmarks ─────────────────────
  static double angle(
    PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final ab = _vec(a, b);
    final cb = _vec(c, b);
    final dot   = ab['x']! * cb['x']! + ab['y']! * cb['y']!;
    final magAB = sqrt(ab['x']! * ab['x']! + ab['y']! * ab['y']!);
    final magCB = sqrt(cb['x']! * cb['x']! + cb['y']! * cb['y']!);
    if (magAB == 0 || magCB == 0) return 0;
    return acos((dot / (magAB * magCB)).clamp(-1.0, 1.0)) * (180 / pi);
  }

  static Map<String, double> _vec(PoseLandmark a, PoseLandmark b) =>
      {'x': a.x - b.x, 'y': a.y - b.y};

  // ── Generic move validator ─────────────────────────────
  /// Returns a list of [MoveCheck] with pass/fail for each rule.
  static List<MoveCheck> validateMove(Pose pose, String moveName) {
    switch (moveName) {
      case 'Crossover Basique':    return _checkCrossover(pose);
      case 'Behind the Back':      return _checkBehindBack(pose);
      case 'Between the Legs':     return _checkBetweenLegs(pose);
      case 'Spin Move':            return _checkSpin(pose);
      case 'Curry Shake':          return _checkCurryShake(pose);
      case 'LeBron Euro Step':     return _checkEuroStep(pose);
      case 'Doncic Step-Back 3pts':return _checkStepBack(pose);
      case 'KD Fadeaway':          return _checkFadeaway(pose);
      default:                     return _checkGeneric(pose);
    }
  }

  // ── Individual move validations ─────────────────────────

  static List<MoveCheck> _checkCrossover(Pose pose) {
    final rWrist  = pose.landmarks[PoseLandmarkType.rightWrist];
    final rHip    = pose.landmarks[PoseLandmarkType.rightHip];
    final lKnee   = pose.landmarks[PoseLandmarkType.leftKnee];
    final rKnee   = pose.landmarks[PoseLandmarkType.rightKnee];

    final checks = <MoveCheck>[];

    // Wrist must be below hip (low dribble position)
    if (rWrist != null && rHip != null) {
      checks.add(MoveCheck(
        label: 'Dribble bas (poignet)',
        passed: rWrist.y > rHip.y,
        tip: 'Gardez le dribble sous la hanche — plus bas !',
      ));
    }

    // Knees should be bent (athletic stance)
    if (lKnee != null && rKnee != null) {
      final lHip   = pose.landmarks[PoseLandmarkType.leftHip];
      final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
      if (lHip != null && lAnkle != null) {
        final bendAngle = angle(lHip, lKnee, lAnkle);
        checks.add(MoveCheck(
          label: 'Genoux fléchis',
          passed: bendAngle < 160,
          tip: 'Fléchissez davantage les genoux — posture athlétique !',
        ));
      }
    }

    checks.add(MoveCheck(
      label: 'Direction du crossover',
      passed: rWrist != null && (rWrist.x < 0.5),
      tip: 'Croisez plus loin devant vous.',
    ));

    return checks;
  }

  static List<MoveCheck> _checkBehindBack(Pose pose) {
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final rHip   = pose.landmarks[PoseLandmarkType.rightHip];
    final lHip   = pose.landmarks[PoseLandmarkType.leftHip];

    return [
      MoveCheck(
        label: 'Main dans le dos',
        passed: rWrist != null && rHip != null &&
                (rWrist.x - rHip.x).abs() > 0.05,
        tip: 'Passez la balle plus loin derrière le dos.',
      ),
      MoveCheck(
        label: 'Hanches ouvertes',
        passed: rHip != null && lHip != null &&
                (rHip.x - lHip.x).abs() > 0.08,
        tip: 'Ouvrez davantage les hanches pour la rotation.',
      ),
      MoveCheck(
        label: 'Torse droit',
        passed: true, // Simplified
        tip: 'Gardez le dos droit pendant le mouvement.',
      ),
    ];
  }

  static List<MoveCheck> _checkBetweenLegs(Pose pose) {
    final rWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final lKnee  = pose.landmarks[PoseLandmarkType.leftKnee];
    final rKnee  = pose.landmarks[PoseLandmarkType.rightKnee];

    return [
      MoveCheck(
        label: 'Passage entre les genoux',
        passed: rWrist != null && lKnee != null && rKnee != null &&
                rWrist.y > min(lKnee.y, rKnee.y),
        tip: 'La main doit descendre entre les genoux.',
      ),
      MoveCheck(
        label: 'Écart des jambes',
        passed: lKnee != null && rKnee != null &&
                (lKnee.x - rKnee.x).abs() > 0.15,
        tip: 'Écartez plus les jambes pour faciliter le passage.',
      ),
    ];
  }

  static List<MoveCheck> _checkSpin(Pose pose) {
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    return [
      MoveCheck(
        label: 'Rotation des épaules',
        passed: lShoulder != null && rShoulder != null &&
                (lShoulder.x - rShoulder.x).abs() < 0.04,
        tip: 'Tournez complètement les épaules pour le spin.',
      ),
      MoveCheck(
        label: 'Protection de balle',
        passed: pose.landmarks[PoseLandmarkType.rightElbow] != null,
        tip: 'Couvrez la balle avec le coude pendant la rotation.',
      ),
    ];
  }

  static List<MoveCheck> _checkCurryShake(Pose pose) {
    final rWrist    = pose.landmarks[PoseLandmarkType.rightWrist];
    final lWrist    = pose.landmarks[PoseLandmarkType.leftWrist];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];

    return [
      MoveCheck(
        label: 'Double fausse passe',
        passed: rWrist != null && lWrist != null &&
                (rWrist.x - lWrist.x).abs() > 0.12,
        tip: 'Exagérez le mouvement de passe des deux mains.',
      ),
      MoveCheck(
        label: 'Mouvement latéral des épaules',
        passed: rShoulder != null && lShoulder != null &&
                (rShoulder.y - lShoulder.y).abs() > 0.03,
        tip: 'Inclinez les épaules lors de la feinte.',
      ),
      MoveCheck(
        label: 'Décalage des hanches',
        passed: pose.landmarks[PoseLandmarkType.rightHip] != null,
        tip: 'Déplacez les hanches dans la direction opposée.',
      ),
    ];
  }

  static List<MoveCheck> _checkEuroStep(Pose pose) {
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    return [
      MoveCheck(
        label: 'Pas latéral',
        passed: lAnkle != null && rAnkle != null &&
                (lAnkle.x - rAnkle.x).abs() > 0.20,
        tip: 'Faites un plus grand pas de côté.',
      ),
      MoveCheck(
        label: 'Pied d\'appel planté',
        passed: rAnkle != null,
        tip: 'Plantez fermement le pied d\'appui.',
      ),
      MoveCheck(
        label: 'Protection de balle',
        passed: pose.landmarks[PoseLandmarkType.rightElbow] != null,
        tip: 'Protégez la balle avec le coude.',
      ),
    ];
  }

  static List<MoveCheck> _checkStepBack(Pose pose) {
    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    final rHip   = pose.landmarks[PoseLandmarkType.rightHip];
    final rWrist  = pose.landmarks[PoseLandmarkType.rightWrist];
    final lElbow  = pose.landmarks[PoseLandmarkType.leftElbow];

    return [
      MoveCheck(
        label: 'Recul du pied',
        passed: rAnkle != null && rHip != null && rAnkle.y < rHip.y,
        tip: 'Reculez plus franchement le pied droit.',
      ),
      MoveCheck(
        label: 'Position de tir',
        passed: rWrist != null && lElbow != null &&
                rWrist.y < lElbow.y,
        tip: 'Montez la balle en position de tir.',
      ),
      MoveCheck(
        label: 'Équilibre',
        passed: true,
        tip: 'Restez équilibré malgré le recul.',
      ),
    ];
  }

  static List<MoveCheck> _checkFadeaway(Pose pose) {
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rHip      = pose.landmarks[PoseLandmarkType.rightHip];

    return [
      MoveCheck(
        label: 'Inclinaison arrière',
        passed: rShoulder != null && rHip != null &&
                rShoulder.y < rHip.y,
        tip: 'Penchez davantage vers l\'arrière.',
      ),
      MoveCheck(
        label: 'Bras haut au lâcher',
        passed: pose.landmarks[PoseLandmarkType.rightWrist] != null &&
                pose.landmarks[PoseLandmarkType.rightElbow] != null,
        tip: 'Étendez complètement les bras vers le haut.',
      ),
      MoveCheck(
        label: 'Équilibre du fadeaway',
        passed: lShoulder != null && rShoulder != null,
        tip: 'Gardez les épaules alignées pendant le fadeaway.',
      ),
    ];
  }

  static List<MoveCheck> _checkGeneric(Pose pose) {
    final hip   = pose.landmarks[PoseLandmarkType.rightHip];
    final knee  = pose.landmarks[PoseLandmarkType.rightKnee];
    final ankle = pose.landmarks[PoseLandmarkType.rightAnkle];

    return [
      MoveCheck(
        label: 'Position athlétique',
        passed: hip != null && knee != null && ankle != null,
        tip: 'Adoptez une position athlétique de base.',
      ),
      MoveCheck(
        label: 'Équilibre général',
        passed: pose.landmarks[PoseLandmarkType.leftAnkle] != null &&
                pose.landmarks[PoseLandmarkType.rightAnkle] != null,
        tip: 'Répartissez votre poids équitablement.',
      ),
    ];
  }
}

// ── Result model ──────────────────────────────────────────
class MoveCheck {
  final String label;
  final bool passed;
  final String tip;

  const MoveCheck({
    required this.label,
    required this.passed,
    required this.tip,
  });
}

class MoveValidationResult {
  final List<MoveCheck> checks;
  final int score;  // 0–100
  final bool accepted;

  MoveValidationResult({required this.checks})
      : score = checks.isEmpty
            ? 0
            : ((checks.where((c) => c.passed).length / checks.length) * 100)
                .round(),
        accepted = checks.isNotEmpty &&
            checks.where((c) => c.passed).length >=
                (checks.length * 0.66).ceil();
}
