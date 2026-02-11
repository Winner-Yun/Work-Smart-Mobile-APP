import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:permission_handler/permission_handler.dart';

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isRearCameraSelected = false;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;

    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      final frontCamera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      _onNewCameraSelected(frontCamera);
    }
  }

  void _onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_controller != null) await _controller!.dispose();

    final cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _controller = cameraController;
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await cameraController.setFlashMode(FlashMode.off);

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _flashMode = FlashMode.off;
          _isRearCameraSelected =
              cameraDescription.lensDirection == CameraLensDirection.back;
        });
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.isEmpty) return;
    setState(() => _isCameraInitialized = false);

    CameraLensDirection newDirection = _isRearCameraSelected
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    CameraDescription newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == newDirection,
      orElse: () => _cameras!.first,
    );

    _onNewCameraSelected(newCamera);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_isRearCameraSelected) return;

    try {
      final newMode = _flashMode == FlashMode.off
          ? FlashMode.torch
          : FlashMode.off;
      await _controller!.setFlashMode(newMode);
      setState(() => _flashMode = newMode);
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _controller!.value.isTakingPicture) {
      return;
    }
    try {
      final XFile file = await _controller!.takePicture();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(painter: FaceOverlayPainter()),
          ),
          _buildForegroundUI(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildGlassButton(
          icon: Icons.close,
          onTap: () => Navigator.pop(context),
        ),
      ),
      centerTitle: true,
      title: _buildLiveStatus(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: _buildGlassButton(
            icon: (_flashMode == FlashMode.off || !_isRearCameraSelected)
                ? Icons.flash_off
                : Icons.flash_on,
            color: (_flashMode == FlashMode.torch && _isRearCameraSelected)
                ? Colors.yellow
                : Colors.white,
            onTap: _isRearCameraSelected ? _toggleFlash : () {},
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return (_isCameraInitialized && _controller != null)
        ? Center(child: CameraPreview(_controller!))
        : const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildForegroundUI() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                AppStrings.tr('face_scan_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              AppStrings.tr('face_scan_step'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          const Spacer(),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildLiveStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 4, backgroundColor: Color(0xFFFF8A8A)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              AppStrings.tr('live_status'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Invisible Expanded spacer to balance the left side
              const Expanded(child: SizedBox()),

              // 2. The Shutter button stays exactly in the center
              _buildShutterButton(),

              // 3. Expanded spacer for the right side, containing the aligned switch button
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildActionColumn(
                    icon: Icons.flip_camera_ios,
                    label: AppStrings.tr('switch_camera'),
                    onTap: _switchCamera,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoBanner(),
        ],
      ),
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: _takePicture,
      child: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 4,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: Colors.white24,
        shape: const CircleBorder(),
      ),
      icon: Icon(icon, color: color, size: 20),
      onPressed: onTap,
    );
  }

  Widget _buildActionColumn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onTap,
          icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        SizedBox(
          width: 80,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                AppStrings.tr('ensure_light'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FaceOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    final cutout = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.4),
        width: size.width * 0.7,
        height: size.height * 0.4,
      ),
      const Radius.circular(150),
    );
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(cutout)
        ..fillType = PathFillType.evenOdd,
      paint,
    );
    canvas.drawRRect(
      cutout,
      Paint()
        ..color = Colors.white30
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
