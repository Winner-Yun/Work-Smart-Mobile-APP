import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/features/user/logic/assign_user_face_logic.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/user/modern_face_painter.dart';

class RegisterFaceScanScreen extends StatefulWidget {
  final Map<String, dynamic>? loginData;

  const RegisterFaceScanScreen({super.key, this.loginData});

  @override
  State<RegisterFaceScanScreen> createState() => _RegisterFaceScanScreenState();
}

class _RegisterFaceScanScreenState extends RegisterFaceLogic {
  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.tertiary;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: isChangingLanguage
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                AppStrings.tr('face_training_title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: isChangingLanguage ? null : toggleLanguage,
            child: Text(
              LanguageManager().locale.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (isCameraInitialized) CameraPreview(controller!),
          AnimatedBuilder(
            animation: laserController,
            builder: (context, child) {
              return CustomPaint(
                painter: ModernFacePainter(
                  color: primaryColor,
                  laserPos: laserController.value,
                ),
              );
            },
          ),
          if (countdown > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Text(
                  "$countdown",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildInstructionCard(primaryColor),
                const SizedBox(height: 20),
                _buildActionButtons(primaryColor),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(Color primary) {
    int displayStep = (currentPhotoCount + 1).clamp(1, totalRequired);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            "${AppStrings.tr('take_photo_step')} $displayStep / $totalRequired",
            style: TextStyle(
              color: primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.tr('face_scan_title'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Color primary) {
    bool isProcessing = countdown > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: isBackCamera ? toggleFlash : null,
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: isBackCamera ? Colors.white : Colors.white24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black45,
              padding: const EdgeInsets.all(12),
            ),
          ),
          GestureDetector(
            onTap: isProcessing ? null : startCaptureProcess,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 85,
                  height: 85,
                  child: CircularProgressIndicator(
                    value: currentPhotoCount / totalRequired,
                    strokeWidth: 5,
                    color: isProcessing ? Colors.orange : primary,
                    backgroundColor: Colors.white12,
                  ),
                ),
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: isProcessing ? Colors.grey : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isProcessing ? Icons.timer : Icons.camera_alt,
                    color: isProcessing ? Colors.white : primary,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isProcessing ? null : toggleCamera,
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black45,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
