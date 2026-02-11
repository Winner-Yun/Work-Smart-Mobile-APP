import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/homepage_screens/face_scan_screen.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class FaceScanLogic extends State<FaceScanScreen>
    with WidgetsBindingObserver {
  // --- State Variables ---
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isCameraInitialized = false;
  bool isRearCameraSelected = false;
  FlashMode flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    // Register this class to observe app lifecycle events
    WidgetsBinding.instance.addObserver(this);
    // Start the camera initialization process immediately
    initCamera();
  }

  @override
  void dispose() {
    // Clean up observer and camera controller to prevent memory leaks
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

  // Captures the image using the camera controller and shows a success SnackBar
  Future<void> takePicture() async {
    if (controller == null ||
        !controller!.value.isInitialized ||
        controller!.value.isTakingPicture) {
      return;
    }
    try {
      final XFile file = await controller!.takePicture();
      debugPrint(file.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: Text(
              AppStrings.tr('scan_success'),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("$e");
    }
  }
}
