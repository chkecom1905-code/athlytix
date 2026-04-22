import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../main.dart';
import '../../models/move_model.dart';
import '../../models/user_model.dart';
import '../../services/pose_service.dart';
import '../../services/xp_service.dart';
import '../../widgets/levelup_dialog.dart';

class VideoScanScreen extends StatefulWidget {
  final Move move;
  final UserProfile? profile;
  final Function(UserProfile) onUpdate;

  const VideoScanScreen({
    super.key,
    required this.move,
    required this.profile,
    required this.onUpdate,
  });

  @override
  State<VideoScanScreen> createState() => _VideoScanScreenState();
}

class _VideoScanScreenState extends State<VideoScanScreen>
    with TickerProviderStateMixin {
  CameraController? _camera;
  bool _cameraReady = false;
  bool _scanning = false;
  bool _processing = false;
  String? _cameraError;

  // Session state
  int _attempts = 0;
  int _maxAttempts = 5;
  int _bestScore = 0;
  List<MoveCheck> _currentChecks = [];
  MoveValidationResult? _lastResult;
  bool _sessionComplete = false;

  // Feedback animation
  late AnimationController _feedbackCtrl;
  late Animation<double> _feedbackAnim;

  // Pose detection
  Pose? _currentPose;
  Timer? _captureTimer;

  @override
  void initState() {
    super.initState();
    _feedbackCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
    _feedbackAnim = CurvedAnimation(
      parent: _feedbackCtrl, curve: Curves.easeOut);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraError = 'Aucune caméra disponible.');
        return;
      }
      // Prefer front camera for self-analysis
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _camera = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await _camera!.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (e) {
      if (mounted) setState(() => _cameraError = 'Erreur caméra: $e');
    }
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _camera?.stopImageStream();
    _camera?.dispose();
    _feedbackCtrl.dispose();
    PoseService.dispose();
    super.dispose();
  }

  void _startScan() {
    if (!_cameraReady || _scanning || _attempts >= _maxAttempts) return;
    HapticFeedback.mediumImpact();
    setState(() { _scanning = true; _currentChecks = []; _lastResult = null; });

    // Analyse every 200ms for 3 seconds
    int frames = 0;
    Map<String, int> checkVotes = {}; // label → pass count

    _captureTimer = Timer.periodic(const Duration(milliseconds: 200), (t) async {
      if (frames >= 15 || !_scanning) {
        t.cancel();
        _finalizeScan(checkVotes, frames);
        return;
      }
      if (_processing) return;
      _processing = true;
      try {
        final image = await _camera?.takePicture();
        if (image == null) { _processing = false; return; }

        final inputImage = InputImage.fromFilePath(image.path);
        final pose = await PoseService.detectPose(inputImage);
        if (pose != null) {
          final checks = PoseService.validateMove(pose, widget.move.title);
          for (final c in checks) {
            checkVotes[c.label] = (checkVotes[c.label] ?? 0) + (c.passed ? 1 : 0);
          }
          if (mounted) setState(() { _currentPose = pose; _currentChecks = checks; });
        }
        frames++;
      } finally {
        _processing = false;
      }
    });
  }

  void _finalizeScan(Map<String, int> votes, int totalFrames) {
    final template = PoseService.validateMove(
      _currentPose ?? _emptyPose(), widget.move.title);

    final finalChecks = template.map((c) {
      final passCount = votes[c.label] ?? 0;
      // Majority vote: passed if > 50% of frames it was correct
      final passed = totalFrames > 0 && (passCount / totalFrames) > 0.5;
      return MoveCheck(label: c.label, passed: passed, tip: c.tip);
    }).toList();

    final result = MoveValidationResult(checks: finalChecks);

    HapticFeedback.heavyImpact();

    setState(() {
      _scanning = false;
      _lastResult = result;
      _currentChecks = finalChecks;
      _attempts++;
      if (result.score > _bestScore) _bestScore = result.score;
      if (result.accepted || _attempts >= _maxAttempts) {
        _sessionComplete = true;
      }
    });

    _feedbackCtrl.reset();
    _feedbackCtrl.forward();

    if (_sessionComplete && result.accepted) {
      _awardXp();
    }
  }

  Future<void> _awardXp() async {
    if (widget.profile == null) return;
    await Future.delayed(const Duration(milliseconds: 600));

    final oldLevel = widget.profile!.level;
    final updated = await XpService.addXp(widget.move.xpReward, widget.profile!);
    if (updated != null) widget.onUpdate(updated);

    // Save completion
    await supabase.from('completed_moves').upsert({
      'user_id':  supabase.auth.currentUser?.id,
      'move_id':  widget.move.id,
      'score':    _bestScore,
      'attempts': _attempts,
    });

    if (!mounted) return;
    if (updated != null && updated.level > oldLevel) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => LevelUpDialog(newLevel: updated.level, xp: updated.xp));
    }
  }

  // Stub pose for fallback
  Pose _emptyPose() {
    // Returns pose with empty landmarks — checks will mostly fail gracefully
    return const Pose(landmarks: {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera or error
          if (_cameraReady && _camera != null)
            Positioned.fill(child: CameraPreview(_camera!))
          else
            Positioned.fill(child: _cameraError != null
              ? _errorView()
              : const Center(child: CircularProgressIndicator(color: AppColors.primary))),

          // Skeleton overlay
          if (_currentPose != null && _cameraReady)
            Positioned.fill(
              child: CustomPaint(
                painter: _PosePainter(_currentPose!),
              ),
            ),

          // Corner brackets
          ..._corners(),

          // Top HUD
          SafeArea(child: Column(children: [
            _topBar(context),
            const SizedBox(height: 8),
            _moveNameBadge(),
            if (_scanning) _scanningIndicator(),
          ])),

          // Bottom panel
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _bottomPanel(),
          ),

          // Result overlay
          if (_lastResult != null && !_scanning)
            Positioned.fill(child: _resultOverlay()),

          // Session complete
          if (_sessionComplete)
            Positioned.fill(child: _sessionCompleteOverlay()),
        ],
      ),
    );
  }

  Widget _errorView() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 60),
      const SizedBox(height: 16),
      Text(_cameraError ?? 'Initialisation caméra…',
        style: AppTextStyles.body, textAlign: TextAlign.center),
      const SizedBox(height: 16),
      // Demo mode button
      ElevatedButton(
        onPressed: _simulateScan,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
        child: const Text('Mode Démo (sans caméra)'),
      ),
    ]),
  );

  void _simulateScan() {
    // Simulate a scan result for demo / testing without camera
    setState(() { _scanning = true; _currentChecks = []; });
    Future.delayed(const Duration(seconds: 2), () {
      final fakeChecks = [
        MoveCheck(label: 'Position des pieds', passed: true, tip: ''),
        MoveCheck(label: 'Genoux fléchis', passed: true, tip: ''),
        MoveCheck(label: 'Bras position', passed: false,
          tip: 'Remontez le bras droit au-dessus de l\'épaule.'),
      ];
      _finalizeScan(
        {for (var c in fakeChecks) c.label: c.passed ? 1 : 0}, 1);
    });
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18)),
          ),
          // Attempts counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54, borderRadius: BorderRadius.circular(12)),
            child: Text('$_attempts / $_maxAttempts tentatives',
              style: const TextStyle(color: Colors.white, fontSize: 12,
                fontWeight: FontWeight.w700)),
          ),
          // Best score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54, borderRadius: BorderRadius.circular(12)),
            child: Text('Meilleur: $_bestScore%',
              style: TextStyle(
                color: _bestScore >= 66 ? AppColors.success : Colors.white,
                fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _moveNameBadge() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Text('MOVE EN COURS', style: TextStyle(
          color: Colors.white.withOpacity(0.6), fontSize: 9,
          fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        Text(widget.move.title, style: const TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
      ]),
    );
  }

  Widget _scanningIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.5))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 10, height: 10,
          child: CircularProgressIndicator(
            color: AppColors.primary, strokeWidth: 2)),
        const SizedBox(width: 8),
        const Text('Scan en cours…', style: TextStyle(
          color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  List<Widget> _corners() {
    const bw = 2.0;
    const sz = 28.0;
    const col = AppColors.primary;
    return [
      Positioned(top: 100, left: 24, child: _corner(true,  true,  sz, bw, col)),
      Positioned(top: 100, right: 24, child: _corner(true,  false, sz, bw, col)),
      Positioned(bottom: 140, left: 24, child: _corner(false, true,  sz, bw, col)),
      Positioned(bottom: 140, right: 24, child: _corner(false, false, sz, bw, col)),
    ];
  }

  Widget _corner(bool top, bool left, double sz, double bw, Color c) {
    return SizedBox(width: sz, height: sz,
      child: CustomPaint(painter: _CornerPainter(top, left, bw, c)));
  }

  Widget _bottomPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.border))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Live checks
        if (_currentChecks.isNotEmpty) ...[
          ...(_currentChecks.take(3).map((c) => _checkRow(c))),
          const SizedBox(height: 12),
        ],
        // Scan button
        Row(children: [
          _scoreCircle(),
          const SizedBox(width: 20),
          Expanded(child: _scanBtn()),
        ]),
      ]),
    );
  }

  Widget _scoreCircle() {
    return Container(
      width: 70, height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _bestScore >= 66 ? AppColors.success : AppColors.primary,
          width: 3)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$_bestScore%', style: TextStyle(
          color: _bestScore >= 66 ? AppColors.success : AppColors.primary,
          fontSize: 18, fontWeight: FontWeight.w800)),
        Text('meilleur', style: TextStyle(
          color: AppColors.textMuted, fontSize: 9)),
      ]),
    );
  }

  Widget _scanBtn() {
    final disabled = _scanning || _attempts >= _maxAttempts;
    return GestureDetector(
      onTap: disabled ? null : _startScan,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: disabled
              ? const LinearGradient(colors: [Color(0xFF1E1E32), Color(0xFF1E1E32)])
              : AppColors.orangeGradient,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(child: _scanning
          ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : Text(
              _attempts >= _maxAttempts ? 'Session terminée' : 'Démarrer le scan',
              style: GoogleFonts.inter(
                color: disabled ? AppColors.textMuted : Colors.white,
                fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _checkRow(MoveCheck c) {
    final color = c.passed ? AppColors.success : AppColors.warning;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(c.passed ? Icons.check_circle_rounded : Icons.warning_rounded,
          color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(
          c.passed ? c.label : c.tip,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _resultOverlay() {
    final r = _lastResult!;
    return FadeTransition(
      opacity: _feedbackAnim,
      child: Positioned(
        bottom: 170,
        left: 16, right: 16,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: r.accepted
                ? AppColors.success.withOpacity(0.15)
                : AppColors.warning.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: r.accepted
                  ? AppColors.success.withOpacity(0.5)
                  : AppColors.warning.withOpacity(0.5))),
          child: Column(children: [
            Row(children: [
              Text(r.accepted ? '✅' : '⚠️', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.accepted ? 'Move validé ! 🔥' : 'Pas encore…',
                  style: GoogleFonts.inter(
                    color: r.accepted ? AppColors.success : AppColors.warning,
                    fontSize: 16, fontWeight: FontWeight.w800)),
                Text('Score: ${r.score}% — ${r.accepted ? "≥ 66% requis ✓" : "< 66% requis"}',
                  style: AppTextStyles.body.copyWith(fontSize: 12)),
              ])),
            ]),
            if (!r.accepted && r.checks.any((c) => !c.passed)) ...[
              const SizedBox(height: 10),
              ...r.checks.where((c) => !c.passed).take(2).map((c) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    const Icon(Icons.arrow_right, color: AppColors.warning, size: 16),
                    Expanded(child: Text(c.tip, style: TextStyle(
                      color: AppColors.warning, fontSize: 11))),
                  ]),
                )),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _sessionCompleteOverlay() {
    final success = _bestScore >= 66;
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: success ? AppColors.success : AppColors.primary, width: 2)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(success ? '🏆' : '💪', style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(success ? 'Move maîtrisé !' : 'Continue l\'entraînement !',
              style: AppTextStyles.heading2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Meilleur score : $_bestScore%',
              style: TextStyle(
                color: success ? AppColors.success : AppColors.primary,
                fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            if (success) Text('+${widget.move.xpReward} XP ajoutés !',
              style: TextStyle(color: AppColors.primary, fontSize: 14,
                fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => setState(() {
                  _sessionComplete = false;
                  _attempts = 0;
                  _bestScore = 0;
                  _lastResult = null;
                  _currentChecks = [];
                }),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
                child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
              )),
              const SizedBox(width: 12),
              Expanded(child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(14)),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
                  child: const Text('Terminer',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              )),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ── Pose skeleton painter ─────────────────────────────────
class _PosePainter extends CustomPainter {
  final Pose pose;
  _PosePainter(this.pose);

  static const _connections = [
    [PoseLandmarkType.leftShoulder,  PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder,  PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow,     PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow,    PoseLandmarkType.rightWrist],
    [PoseLandmarkType.leftShoulder,  PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip,       PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip,       PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee,      PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip,      PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee,     PoseLandmarkType.rightAnkle],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final bonePaint = Paint()
      ..color = const Color(0xFF00FF88).withOpacity(0.7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    // Draw bones
    for (final conn in _connections) {
      final a = pose.landmarks[conn[0]];
      final b = pose.landmarks[conn[1]];
      if (a != null && b != null) {
        canvas.drawLine(
          Offset(a.x * size.width, a.y * size.height),
          Offset(b.x * size.width, b.y * size.height),
          bonePaint,
        );
      }
    }

    // Draw joints
    for (final landmark in pose.landmarks.values) {
      canvas.drawCircle(
        Offset(landmark.x * size.width, landmark.y * size.height),
        5,
        jointPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_PosePainter old) => old.pose != pose;
}

// ── Corner bracket painter ────────────────────────────────
class _CornerPainter extends CustomPainter {
  final bool top, left;
  final double strokeW;
  final Color color;
  _CornerPainter(this.top, this.left, this.strokeW, this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = strokeW..style = PaintingStyle.stroke;
    final path = Path();
    if (top && left) {
      path.moveTo(0, s.height); path.lineTo(0, 0); path.lineTo(s.width, 0);
    } else if (top && !left) {
      path.moveTo(0, 0); path.lineTo(s.width, 0); path.lineTo(s.width, s.height);
    } else if (!top && left) {
      path.moveTo(0, 0); path.lineTo(0, s.height); path.lineTo(s.width, s.height);
    } else {
      path.moveTo(0, s.height); path.lineTo(s.width, s.height); path.lineTo(s.width, 0);
    }
    canvas.drawPath(path, p);
  }

  @override bool shouldRepaint(_) => false;
}
