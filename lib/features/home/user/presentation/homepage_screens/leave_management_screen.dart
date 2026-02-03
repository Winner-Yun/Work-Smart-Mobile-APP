import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';

class LeaveDetailScreen extends StatefulWidget {
  const LeaveDetailScreen({super.key});

  @override
  State<LeaveDetailScreen> createState() => _LeaveDetailScreenState();
}

class _LeaveDetailScreenState extends State<LeaveDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _annualController;
  late AnimationController _sickController;
  late Animation<double> _annualAnimation;
  late Animation<double> _sickAnimation;

  final List<Map<String, dynamic>> _history = [
    {
      "title": "ឈប់ច្បាប់ប្រចាំឆ្នាំ",
      "date": "១៥ តុលា ២០២៣",
      "status": "បានអនុម័ត",
      "color": Colors.green,
    },
    {
      "title": "ឈប់ច្បាប់ឈឺ (គ្រុនក្ដៅ)",
      "date": "០២ កញ្ញា ២០២៣",
      "status": "បានអនុម័ត",
      "color": Colors.green,
    },
    {
      "title": "ឈប់ច្បាប់ប្រចាំឆ្នាំ",
      "date": "១០ សីហា ២០២៣",
      "status": "បានបដិសេធ",
      "color": Colors.red,
    },
    // ... other items
  ];

  @override
  void initState() {
    super.initState();
    _annualController = AnimationController(vsync: this, duration: 1500.ms);
    _sickController = AnimationController(vsync: this, duration: 1500.ms);

    _annualAnimation = Tween<double>(begin: 0, end: 0.7).animate(
      CurvedAnimation(parent: _annualController, curve: Curves.easeInOut),
    );
    _sickAnimation = Tween<double>(begin: 0, end: 0.4).animate(
      CurvedAnimation(parent: _sickController, curve: Curves.easeInOut),
    );

    _annualController.forward();
    _sickController.forward();
  }

  @override
  void dispose() {
    _annualController.dispose();
    _sickController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildDoubleOverviewCard(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("ស្ថិតិប្រើប្រាស់", ""),
                const SizedBox(height: 15),
                _buildDetailedStatsGrid(),
                const SizedBox(height: 30),
                _buildSectionHeader("ប្រវត្តិការស្នើសុំ", "មើលទាំងអស់"),
                const SizedBox(height: 5),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return _buildTimelineItem(
                  item['title'] as String,
                  item['date'] as String,
                  item['status'] as String,
                  item['color'] as Color,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "ព័ត៌មានលម្អិតការឈប់សម្រាក",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildDoubleOverviewCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20, top: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildLeaveProgressItem(
                  _annualAnimation,
                  "12/18",
                  "ច្បាប់ប្រចាំឆ្នាំ",
                  Colors.white,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
              Expanded(
                child: _buildLeaveProgressItem(
                  _sickAnimation,
                  "02/05",
                  "ច្បាប់ឈឺ",
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.info_outline,
            "អ្នកនៅសល់សរុប ៩ ថ្ងៃទៀតសម្រាប់ឆ្នាំនេះ",
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveProgressItem(
    Animation<double> animation,
    String value,
    String label,
    Color color,
  ) {
    return Row(
      children: [
        _buildAnimatedCircularIndicator(animation, value, color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "នៅសល់ ${value.split('/')[1].split('')[1]} ថ្ងៃ",
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCircularIndicator(
    Animation<double> animation,
    String value,
    Color color,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 55,
              height: 55,
              child: CircularProgressIndicator(
                value: animation.value,
                strokeWidth: 5,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color == Colors.white ? AppColors.secondary : color,
                ),
              ),
            ),
            Text(
              value.split('/')[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailedStatsGrid() {
    return Row(
      children: [
        _buildStatBox(
          "ច្បាប់ប្រចាំឆ្នាំ",
          "ប្រើអស់ ១២ ថ្ងៃ",
          "សល់ ៦ ថ្ងៃ",
          Colors.blue,
        ),
        const SizedBox(width: 15),
        _buildStatBox(
          "ច្បាប់ឈឺ",
          "ប្រើអស់ ២ ថ្ងៃ",
          "សល់ ៣ ថ្ងៃ",
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatBox(String title, String used, String remain, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              used,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
            Text(
              remain,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String date,
    String status,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
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
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        if (action.isNotEmpty)
          Text(
            action,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                "ស្នើច្បាប់ឈឺ",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: const Size(0, 55),
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
}
