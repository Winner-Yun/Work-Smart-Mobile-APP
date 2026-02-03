import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LeaveAttendanceScreen(),
    ),
  );
}

class LeaveAttendanceScreen extends StatelessWidget {
  const LeaveAttendanceScreen({super.key});

  // --- Mockup Data ---
  static const List<Map<String, dynamic>> _leaveRequests = [
    {
      'title': 'ឈប់សម្រាកប្រចាំឆ្នាំ',
      'subtitle': '២០ - ២២ តុលា ២០២៣',
      'status': 'អនុម័ត',
      'statusColor': Colors.green,
      'icon': Icons.beach_access_outlined,
    },
    {
      'title': 'ច្បាប់ឈឺ (គ្រុនផ្តាសាយ)',
      'subtitle': '០៥ វិច្ឆិកា ២០២៣',
      'status': 'រង់ចាំ',
      'statusColor': Colors.orange,
      'icon': Icons.medical_services_outlined,
    },
    {
      'title': 'ឈប់សម្រាកផ្ទាល់ខ្លួន',
      'subtitle': '១៥ តុលា ២០២៣',
      'status': 'បដិសេធ',
      'statusColor': Colors.red,
      'icon': Icons.calendar_today_outlined,
    },
    {
      'title': 'ឈប់សម្រាកពិសេស',
      'subtitle': '១០ ធ្នូ ២០២៣',
      'status': 'អនុម័ត',
      'statusColor': Colors.green,
      'icon': Icons.star_outline,
    },
    {
      'title': 'ឈប់សម្រាកប្រចាំឆ្នាំ',
      'subtitle': '០១ - ០៣ មករា ២០២៤',
      'status': 'អនុម័ត',
      'statusColor': Colors.green,
      'icon': Icons.beach_access_outlined,
    },
    {
      'title': 'ច្បាប់ឈឺ',
      'subtitle': '១២ កុម្ភៈ ២០២៤',
      'status': 'រង់ចាំ',
      'statusColor': Colors.orange,
      'icon': Icons.medical_services_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      bottomNavigationBar: _buildBottomAction(context).animate().slideY(
        begin: 1,
        end: 0,
        duration: 400.ms,
        curve: Curves.easeOutQuad,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIXED TOP SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummarySection(context)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: 30),
                _buildListHeader(),
              ],
            ),
          ),

          // SCROLLABLE LIST SECTION
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _leaveRequests.length,
              physics:
                  const BouncingScrollPhysics(), // Added for smooth scrolling
              itemBuilder: (context, index) {
                final data = _leaveRequests[index];
                return _buildRequestListItem(
                      context: context,
                      title: data['title'],
                      subtitle: data['subtitle'],
                      status: data['status'],
                      statusColor: data['statusColor'],
                      icon: data['icon'],
                    )
                    .animate()
                    .fadeIn(delay: (100 * index).ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. AppBar Widget ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      title: const Text(
        'ច្បាប់ឈប់សម្រាក',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoute.notificationScreen),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
              ],
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_none,
                  color: Theme.of(context).iconTheme.color,
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
          ).animate().shake(delay: 1.seconds, duration: 500.ms),
        ),
      ],
    );
  }

  // --- 2. Leave Summary Section ---
  Widget _buildSummarySection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context: context,
            title: 'ច្បាប់ប្រចាំឆ្នាំ',
            value: '១២',
            icon: Icons.calendar_today_outlined,
            iconColor: Colors.teal,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildSummaryCard(
            context: context,
            title: 'ច្បាប់ឈឺ',
            value: '០៥',
            icon: Icons.medical_services_outlined,
            iconColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  // --- 3. Request List Header ---
  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'សំណើថ្មីៗ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('មើលទាំងអស់', style: TextStyle(color: Colors.teal)),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  // --- 4. Fixed Bottom Action ---
  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoute.sickleaveScreen);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 55),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "ស្នើច្បាប់ឈឺ",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoute.annualleaveScreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(0, 55),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "ស្នើច្បាប់ប្រចាំឆ្នាំ",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Private Helper Components ---

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'ថ្ងៃនៅសល់',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestListItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
            child: Icon(icon, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
