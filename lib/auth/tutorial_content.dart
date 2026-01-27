import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/config/appcolor.dart'; // Added AppColors

class TutorialContent extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final bool isFirstScreen;

  const TutorialContent({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.isFirstScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    // DEV NOTE: Switched to AppColors.primary for consistency
    return Column(
      children: [
        const Spacer(flex: 1),
        Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              height: MediaQuery.sizeOf(context).height * 0.4,
              alignment: Alignment.center,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) => Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: Colors.grey[300],
                ),
              ),
            ),
          ],
        ),
        const Spacer(flex: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey, // Switched to AppColors
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
