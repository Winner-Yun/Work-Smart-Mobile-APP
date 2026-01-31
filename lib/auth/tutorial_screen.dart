import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/auth/tutorial_content.dart';
import 'package:flutter_worksmart_mobile_app/config/appcolor.dart'; // Added AppColors
import 'package:flutter_worksmart_mobile_app/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/translations/app_strings.dart'; // Added AppStrings

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // DEV NOTE: Converted Strings to AppStrings keys for dynamic translation
  final List<Map<String, dynamic>> _tutorialData = [
    {
      'image': AppImg.firstScreen,
      'title': "tutorial_title_1", // Key
      'subtitle': "tutorial_subtitle_1", // Key
      'isFirst': true,
    },
    {
      'image': AppImg.secondScreen,
      'title': "tutorial_title_2", // Key
      'subtitle': "tutorial_subtitle_2", // Key
      'isFirst': false,
    },
    {
      'image': AppImg.thirdScreen,
      'title': "tutorial_title_3", // Key
      'subtitle': "tutorial_subtitle_3", // Key
      'isFirst': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScrollTimer();
  }

  void _startAutoScrollTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoute.authScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoute.authScreen);
                },
                child: Text(
                  AppStrings.tr('skip'), // "រំលង"
                  style: const TextStyle(color: AppColors.textGrey),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _tutorialData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _timer?.cancel();
                  _startAutoScrollTimer();
                },
                itemBuilder: (context, index) {
                  final data = _tutorialData[index];
                  // DEV NOTE: We now translate keys here before passing to Widget
                  return TutorialContent(
                    imagePath: data['image'],
                    title: AppStrings.tr(data['title']),
                    subtitle: AppStrings.tr(data['subtitle']),
                    isFirstScreen: data['isFirst'],
                  ).animate().fadeIn(delay: (200 + (index * 10)).ms);
                },
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == _currentPage ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index == _currentPage
                            ? AppColors.primary
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _onNextPressed,
                      child: Text(
                        _currentPage == 2
                            ? AppStrings.tr('start') // "ចាប់ផ្តើម"
                            : AppStrings.tr('next'), // "បន្ទាប់"
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
