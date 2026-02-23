import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/homepage_screens/face_scan_screen.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class FaceScanLogic extends State<FaceScanScreen>
    with WidgetsBindingObserver {
  // --- State Variables ---
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isCameraInitialized = false;
  bool isRearCameraSelected = false;
  FlashMode flashMode = FlashMode.off;
  bool isScanning = false;
  double scanProgress = 0;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    initCamera();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  // Requests camera permissions and finds available cameras (prefers front camera)
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

  // Initializes the specific camera controller and listener for UI updates
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

  // Swaps between Front and Back cameras
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

  // Toggles the Flash (Torch mode) on/off, only works if Rear camera is selected
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

  // Mock scanning flow for 5 seconds, then show success dialog and return result
  Future<void> takePicture() async {
    if (isScanning || controller == null || !controller!.value.isInitialized) {
      return;
    }

    const int totalDurationMs = 5000;
    const int tickMs = 16;
    int elapsedMs = 0;

    setState(() {
      isScanning = true;
      scanProgress = 0;
    });

    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(milliseconds: tickMs), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      elapsedMs += tickMs;
      final double progress = (elapsedMs / totalDurationMs).clamp(0.0, 1.0);
      setState(() {
        scanProgress = progress;
      });

      if (elapsedMs >= totalDurationMs) {
        timer.cancel();
        setState(() {
          isScanning = false;
          scanProgress = 1;
        });

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
                AppStrings.tr('face_scan_success_desc'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    // More visual weight than TextButton
                    onPressed: () => Navigator.pop(dialogContext),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppStrings.tr('understood'),
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                ),
              ],
            );
          },
        );

        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    });
  }
}
