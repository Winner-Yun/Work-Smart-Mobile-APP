import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/core/util/cloudinary/cloudinary_profile_image_service.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/realtime_data_controller.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/homepage_screens/assign_user_face_screen.dart';
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
  final int totalRequired = 3;
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    laserController.dispose();
    timer?.cancel();
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

      final String imageUrl = await _cloudinaryProfileImageService
          .uploadFaceSampleImage(
            imageFile: File(captured.path),
            userId: userId,
            sampleIndex: currentPhotoCount + 1,
          );

      _capturedFaceImageUrls.add(imageUrl);

      await _realtimeDataController.updateUserRecord(userId, {
        'biometrics': {
          'face_status': 'pending',
          'face_count': _capturedFaceImageUrls.length,
          'face_image_urls': _capturedFaceImageUrls,
          'registered_date': DateTime.now().toIso8601String(),
        },
      });

      if (!mounted) return;

      setState(() {
        if (currentPhotoCount < totalRequired) currentPhotoCount++;
      });

      if (currentPhotoCount == totalRequired) {
        await onComplete();
      }
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

    if (mounted) {
      setState(() => isApprovingFace = true);
    }

    try {
      await _realtimeDataController.updateUserRecord(userId, {
        'biometrics': {
          'face_status': 'pending',
          'face_count': _capturedFaceImageUrls.length,
          'face_image_urls': _capturedFaceImageUrls,
          'registered_date': DateTime.now().toIso8601String(),
        },
      });

      await Future.delayed(const Duration(seconds: 5));

      await _realtimeDataController.updateUserRecord(userId, {
        'biometrics': {
          'face_status': 'approved',
          'face_count': _capturedFaceImageUrls.length,
          'face_image_urls': _capturedFaceImageUrls,
          'registered_date': DateTime.now().toIso8601String(),
        },
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.tr('face_registered_success'),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
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
        setState(() => isApprovingFace = false);
      }
    }
  }

  String _resolveUserId() {
    return (widget.loginData?['uid'] ?? '').toString().trim();
  }
}
