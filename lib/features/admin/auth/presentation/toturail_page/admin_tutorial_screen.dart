import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/database_helper.dart';

import '../../../../../shared/widget/admin/admin_feature_visual.dart';
import '../../../../../shared/widget/user/tutorial_data.dart';

class AdminTutorialScreen extends StatefulWidget {
  const AdminTutorialScreen({super.key});

  @override
  State<AdminTutorialScreen> createState() => _AdminTutorialScreenState();
}

class _AdminTutorialScreenState extends State<AdminTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < TutorialData.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  Future<void> _completeTutorial() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.saveConfig('admin_tutorial_seen', 'true');
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppAdminRoute.authAdminScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutorialData = TutorialData.pages;
    final activeColor = tutorialData[_currentPage]['color'] as Color;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Color Transition (Low cost)
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            color: activeColor.withOpacity(0.03),
          ),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 600),
              child: Card(
                elevation: 0, // Removed high elevation for performance
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                color: Colors.white,
                margin: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Top Bar (Logo + Skip)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.business_center_rounded,
                            color: activeColor, // Simple color update
                            size: 28,
                          ),
                          TextButton(
                            onPressed: _completeTutorial,
                            child: Text(
                              AppStrings.tr('skip'),
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Content Slider
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        itemCount: tutorialData.length,
                        itemBuilder: (context, index) {
                          final data = tutorialData[index];
                          return Row(
                            children: [
                              // Left: Text
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.tr(data['title']),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        AppStrings.tr(data['subtitle']),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF6B7280),
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Right: Visual
                              Expanded(
                                flex: 6,
                                child: Container(
                                  margin: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: (data['color'] as Color).withOpacity(
                                      0.05,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: AdminFeatureVisual(data: data),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Bottom Bar
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(
                              tutorialData.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 8),
                                height: 6,
                                width: _currentPage == index ? 24 : 6,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? activeColor
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          // Button
                          ElevatedButton(
                            onPressed: _onNextPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF111827),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentPage == tutorialData.length - 1
                                      ? AppStrings.tr('start')
                                      : AppStrings.tr('next'),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
