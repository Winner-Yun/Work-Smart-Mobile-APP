import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/util/cloudinary/cloudinary_profile_image_service.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/realtime_data_controller.dart';
import 'package:flutter_worksmart_mobile_app/core/util/face/face_attendance_verifier.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/homepage_screens/assign_user_face_screen.dart';
import 'package:flutter_worksmart_mobile_app/features/user/utils/face_detection_util.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class RegisterFaceLogic extends State<RegisterFaceScanScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  bool isCameraInitialized = false;
  bool isChangingLanguage = false;
  bool isBackCamera = false;
  bool isFlashOn = false;
  int currentPhotoCount = 0;
  final int totalRequired = 1;
  int countdown = 0;
  Timer? timer;
  late AnimationController laserController;
  bool isUploadingFaceSample = false;
  bool isApprovingFace = false;

  final RealtimeDataController _realtimeDataController =
      RealtimeDataController();
  final CloudinaryProfileImageService _cloudinaryProfileImageService =
      CloudinaryProfileImageService();
  final List<String> _capturedFaceImageUrls = <String>[];
  final List<List<double>> _capturedEmbeddings = <List<double>>[];
  late final FaceAttendanceVerifier _faceAttendanceVerifier;

    String? get latestCapturedFaceImageUrl =>
      _capturedFaceImageUrls.isNotEmpty ? _capturedFaceImageUrls.first : null;

  bool get isCaptureBusy =>
      countdown > 0 || isUploadingFaceSample || isApprovingFace;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initCamera();
    laserController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _faceAttendanceVerifier = FaceAttendanceVerifier();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    laserController.dispose();
    timer?.cancel();
    _faceAttendanceVerifier.close();
    super.dispose();
  }

  Future<void> initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;

    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      await startCamera(
        cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        ),
      );
    }
  }

  Future<void> startCamera(CameraDescription desc) async {
    if (controller != null) await controller!.dispose();
    controller = CameraController(
      desc,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await controller!.initialize();
      isBackCamera = desc.lensDirection == CameraLensDirection.back;
      if (mounted) setState(() => isCameraInitialized = true);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> toggleCamera() async {
    if (cameras.isEmpty) return;
    final newDesc = isBackCamera
        ? cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
          )
        : cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
          );
    setState(() => isCameraInitialized = false);
    await startCamera(newDesc);
  }

  Future<void> toggleFlash() async {
    if (controller == null || !isBackCamera) return;
    isFlashOn = !isFlashOn;
    await controller!.setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  Future<void> toggleLanguage() async {
    setState(() => isChangingLanguage = true);
    await Future.delayed(const Duration(milliseconds: 600));
    final current = LanguageManager().locale;
    await LanguageManager().changeLanguage(current == 'en' ? 'km' : 'en');
    if (mounted) setState(() => isChangingLanguage = false);
  }

  void startCaptureProcess() {
    if (isCaptureBusy || currentPhotoCount >= totalRequired) return;
    setState(() => countdown = 3);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown > 1) {
        setState(() => countdown--);
      } else {
        timer?.cancel();
        setState(() => countdown = 0);
        takePhoto();
      }
    });
  }

  Future<void> takePhoto() async {
    if (controller == null ||
        !controller!.value.isInitialized ||
        isCaptureBusy) {
      return;
    }

    final String userId = _resolveUserId();
    if (userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr('unable_to_resolve_user_id'))),
      );
      return;
    }

    setState(() => isUploadingFaceSample = true);

    try {
      final XFile captured = await controller!.takePicture();

      // Re-validate the actual captured frame so movement during countdown
      // cannot pass through and be uploaded as a valid training sample.
      final capturedFaces = await FaceDetectionUtil.detectFacesInImage(
        captured,
      );
      if (capturedFaces.isEmpty) {
        throw Exception(AppStrings.tr('no_face_detected'));
      }
      final capturedImageSize = await FaceDetectionUtil.getImageSize(captured);

      final capturedValidationError =
          await FaceDetectionUtil.validateFaceQuality(
            capturedFaces.first,
            capturedImageSize,
          );
      if (capturedValidationError != null) {
        throw Exception(AppStrings.tr(capturedValidationError));
      }

      final List<double>? embedding = await _faceAttendanceVerifier
          .extractEmbeddingFromPath(captured.path);
      if (embedding == null) {
        throw Exception(
          'Face alignment failed. Keep your head straight and retry.',
        );
      }

      final String imageUrl = await _cloudinaryProfileImageService
          .uploadFaceSampleImage(
            imageFile: File(captured.path),
            userId: userId,
            sampleIndex: currentPhotoCount + 1,
          );

      // Only save the face sample and embedding, no matching or approval.
      _capturedFaceImageUrls
        ..clear()
        ..add(imageUrl);
      _capturedEmbeddings
        ..clear()
        ..add(embedding);

      if (!mounted) return;

      setState(() {
        if (currentPhotoCount < totalRequired) currentPhotoCount++;
      });

      // Immediately save registration after capture (no approval/match step)
      if (currentPhotoCount == totalRequired) {
        await onComplete();
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      final code = e.code.toLowerCase();
      final message = code == 'permission-denied'
          ? 'Firestore permission denied. Please update Firebase rules.'
          : (e.message ?? e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.tr('face_sample_upload_failed')}: $message',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.tr('face_sample_upload_failed')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isUploadingFaceSample = false);
      }
    }
  }

  Future<void> onComplete() async {
    final String userId = _resolveUserId();
    if (userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr('unable_to_resolve_user_id'))),
      );
      return;
    }

    if (_capturedFaceImageUrls.isEmpty) {
      return;
    }

    try {
      final Map<String, dynamic> updateData = {
        'biometrics': _buildBiometricsPayload('approved'),
      };

      await _realtimeDataController.updateUserRecord(userId, updateData);
      if (!mounted) return;
      await onFaceRegistrationCompleted();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.tr('face_sample_upload_failed')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _resolveUserId() {
    return (widget.loginData?['uid'] ?? '').toString().trim();
  }

  Future<void> returnToHomepage() async {
    if (!mounted) return;
    final Map<String, dynamic> homeArgs = Map<String, dynamic>.from(
      widget.loginData ?? <String, dynamic>{},
    )..['initialIndex'] = 0;

    await Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoute.appmain,
      (route) => false,
      arguments: homeArgs,
    );
  }

  Future<void> onFaceRegistrationCompleted() async {
    await returnToHomepage();
  }

  Future<void> applyRegisteredFaceAsProfileImage(String imageUrl) async {
    final String userId = _resolveUserId();
    if (userId.isEmpty || imageUrl.trim().isEmpty) {
      return;
    }

    await _realtimeDataController.updateUserRecord(userId, {
      'profile_url': imageUrl,
      'profile_image_url': imageUrl,
    });
  }

  Map<String, dynamic> _buildBiometricsPayload(String status) {
    final hasFace = _capturedFaceImageUrls.isNotEmpty;
    return {
      'face_status': status,
      'face_count': hasFace ? 1 : 0,
      'face_image_urls': hasFace
          ? <String>[_capturedFaceImageUrls.first]
          : <String>[],
      'registered_date': DateTime.now().toIso8601String(),
    };
  }
}
