import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/features/user/logic/face_scan_logic.dart';

class FaceScanScreen extends StatefulWidget {
  final Map<String, dynamic>? loginData;

  const FaceScanScreen({super.key, this.loginData});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends FaceScanLogic {
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
          if (isFlashOverlayEnabled)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: Colors.white.withOpacity(0.92)),
              ),
            ),
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(painter: FaceOverlayPainter()),
          ),
          if (isScanning) _buildScanningAnimation(),
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
            icon: (flashMode == FlashMode.off || !isRearCameraSelected)
                ? Icons.flash_off
                : Icons.flash_on,
            color: (flashMode == FlashMode.torch && isRearCameraSelected)
                ? Colors.yellow
                : Colors.white,
            onTap: (isRearCameraSelected && !isScanning) ? toggleFlash : () {},
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return (isCameraInitialized && controller != null)
        ? Center(child: CameraPreview(controller!))
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
              isScanning
                  ? (scanMessage.isEmpty
                        ? AppStrings.tr('processing')
                        : scanMessage)
                  : AppStrings.tr('face_scan_step'),
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
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isScanning
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isScanning
                          ? AppStrings.tr('processing')
                          : AppStrings.tr('live_status'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildScanButton(),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildActionColumn(
                    icon: Icons.flip_camera_ios,
                    label: AppStrings.tr('switch_camera'),
                    onTap: isScanning ? () {} : switchCamera,
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

  Widget _buildScanButton() {
    return IconButton.filled(
      onPressed: isScanning ? null : takePicture,
      icon: const Icon(Icons.face_retouching_natural, size: 28),
      style: IconButton.styleFrom(
        minimumSize: const Size(66, 66),
        shape: const CircleBorder(),
      ),
    );
  }

  Widget _buildScanningAnimation() {
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final overlayTop = 70.0;
            final overlayHeight = constraints.maxHeight - overlayTop;
            final faceCenterY = overlayTop + (overlayHeight * 0.4);
            final faceHeight = overlayHeight * 0.4;
            final scanStartY = faceCenterY - (faceHeight * 0.45);
            final scanEndY = faceCenterY + (faceHeight * 0.45);
            final t = scanProgress.clamp(0.0, 1.0);
            final pingPongProgress = 0.5 - (0.5 * math.cos(2 * math.pi * t));
            final scanY =
                scanStartY + ((scanEndY - scanStartY) * pingPongProgress);

            return Stack(
              children: [
                Positioned(
                  top: scanY - 12,
                  left: constraints.maxWidth * 0.18,
                  right: constraints.maxWidth * 0.18,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0),
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.45),
                          Theme.of(context).colorScheme.primary.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: scanY,
                  left: constraints.maxWidth * 0.18,
                  right: constraints.maxWidth * 0.18,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.7),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    canvas.drawRRect(
      cutout,
      Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
