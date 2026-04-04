import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:detect_fake_location/detect_fake_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/realtime_data_controller.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:ntp/ntp.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

enum LivenessAction { blink, turnLeft, turnRight }

class VerificationProgress {
  final String message;
  final double progress;

  const VerificationProgress({required this.message, required this.progress});
}

class AttendanceVerificationResult {
  final bool success;
  final String message;
  final double similarity;
  final double threshold;
  final String livenessSummary;
  final bool flashPassed;
  final Map<String, dynamic> security;

  const AttendanceVerificationResult({
    required this.success,
    required this.message,
    required this.similarity,
    required this.threshold,
    required this.livenessSummary,
    required this.flashPassed,
    required this.security,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'message': message,
      'similarity': similarity,
      'threshold': threshold,
      'liveness_summary': livenessSummary,
      'flash_passed': flashPassed,
      'security': security,
      'verified_at': DateTime.now().toIso8601String(),
    };
  }
}

class FaceAttendanceVerifier {
  FaceAttendanceVerifier({RealtimeDataController? dataController})
    : _dataController = dataController ?? RealtimeDataController(),
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          enableLandmarks: true,
          enableTracking: true,
          performanceMode: FaceDetectorMode.accurate,
          minFaceSize: 0.2,
        ),
      );

  static const String modelAssetPath = 'assets/models/mobilefacenet.tflite';
  static const int embeddingSize = 192;

  final RealtimeDataController _dataController;
  final FaceDetector _faceDetector;
  Interpreter? _interpreter;

  Future<void> close() async {
    await _faceDetector.close();
    _interpreter?.close();
    _interpreter = null;
  }

  Future<AttendanceVerificationResult> verifyAttendance({
    required CameraController cameraController,
    required String userId,
    required Future<void> Function(bool enabled) onFlashOverlay,
    required void Function(VerificationProgress progress) onProgress,
  }) async {
    onProgress(
      const VerificationProgress(
        message: 'Running security checks...',
        progress: 0.05,
      ),
    );

    final Map<String, dynamic>? userRecord = await _dataController
        .fetchUserRecordById(userId);
    if (userRecord == null) {
      return _fail('User profile not found for verification.');
    }

    final SecurityValidationResult securityValidation = await _validateSecurity(
      userRecord: userRecord,
    );
    if (!securityValidation.passed) {
      return _fail(
        securityValidation.message,
        security: securityValidation.toMap(),
      );
    }

    onProgress(
      const VerificationProgress(
        message: 'Checking face alignment...',
        progress: 0.15,
      ),
    );
    final CapturedFace? baseline = await _captureAlignedFace(cameraController);
    if (baseline == null) {
      return _fail(
        'No aligned face detected. Keep your face centered and straight.',
      );
    }

    final List<LivenessAction> challenges = _randomizedChallenges();
    for (int i = 0; i < challenges.length; i++) {
      final LivenessAction challenge = challenges[i];
      onProgress(
        VerificationProgress(
          message: 'Liveness: ${_labelForAction(challenge)}',
          progress: 0.25 + (i * 0.2),
        ),
      );

      final LivenessCheckResult challengeResult = await _runChallenge(
        cameraController: cameraController,
        baseline: baseline,
        challenge: challenge,
      );

      if (!challengeResult.passed) {
        return _fail(
          challengeResult.message,
          security: securityValidation.toMap(),
        );
      }
    }

    onProgress(
      const VerificationProgress(
        message: 'Running screen flash anti-spoof check...',
        progress: 0.7,
      ),
    );
    final bool flashPassed = await _runFlashHeuristic(
      cameraController: cameraController,
      onFlashOverlay: onFlashOverlay,
      baseline: baseline,
    );
    if (!flashPassed) {
      return _fail(
        'Screen reflection test failed. Possible spoof detected.',
        security: securityValidation.toMap(),
      );
    }

    onProgress(
      const VerificationProgress(
        message: 'Generating face embedding...',
        progress: 0.82,
      ),
    );
    final List<double>? probeEmbedding = await extractEmbeddingFromPath(
      baseline.file.path,
    );
    if (probeEmbedding == null) {
      return _fail('Failed to extract face embedding from the captured face.');
    }

    final List<List<double>> storedEmbeddings = _extractStoredEmbeddings(
      userRecord,
    );
    if (storedEmbeddings.isEmpty) {
      return _fail(
        'No enrolled face embeddings found. Please register your face again.',
      );
    }

    final double similarityThreshold = _readSimilarityThreshold(userRecord);
    final double bestSimilarity = _maxCosineSimilarity(
      probeEmbedding,
      storedEmbeddings,
    );

    if (bestSimilarity <= similarityThreshold) {
      return _fail(
        'Face did not match the enrolled profile. Similarity: ${bestSimilarity.toStringAsFixed(2)}',
        similarity: bestSimilarity,
        threshold: similarityThreshold,
        security: securityValidation.toMap(),
      );
    }

    onProgress(
      const VerificationProgress(
        message: 'Verification passed.',
        progress: 1.0,
      ),
    );

    return AttendanceVerificationResult(
      success: true,
      message: 'Face verification passed.',
      similarity: bestSimilarity,
      threshold: similarityThreshold,
      livenessSummary: 'Randomized blink/head-turn challenge passed.',
      flashPassed: true,
      security: securityValidation.toMap(),
    );
  }

  Future<List<double>?> extractEmbeddingFromPath(String imagePath) async {
    final CapturedFace? capturedFace = await _detectSingleFaceFromPath(
      imagePath,
    );
    if (capturedFace == null) {
      return null;
    }

    final File file = File(imagePath);
    if (!file.existsSync()) {
      return null;
    }

    final img.Image? decoded = img.decodeImage(file.readAsBytesSync());
    if (decoded == null) {
      return null;
    }

    final Rect bounded = _clampRect(
      capturedFace.face.boundingBox,
      decoded.width,
      decoded.height,
    );
    final img.Image faceCrop = img.copyCrop(
      decoded,
      x: bounded.left.toInt(),
      y: bounded.top.toInt(),
      width: bounded.width.toInt(),
      height: bounded.height.toInt(),
    );

    final img.Image resized = img.copyResize(faceCrop, width: 112, height: 112);
    final List<List<List<List<double>>>> input = List.generate(
      1,
      (_) => List.generate(
        112,
        (y) => List.generate(112, (x) {
          final pixel = resized.getPixel(x, y);
          final double r = (pixel.r - 127.5) / 128.0;
          final double g = (pixel.g - 127.5) / 128.0;
          final double b = (pixel.b - 127.5) / 128.0;
          return <double>[r, g, b];
        }),
      ),
    );

    final Interpreter interpreter = await _getInterpreter();
    final List<List<double>> output = List.generate(
      1,
      (_) => List.filled(embeddingSize, 0),
    );
    interpreter.run(input, output);

    return _l2Normalize(output.first);
  }

  Future<Interpreter> _getInterpreter() async {
    if (_interpreter != null) {
      return _interpreter!;
    }

    _interpreter = await Interpreter.fromAsset(modelAssetPath);
    return _interpreter!;
  }

  Future<SecurityValidationResult> _validateSecurity({
    required Map<String, dynamic> userRecord,
  }) async {
    bool fakeLocationDetected = false;
    bool jailbroken = false;
    bool developerMode = false;
    bool ntpValid = true;
    int ntpSkewMs = 0;

    try {
      fakeLocationDetected = await DetectFakeLocation().detectFakeLocation();
    } catch (_) {
      fakeLocationDetected = false;
    }

    try {
      jailbroken = await FlutterJailbreakDetection.jailbroken;
    } catch (_) {
      jailbroken = false;
    }

    try {
      final DateTime ntpNow = await NTP.now(
        timeout: const Duration(seconds: 3),
      );
      ntpSkewMs = ntpNow.difference(DateTime.now()).inMilliseconds.abs();
      ntpValid = ntpSkewMs <= 120000;
    } catch (_) {
      ntpValid = false;
    }

    if (fakeLocationDetected) {
      return SecurityValidationResult.failed(
        'Fake GPS was detected on this device.',
        fakeLocation: true,
        jailbroken: jailbroken,
        developerMode: developerMode,
        ntpSkewMs: ntpSkewMs,
        ntpValid: ntpValid,
        deviceBound: '',
        deviceCurrent: '',
      );
    }

    if (jailbroken) {
      return SecurityValidationResult.failed(
        'Root/Jailbreak detected. Attendance is blocked.',
        fakeLocation: false,
        jailbroken: true,
        developerMode: developerMode,
        ntpSkewMs: ntpSkewMs,
        ntpValid: ntpValid,
        deviceBound: '',
        deviceCurrent: '',
      );
    }

    if (!ntpValid) {
      return SecurityValidationResult.failed(
        'Device time is not trusted (NTP check failed).',
        fakeLocation: false,
        jailbroken: false,
        developerMode: developerMode,
        ntpSkewMs: ntpSkewMs,
        ntpValid: false,
        deviceBound: '',
        deviceCurrent: '',
      );
    }

    return SecurityValidationResult.success(
      fakeLocation: false,
      jailbroken: false,
      developerMode: false,
      ntpSkewMs: ntpSkewMs,
      ntpValid: true,
      deviceBound: '',
      deviceCurrent: '',
    );
  }

  Future<CapturedFace?> _captureAlignedFace(
    CameraController cameraController,
  ) async {
    for (int i = 0; i < 5; i++) {
      final XFile file = await cameraController.takePicture();
      final CapturedFace? capturedFace = await _detectSingleFaceFromPath(
        file.path,
      );
      if (capturedFace == null) {
        continue;
      }

      final double yaw = capturedFace.face.headEulerAngleY?.abs() ?? 0;
      final double pitch = capturedFace.face.headEulerAngleX?.abs() ?? 0;
      if (yaw > 15 || pitch > 10) {
        continue;
      }

      return capturedFace;
    }
    return null;
  }

  Future<CapturedFace?> _detectSingleFaceFromPath(String path) async {
    final InputImage inputImage = InputImage.fromFilePath(path);
    final List<Face> faces = await _faceDetector.processImage(inputImage);
    if (faces.length != 1) {
      return null;
    }

    return CapturedFace(file: File(path), face: faces.first);
  }

  Future<LivenessCheckResult> _runChallenge({
    required CameraController cameraController,
    required CapturedFace baseline,
    required LivenessAction challenge,
  }) async {
    final DateTime startedAt = DateTime.now();
    final double baselineEyes = _meanEyeOpen(baseline.face);

    for (int i = 0; i < 8; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 450));

      final CapturedFace? current = await _captureAlignedFace(cameraController);
      if (current == null) {
        continue;
      }

      bool actionSatisfied = false;
      final double yaw = current.face.headEulerAngleY ?? 0;
      final double currentEyes = _meanEyeOpen(current.face);

      if (challenge == LivenessAction.blink) {
        actionSatisfied = baselineEyes >= 0.6 && currentEyes <= 0.35;
      } else if (challenge == LivenessAction.turnLeft) {
        actionSatisfied = yaw <= -12;
      } else if (challenge == LivenessAction.turnRight) {
        actionSatisfied = yaw >= 12;
      }

      if (!actionSatisfied) {
        continue;
      }

      final int reactionMs = DateTime.now()
          .difference(startedAt)
          .inMilliseconds;
      if (reactionMs < 200) {
        return const LivenessCheckResult(
          passed: false,
          message: 'Liveness challenge completed too quickly. Spoof suspected.',
        );
      }

      return const LivenessCheckResult(
        passed: true,
        message: 'Liveness challenge passed.',
      );
    }

    return LivenessCheckResult(
      passed: false,
      message: 'Failed liveness challenge: ${_labelForAction(challenge)}.',
    );
  }

  Future<bool> _runFlashHeuristic({
    required CameraController cameraController,
    required Future<void> Function(bool enabled) onFlashOverlay,
    required CapturedFace baseline,
  }) async {
    final img.Image? before = img.decodeImage(
      await baseline.file.readAsBytes(),
    );
    if (before == null) {
      return false;
    }

    await onFlashOverlay(true);
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final CapturedFace? flashed = await _captureAlignedFace(cameraController);
    await onFlashOverlay(false);

    if (flashed == null) {
      return false;
    }

    final img.Image? after = img.decodeImage(await flashed.file.readAsBytes());
    if (after == null) {
      return false;
    }

    final BrightnessStats beforeStats = _faceBrightnessStats(
      before,
      baseline.face.boundingBox,
    );
    final BrightnessStats afterStats = _faceBrightnessStats(
      after,
      flashed.face.boundingBox,
    );

    final double avgDelta = (afterStats.mean - beforeStats.mean).abs();
    final double stdDelta = (afterStats.stdDev - beforeStats.stdDev).abs();

    // Heuristic: a real face reflection should change moderately, not in a flat/sharp jump.
    return avgDelta >= 3 && avgDelta <= 80 && stdDelta <= 45;
  }

  BrightnessStats _faceBrightnessStats(img.Image image, Rect box) {
    final Rect bounded = _clampRect(box, image.width, image.height);
    double sum = 0;
    double sumSq = 0;
    int count = 0;

    for (int y = bounded.top.toInt(); y < bounded.bottom.toInt(); y++) {
      for (int x = bounded.left.toInt(); x < bounded.right.toInt(); x++) {
        final pixel = image.getPixel(x, y);
        final double gray =
            (pixel.r * 0.299) + (pixel.g * 0.587) + (pixel.b * 0.114);
        sum += gray;
        sumSq += gray * gray;
        count++;
      }
    }

    if (count == 0) {
      return const BrightnessStats(mean: 0, stdDev: 0);
    }

    final double mean = sum / count;
    final double variance = max(0, (sumSq / count) - (mean * mean));
    return BrightnessStats(mean: mean, stdDev: sqrt(variance));
  }

  List<double> _l2Normalize(List<double> embedding) {
    final double norm = sqrt(
      embedding.fold<double>(0.0, (sum, v) => sum + (v * v)),
    );
    if (norm == 0) {
      return embedding;
    }
    return embedding.map((v) => v / norm).toList(growable: false);
  }

  List<List<double>> _extractStoredEmbeddings(Map<String, dynamic> userRecord) {
    final Map<String, dynamic> biometrics = _asMap(userRecord['biometrics']);
    final dynamic rawEmbeddings =
        biometrics['face_embeddings'] ?? biometrics['face_vectors'];
    if (rawEmbeddings is! List) {
      return <List<double>>[];
    }

    return rawEmbeddings
        .map((entry) {
          if (entry is List) {
            return entry
                .whereType<num>()
                .map((v) => v.toDouble())
                .toList(growable: false);
          }

          if (entry is Map) {
            final dynamic rawVector =
                entry['vector'] ?? entry['embedding'] ?? entry['values'];
            if (rawVector is List) {
              return rawVector
                  .whereType<num>()
                  .map((v) => v.toDouble())
                  .toList(growable: false);
            }
          }

          return <double>[];
        })
        .where((embedding) => embedding.length == embeddingSize)
        .toList(growable: false);
  }

  double _maxCosineSimilarity(List<double> probe, List<List<double>> enrolled) {
    double best = -1;
    for (final List<double> candidate in enrolled) {
      final double score = _cosineSimilarity(probe, candidate);
      if (score > best) {
        best = score;
      }
    }
    return best;
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length || a.isEmpty) {
      return -1;
    }

    double dot = 0;
    double normA = 0;
    double normB = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) {
      return -1;
    }

    return dot / (sqrt(normA) * sqrt(normB));
  }

  double _readSimilarityThreshold(Map<String, dynamic> userRecord) {
    final Map<String, dynamic> biometrics = _asMap(userRecord['biometrics']);
    final dynamic configured = biometrics['face_match_threshold'];
    final double threshold = configured is num ? configured.toDouble() : 0.6;
    return threshold.clamp(0.4, 0.95);
  }

  List<LivenessAction> _randomizedChallenges() {
    final List<LivenessAction> pool = <LivenessAction>[
      LivenessAction.blink,
      LivenessAction.turnLeft,
      LivenessAction.turnRight,
    ];
    pool.shuffle();
    return pool.take(2).toList(growable: false);
  }

  String _labelForAction(LivenessAction action) {
    switch (action) {
      case LivenessAction.blink:
        return 'Blink naturally';
      case LivenessAction.turnLeft:
        return 'Turn your head left';
      case LivenessAction.turnRight:
        return 'Turn your head right';
    }
  }

  double _meanEyeOpen(Face face) {
    final double left = face.leftEyeOpenProbability ?? 0.8;
    final double right = face.rightEyeOpenProbability ?? 0.8;
    return (left + right) / 2;
  }

  Rect _clampRect(Rect source, int width, int height) {
    final double left = source.left.clamp(0, width - 1).toDouble();
    final double top = source.top.clamp(0, height - 1).toDouble();
    final double right = source.right
        .clamp(left + 1, width.toDouble())
        .toDouble();
    final double bottom = source.bottom
        .clamp(top + 1, height.toDouble())
        .toDouble();
    return Rect.fromLTRB(left, top, right, bottom);
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  AttendanceVerificationResult _fail(
    String message, {
    double similarity = 0,
    double threshold = 0.6,
    Map<String, dynamic>? security,
  }) {
    return AttendanceVerificationResult(
      success: false,
      message: message,
      similarity: similarity,
      threshold: threshold,
      livenessSummary: 'Failed',
      flashPassed: false,
      security: security ?? <String, dynamic>{},
    );
  }
}

class CapturedFace {
  final File file;
  final Face face;

  const CapturedFace({required this.file, required this.face});
}

class LivenessCheckResult {
  final bool passed;
  final String message;

  const LivenessCheckResult({required this.passed, required this.message});
}

class BrightnessStats {
  final double mean;
  final double stdDev;

  const BrightnessStats({required this.mean, required this.stdDev});
}

class SecurityValidationResult {
  final bool passed;
  final String message;
  final bool fakeLocation;
  final bool jailbroken;
  final bool developerMode;
  final bool ntpValid;
  final int ntpSkewMs;
  final String deviceBound;
  final String deviceCurrent;

  const SecurityValidationResult._({
    required this.passed,
    required this.message,
    required this.fakeLocation,
    required this.jailbroken,
    required this.developerMode,
    required this.ntpValid,
    required this.ntpSkewMs,
    required this.deviceBound,
    required this.deviceCurrent,
  });

  factory SecurityValidationResult.success({
    required bool fakeLocation,
    required bool jailbroken,
    required bool developerMode,
    required bool ntpValid,
    required int ntpSkewMs,
    required String deviceBound,
    required String deviceCurrent,
  }) {
    return SecurityValidationResult._(
      passed: true,
      message: 'Security checks passed',
      fakeLocation: fakeLocation,
      jailbroken: jailbroken,
      developerMode: developerMode,
      ntpValid: ntpValid,
      ntpSkewMs: ntpSkewMs,
      deviceBound: deviceBound,
      deviceCurrent: deviceCurrent,
    );
  }

  factory SecurityValidationResult.failed(
    String message, {
    required bool fakeLocation,
    required bool jailbroken,
    required bool developerMode,
    required bool ntpValid,
    required int ntpSkewMs,
    required String deviceBound,
    required String deviceCurrent,
  }) {
    return SecurityValidationResult._(
      passed: false,
      message: message,
      fakeLocation: fakeLocation,
      jailbroken: jailbroken,
      developerMode: developerMode,
      ntpValid: ntpValid,
      ntpSkewMs: ntpSkewMs,
      deviceBound: deviceBound,
      deviceCurrent: deviceCurrent,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'passed': passed,
      'message': message,
      'fake_location': fakeLocation,
      'jailbroken': jailbroken,
      'developer_mode': developerMode,
      'ntp_valid': ntpValid,
      'ntp_skew_ms': ntpSkewMs,
      'bound_device_id': deviceBound,
      'current_device_id': deviceCurrent,
    };
  }
}
