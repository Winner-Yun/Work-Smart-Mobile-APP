import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/auth/tutorial_content.dart';
import 'package:flutter_worksmart_mobile_app/constants/app_img.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _tutorialData = [
    {
      'image': AppImg.firstScreen,
      'title': "គ្រប់គ្រងវត្តមានដោយឆ្លាតវៃ",
      'subtitle': "តាមដានវត្តមានបុគ្គលិកដោយសុវត្ថិភាព និងប្រសិទ្ធភាព",
      'isFirst': true,
    },
    {
      'image': AppImg.secondScreen,
      'title': "បច្ចេកវិទ្យាការពារការបន្លំ",
      'subtitle':
          "ផ្ទៀងផ្ទាត់ទីតាំង GPS និងថតរូបផ្ទាល់ ដើម្បីធានាភាពត្រឹមត្រូវ",
      'isFirst': false,
    },
    {
      'image': AppImg.thirdScreen,
      'title': "បង្កើនប្រសិទ្ធភាពការងារ",
      'subtitle': "ទទួលបានសមិទ្ធផល និងចំណាត់ថ្នាក់ល្អក្នុងក្រុមហ៊ុន",
      'isFirst': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScrollTimer();
  }

  void _startAutoScrollTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
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
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {},
                child: const Text("រំលង", style: TextStyle(color: Colors.grey)),
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
                  return TutorialContent(
                    imagePath: data['image'],
                    title: data['title'],
                    subtitle: data['subtitle'],
                    isFirstScreen: data['isFirst'],
                  );
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
                            ? primaryColor
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
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _onNextPressed,
                      child: Text(
                        _currentPage == 2 ? "ចាប់ផ្តើម" : "បន្ទាប់",
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
