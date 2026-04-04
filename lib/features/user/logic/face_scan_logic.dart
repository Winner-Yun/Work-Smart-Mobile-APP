import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/realtime_data_controller.dart';
import 'package:flutter_worksmart_mobile_app/core/util/face/face_attendance_verifier.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/homepage_screens/face_scan_screen.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class FaceScanLogic extends State<FaceScanScreen>
    with WidgetsBindingObserver {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isCameraInitialized = false;
  bool isRearCameraSelected = false;
  FlashMode flashMode = FlashMode.off;
  bool isScanning = false;
  double scanProgress = 0;
  Timer? _scanTimer;
  bool isFlashOverlayEnabled = false;
  String scanMessage = '';
  final RealtimeDataController _realtimeDataController =
      RealtimeDataController();
  late final FaceAttendanceVerifier _faceAttendanceVerifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _faceAttendanceVerifier = FaceAttendanceVerifier();
    initCamera();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _faceAttendanceVerifier.close();
    controller?.dispose();
    super.dispose();
  }

  Future<void> initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;

    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      final frontCamera = cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras!.first,
      );
      onNewCameraSelected(frontCamera);
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) await controller!.dispose();

    final cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    controller = cameraController;
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await cameraController.setFlashMode(FlashMode.off);

      if (mounted) {
        setState(() {
          isCameraInitialized = true;
          flashMode = FlashMode.off;
          isRearCameraSelected =
              cameraDescription.lensDirection == CameraLensDirection.back;
        });
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> switchCamera() async {
    if (cameras == null || cameras!.isEmpty) return;
    setState(() => isCameraInitialized = false);

    CameraLensDirection newDirection = isRearCameraSelected
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    CameraDescription newCamera = cameras!.firstWhere(
      (camera) => camera.lensDirection == newDirection,
      orElse: () => cameras!.first,
    );

    onNewCameraSelected(newCamera);
  }

  Future<void> toggleFlash() async {
    if (controller == null || !isRearCameraSelected) return;

    try {
      final newMode = flashMode == FlashMode.off
          ? FlashMode.torch
          : FlashMode.off;
      await controller!.setFlashMode(newMode);
      setState(() => flashMode = newMode);
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> takePicture() async {
    if (isScanning || controller == null || !controller!.value.isInitialized) {
      return;
    }

    setState(() {
      isScanning = true;
      scanProgress = 0;
      scanMessage = 'Initializing secure scan...';
    });

    final String userId = (widget.loginData?['uid'] ?? '').toString().trim();
    if (userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr('unable_to_resolve_user_id'))),
      );
      setState(() {
        isScanning = false;
        scanProgress = 0;
      });
      return;
    }

    late final AttendanceVerificationResult verification;
    try {
      verification = await _faceAttendanceVerifier
          .verifyAttendance(
            cameraController: controller!,
            userId: userId,
            onFlashOverlay: (enabled) async {
              if (!mounted) return;
              setState(() => isFlashOverlayEnabled = enabled);
            },
            onProgress: (progress) {
              if (!mounted) return;
              setState(() {
                scanProgress = progress.progress;
                scanMessage = progress.message;
              });
            },
          )
          .timeout(const Duration(seconds: 50));
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        isScanning = false;
        scanProgress = 0;
        isFlashOverlayEnabled = false;
        scanMessage = 'Face verification timed out. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Face verification timed out. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isScanning = false;
        scanProgress = 0;
        isFlashOverlayEnabled = false;
        scanMessage = 'Face verification failed. Please retry.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Face verification failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!verification.success) {
      if (mounted) {
        setState(() {
          isScanning = false;
          scanProgress = 0;
          isFlashOverlayEnabled = false;
          scanMessage = verification.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verification.message),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final Map<String, dynamic>? savedRecord = await _saveAttendanceRecord(
      verification: verification.toMap(),
    );
    if (savedRecord == null) {
      if (mounted) {
        setState(() {
          isScanning = false;
          scanProgress = 0;
          isFlashOverlayEnabled = false;
        });
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      isScanning = false;
      scanProgress = 1;
      isFlashOverlayEnabled = false;
      scanMessage = 'Verification passed';
    });

    await controller?.pausePreview();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: theme.colorScheme.primary,
              size: 48,
            ),
          ),
          title: Text(
            AppStrings.tr('scan_success'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '${AppStrings.tr('face_scan_success_desc')}\nSimilarity: ${verification.similarity.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.tr('understood'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    await controller?.resumePreview();
  }

  Future<Map<String, dynamic>?> _saveAttendanceRecord({
    Map<String, dynamic>? verification,
  }) async {
    final String userId = (widget.loginData?['uid'] ?? '').toString().trim();
    if (userId.isEmpty) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr('unable_to_resolve_user_id'))),
      );
      return null;
    }

    final String rawScanType = (widget.loginData?['scanType'] ?? 'check_in')
        .toString()
        .trim();
    final String scanType = rawScanType.toLowerCase() == 'check_out'
        ? 'check_out'
        : 'check_in';

    Map<String, dynamic>? latLng;
    final dynamic rawLatLng = widget.loginData?['lat_lng'];
    if (rawLatLng is Map) {
      latLng = Map<String, dynamic>.from(rawLatLng);
    }

    try {
      final savedRecord = await _realtimeDataController.saveAttendanceScan(
        uid: userId,
        scanType: scanType,
        scannedAt: DateTime.now(),
        latLng: latLng,
        verification: verification,
      );
      return savedRecord;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.tr('attendance_scan_save_failed')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }
}
