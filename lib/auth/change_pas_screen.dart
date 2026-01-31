import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/config/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/translations/app_strings.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleReset() {
    if (_formKey.currentState!.validate()) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 80,
            ).animate().scale(duration: 400.ms),
            const SizedBox(height: 20),
            Text(
              AppStrings.tr('success_title'),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.tr('success_message'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text(
                  AppStrings.tr('back_to_login'),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(children: [_buildHeader(), _buildFormContainer()]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImg.authBackground),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 15,
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Positioned(
          bottom: 70,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.tr('reset_password_title'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
              Text(
                AppStrings.tr('reset_password_subtitle'),
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormContainer() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildThemedPasswordField(
                _passController,
                AppStrings.tr('new_password_label'),
                AppStrings.tr('new_password_hint'),
                _obscurePass,
                () => setState(() => _obscurePass = !_obscurePass),
              ),
              const SizedBox(height: 25),
              _buildThemedPasswordField(
                _confirmPassController,
                AppStrings.tr('confirm_password_label'),
                AppStrings.tr('confirm_password_hint'),
                _obscureConfirm,
                () => setState(() => _obscureConfirm = !_obscureConfirm),
                isConfirm: true,
              ),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildThemedPasswordField(
    TextEditingController ctrl,
    String label,
    String hint,
    bool obscure,
    VoidCallback toggle, {
    bool isConfirm = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: AppColors.primary,
              selectionHandleColor: AppColors.primary,
              selectionColor: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: TextFormField(
            controller: ctrl,
            obscureText: obscure,
            style: const TextStyle(fontSize: 16),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return AppStrings.tr('password_empty_error');
              }
              if (val.length < 6) return AppStrings.tr('password_length_error');
              if (isConfirm && val != _passController.text) {
                return AppStrings.tr('password_mismatch_error');
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: const Icon(
                Icons.lock_reset_rounded,
                color: AppColors.primary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: toggle,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey[100]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: _handleReset,
        child: Text(
          AppStrings.tr('change_password_button'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
