import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Utility class for AI-powered face detection and validation
class FaceDetectionUtil {
  /// Validate face characteristics and return feedback
  /// Returns null if all validations pass, otherwise returns error message
  static Future<String?> validateFaceQuality(Face face, Size imageSize) async {
    try {
      // 1. HEAD MUST BE REASONABLY STRAIGHT
      final double yaw = face.headEulerAngleY?.abs() ?? 0;
      final double pitch = face.headEulerAngleX?.abs() ?? 0;

      if (yaw > 15 || pitch > 12) {
        return 'face_not_straight';
      }

      // 2. FACE SIZE SHOULD BE NORMAL (NOT TOO SMALL)
      final box = face.boundingBox;
      final faceArea = box.width * box.height;
      final imageArea = imageSize.width * imageSize.height;

      final ratio = faceArea / imageArea;

      // Keep minimum practical size for embedding quality.
      if (ratio < 0.18) {
        return 'move_closer_full_face_required';
      }

      // 3. FACE MUST BE CENTERED
      final centerX = box.left + box.width / 2;
      final centerY = box.top + box.height / 2;

      final offsetX = (centerX - imageSize.width / 2).abs();
      final offsetY = (centerY - imageSize.height / 2).abs();

      if (offsetX > imageSize.width * 0.2 || offsetY > imageSize.height * 0.2) {
        return 'face_not_centered';
      }

      // 4. EYES MUST BE CLEAR
      final double leftOpen = face.leftEyeOpenProbability ?? 0;
      final double rightOpen = face.rightEyeOpenProbability ?? 0;

      if (leftOpen < 0.5 || rightOpen < 0.5) {
        return 'eyes_not_clear';
      }

      // 5. NEUTRAL EXPRESSION
      final double smiling = face.smilingProbability ?? 0;
      if (smiling > 0.4) {
        return 'keep_neutral_expression';
      }

      // 6. LIGHT CHECK (reuse your logic)
      if (detectLightPollution(face)) {
        return 'bad_lighting';
      }

      // 7. STRICT GLASSES CHECK
      if (detectGlasses(face)) {
        return 'remove_glasses_alert';
      }

      // 8. STRICT HAT CHECK
      if (detectHat(face, imageSize)) {
        return 'remove_hat_alert';
      }

      return null; // All checks passed
    } catch (e) {
      debugPrint('Face validation error: $e');
      return 'face_validation_error';
    }
  }

  /// Process image and detect faces
  static Future<List<Face>> detectFacesInImage(XFile imageFile) async {
    final faceDetector = createFaceDetector();
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      return await faceDetector.processImage(inputImage);
    } catch (e) {
      debugPrint('Face detection error: $e');
      return <Face>[];
    } finally {
      await faceDetector.close();
    }
  }

  /// Read image dimensions from a captured file.
  static Future<Size> getImageSize(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final size = Size(image.width.toDouble(), image.height.toDouble());
      image.dispose();
      codec.dispose();
      return size;
    } catch (e) {
      debugPrint('Image size read error: $e');
      return const Size(1080, 1920);
    }
  }

  /// Create face detector with optimized settings
  static FaceDetector createFaceDetector() {
    return FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        minFaceSize: 0.3,
      ),
    );
  }

  static bool detectGlasses(Face face) {
    try {
      final lm = face.landmarks;

      final leftEye = lm[FaceLandmarkType.leftEye]?.position;
      final rightEye = lm[FaceLandmarkType.rightEye]?.position;
      final nose = lm[FaceLandmarkType.noseBase]?.position;
      final leftCheek = lm[FaceLandmarkType.leftCheek]?.position;
      final rightCheek = lm[FaceLandmarkType.rightCheek]?.position;

      final leftOpen = face.leftEyeOpenProbability ?? 1.0;
      final rightOpen = face.rightEyeOpenProbability ?? 1.0;
      final avgOpen = (leftOpen + rightOpen) / 2;

      final yaw = (face.headEulerAngleY ?? 0).abs();
      final isStraight = yaw < 12;

      // ─────────────────────────────
      //  1. HARD FAIL (instant block)
      // ─────────────────────────────
      if (leftEye == null && rightEye == null) return true;

      if (isStraight && leftEye == null || rightEye == null) {
        return true;
      }

      // ─────────────────────────────
      //  2. SOFT SCORING
      // ─────────────────────────────
      int score = 0;

      // Eye confidence suppression
      if (avgOpen < 0.75)
        score += 2;
      else if (avgOpen < 0.82)
        score += 1;

      // Eye asymmetry (only when straight)
      final diff = (leftOpen - rightOpen).abs();
      if (isStraight && diff > 0.18)
        score += 2;
      else if (isStraight && diff > 0.10)
        score += 1;

      // Geometry checks
      if (leftEye != null && nose != null) {
        final eyeDist = (rightEye.x - leftEye.x).abs();
        if (eyeDist > 0) {
          final eyeMidY = (leftEye.y + rightEye.y) / 2;
          final ratio = (nose.y - eyeMidY).abs() / eyeDist;

          if (isStraight && ratio < 0.42)
            score += 2;
          else if (isStraight && ratio < 0.52)
            score += 1;
        }
      }

      // Eye vs cheek ratio
      if (leftEye != null && leftCheek != null && rightCheek != null) {
        final eyeSpan = (rightEye.x - leftEye.x).abs();
        final cheekSpan = (rightCheek.x - leftCheek.x).abs();

        if (cheekSpan > 0) {
          final ratio = eyeSpan / cheekSpan;

          if (ratio > 0.88)
            score += 2;
          else if (ratio > 0.78)
            score += 1;
        }
      }

      // ─────────────────────────────
      //  3. REFLECTION BOOST
      // ─────────────────────────────
      if (detectGlassesReflection(face)) {
        score += 2;
      }

      // ─────────────────────────────
      //  FINAL DECISION
      // ─────────────────────────────
      return score >= 3;
    } catch (e) {
      debugPrint('Glasses detection error: $e');
      return true; // fail safe
    }
  }

  // ─────────────────────────────────────────────
  // SIGNAL 8: Screen reflection detection
  static bool detectGlassesReflection(Face face) {
    try {
      final leftOpen = face.leftEyeOpenProbability ?? 0.0;
      final rightOpen = face.rightEyeOpenProbability ?? 0.0;

      final lm = face.landmarks;
      final leftEye = lm[FaceLandmarkType.leftEye]?.position;
      final rightEye = lm[FaceLandmarkType.rightEye]?.position;
      final nose = lm[FaceLandmarkType.noseBase]?.position;
      final leftCheek = lm[FaceLandmarkType.leftCheek]?.position;
      final rightCheek = lm[FaceLandmarkType.rightCheek]?.position;

      final yaw = (face.headEulerAngleY ?? 0).abs();

      // ✅ Relaxed condition (important)
      if (yaw > 12) return false;

      int score = 0;

      // ── CLUE 1: High eye openness (relaxed)
      if (leftOpen > 0.90 && rightOpen > 0.90) {
        score += 1;
      }

      // ── CLUE 2: Symmetry (relaxed)
      final diff = (leftOpen - rightOpen).abs();
      if (leftOpen > 0.85 && rightOpen > 0.85 && diff < 0.03) {
        score += 2;
      }

      // ── CLUE 3: Vertical distortion (safer)
      if (leftEye != null && rightEye != null && nose != null) {
        final eyeMidY = (leftEye.y + rightEye.y) / 2;
        final eyeDist = (rightEye.x - leftEye.x).abs();

        if (eyeDist > 0) {
          final ratio = (nose.y - eyeMidY).abs() / eyeDist;

          if (ratio < 0.35) {
            score += 2;
          } else if (ratio < 0.45) {
            score += 1;
          }
        }
      }

      // ── CLUE 4: Span check (keep light)
      if (leftEye != null &&
          rightEye != null &&
          leftCheek != null &&
          rightCheek != null) {
        final eyeSpan = (rightEye.x - leftEye.x).abs();
        final cheekSpan = (rightCheek.x - leftCheek.x).abs();

        if (cheekSpan > 0) {
          final ratio = eyeSpan / cheekSpan;

          if (ratio > 0.88) {
            score += 1;
          }
        }
      }

      // ── CLUE 5: Y symmetry (relaxed)
      if (leftEye != null && rightEye != null) {
        final yDiff = (leftEye.y - rightEye.y).abs();
        final eyeDist = (rightEye.x - leftEye.x).abs();

        if (eyeDist > 0) {
          final ratio = yDiff / eyeDist;

          if (ratio < 0.025) {
            score += 1;
          }
        }
      }

      //  Slightly lower threshold
      return score >= 3;
    } catch (e) {
      debugPrint('Reflection detection error: $e');
      return false;
    }
  }

  /// IMPROVED light pollution detection using landmark spread + bounding box position
  static bool detectLightPollution(Face face, {Size? imageSize}) {
    try {
      final leftOpen = face.leftEyeOpenProbability ?? 0.5;
      final rightOpen = face.rightEyeOpenProbability ?? 0.5;

      // --- SIGNAL 1: Both eyes near-fully closed (underexposed / blown out) ---
      // Very strict threshold — only fire when both are extremely low
      if (leftOpen < 0.08 && rightOpen < 0.08) return true;

      // --- SIGNAL 2: Both eyes near-perfectly open is NOT a light issue ---
      // Removed the > 0.985 check — that's a normal well-lit face

      // --- SIGNAL 3: Landmark spread relative to bounding box ---
      final box = face.boundingBox;
      final boxW = box.width;
      final boxH = box.height;

      if (boxW <= 0 || boxH <= 0) return false;

      final validPositions = face.landmarks.values
          .where((l) => l != null)
          .map((l) => l!.position)
          .toList();

      if (validPositions.isEmpty) {
        return true; // No landmarks at all = bad image
      }

      // Compute landmark spread as fraction of bounding box
      double minLx = double.infinity, maxLx = double.negativeInfinity;
      double minLy = double.infinity, maxLy = double.negativeInfinity;

      for (final pos in validPositions) {
        final x = pos.x.toDouble();
        final y = pos.y.toDouble();
        if (x < minLx) minLx = x;
        if (x > maxLx) maxLx = x;
        if (y < minLy) minLy = y;
        if (y > maxLy) maxLy = y;
      }

      final spreadX = (maxLx - minLx) / boxW;
      final spreadY = (maxLy - minLy) / boxH;

      // If landmarks are all clustered into a tiny area of the face box
      // it usually means the image is overexposed / washed out
      if (validPositions.length >= 3 && spreadX < 0.12 && spreadY < 0.12) {
        return true;
      }

      // --- SIGNAL 4: Landmark count vs head pose ---
      // Straight-facing head should have most landmarks visible
      final yaw = face.headEulerAngleY?.abs() ?? 0;
      final pitch = face.headEulerAngleX?.abs() ?? 0;
      final headStraight = yaw < 10 && pitch < 10;

      if (headStraight && validPositions.length < 4) {
        // Straight face with very few landmarks = likely occlusion or bad lighting
        return true;
      }

      // --- SIGNAL 5: Landmark boundary check (resolution-independent) ---
      if (imageSize != null && imageSize.width > 0 && imageSize.height > 0) {
        final marginX = imageSize.width * 0.05;
        final marginY = imageSize.height * 0.05;

        // If ALL landmarks are near the image border → something is very wrong
        final allAtBorder = validPositions.every((pos) {
          final x = pos.x.toDouble();
          final y = pos.y.toDouble();
          return x < marginX ||
              x > imageSize.width - marginX ||
              y < marginY ||
              y > imageSize.height - marginY;
        });

        if (headStraight && allAtBorder && validPositions.length >= 3) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Light pollution detection error: $e');
      return false;
    }
  }

  /// Detect hat / head obstruction
  static bool detectHat(Face face, Size imageSize) {
    try {
      final box = face.boundingBox;

      // Too close to top → likely hat or cut
      if (box.top < imageSize.height * 0.05) {
        return true;
      }

      final hasLeftEye = face.landmarks[FaceLandmarkType.leftEye] != null;
      final hasRightEye = face.landmarks[FaceLandmarkType.rightEye] != null;

      if (hasLeftEye && hasRightEye) {
        final foreheadSpace = box.top;

        if (foreheadSpace < imageSize.height * 0.08) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Hat detection error: $e');
      return true; // strict
    }
  }
}
