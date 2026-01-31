import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/config/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/translations/app_strings.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  // ===========================================================================
  // MOCK DATA SECTION
  // ===========================================================================
  // DEV NOTE: In a real app, replace these static lists with Models fetched
  // from an API or Database (e.g., List<EmployeeModel>).
  static const List<Map<String, dynamic>> employeeData = [
    {
      "name": "Dara",
      "role": "role_trainer", // Key matches AppStrings for localization
      "score": "98%",
      "imgUrl": "https://i.pravatar.cc/150?img=5",
      "isTop":
          true, // Logic Flag: Used to render the "Crown" icon and Gold border
    },
    {
      "name": "Vanda",
      "role": "role_ios",
      "score": "97%",
      "imgUrl": "https://i.pravatar.cc/150?img=9",
      "isTop": false,
    },
    {
      "name": "Vibol",
      "role": "role_designer",
      "score": "95%",
      "imgUrl": "https://i.pravatar.cc/150?img=3",
      "isTop": false,
    },
  ];

  static const List<Map<String, dynamic>> leaveData = [
    {
      "icon": Icons.beach_access,
      "label": "annual_leave",
      "amount": "12",
      "color": Colors.blue, // Specific color for this leave type
    },
    {
      "icon": Icons.sick_outlined,
      "label": "sick_leave",
      "amount": "5",
      "color": Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,

        // =====================================================================
        // SCROLL VIEW ARCHITECTURE
        // =====================================================================
        // DEV NOTE: We use CustomScrollView instead of SingleChildScrollView
        // to support the 'SliverAppBar' which provides the sticky header effect.
        body: CustomScrollView(
          slivers: [
            // --- 1. Sticky Header ---
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: true,
              floating: false,
              automaticallyImplyLeading: false,
              scrolledUnderElevation:
                  0, // Removes shadow when scrolled under (Material 3)
              elevation: 0,
              toolbarHeight: 80,
              titleSpacing: 20,
              title: Row(
                children: [
                  // Profile Avatar with Status Dot
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=11',
                        ),
                      ),
                      // Online Status Indicator (Bottom Right)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            border: Border.all(color: Colors.white, width: 2),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tr('greeting'),
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const Text(
                          "វិនន័រ",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                // Notification Bell with Red Dot
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Icon(
                            Icons.notifications_none,
                            color: AppColors.textDark,
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- 2. Main Body Content ---
            // DEV NOTE: SliverToBoxAdapter is required here to put normal widgets
            // (like Column, Row, Container) inside a CustomScrollView.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // --- Date & Status Row ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "ថ្ងៃចន្ទ, ២៤ តុលា ២០២៣",
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "សុវត្ថិភាព",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- Time Attendance Cards ---
                    Row(
                      children: [
                        _buildTimeCard(
                          AppStrings.tr('check_in'),
                          "08:00\nAM",
                          Icons.login,
                          false, // Light Theme
                        ),
                        const SizedBox(width: 10),
                        _buildTimeCard(
                          AppStrings.tr('check_out'),
                          "--:--",
                          Icons.logout,
                          false, // Light Theme
                        ),
                        const SizedBox(width: 10),
                        _buildTimeCard(
                          AppStrings.tr('work_hours'),
                          "4h 30m",
                          Icons.access_time,
                          true, // Dark Theme (Highlighted)
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- Map & Scan Action Card ---
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Top Section: Map Background
                          Container(
                            height: 140,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Placeholder Map (Replace with GoogleMap widget later)
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.map,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                // Gradient Overlay: Ensures text visibility over map image
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.6),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 15,
                                  left: 15,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.tr('current_loc'),
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: AppColors.secondary,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            AppStrings.tr('office_name'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Bottom Section: Action Button
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppStrings.tr('leave_question'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        AppStrings.tr('in_range'),
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.qr_code_scanner,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppStrings.tr('scan_out'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const CircleAvatar(
                                          radius: 4,
                                          backgroundColor: AppColors.secondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- Leave Stats (Dynamic Generation) ---
                    // Using map() to generate widgets ensures we don't repeat code.
                    Row(
                      children: leaveData.map((data) {
                        bool isLast = data == leaveData.last;
                        return Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildLeaveCard(
                                  data['icon'] as IconData,
                                  AppStrings.tr(data['label']),
                                  "${data['amount']} ${AppStrings.tr('days')}",
                                  data['color'] as Color,
                                ),
                              ),
                              if (!isLast) const SizedBox(width: 15),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // --- Outstanding Staff Section ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.tr('employee_title'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            AppStrings.tr('view_all'),
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),

                    // --- Employee List ---
                    Column(
                      children: employeeData.map((employee) {
                        return _buildEmployeeRow(
                          employee['name'],
                          AppStrings.tr(employee['role']),
                          employee['score'],
                          employee['imgUrl'],
                          employee['isTop'], // Passing the winner flag
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPER WIDGETS
  // ===========================================================================

  // Builds a single employee row.
  // Handles logic for the "Top Employee" (Crown icon + Gold Border).
  Widget _buildEmployeeRow(
    String name,
    String role,
    String score,
    String imgUrl,
    bool isTop,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Logic: Apply secondary color border only if isTop is true
        border: isTop
            ? Border.all(color: AppColors.secondary, width: 0.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Stack allows positioning the crown over the avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(isTop ? 2 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isTop
                      ? Border.all(color: AppColors.secondary, width: 2)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(imgUrl),
                ),
              ),
              // Only show Crown Icon if user is Top
              if (isTop)
                Positioned(
                  top: -8,
                  right: -6,
                  child: Image.asset(AppImg.crown, width: 24, height: 24),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Text(
            score,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Builds Time Cards (In/Out/Hours).
  // Uses 'isDark' flag to toggle between Primary color BG and White BG.
  Widget _buildTimeCard(String label, String time, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 110,
        decoration: BoxDecoration(
          // Conditional Styling based on isDark
          color: isDark ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isDark ? Colors.white70 : AppColors.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Text(
              time,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds standard cards for Leave Types.
  Widget _buildLeaveCard(
    IconData icon,
    String label,
    String days,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            days,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
