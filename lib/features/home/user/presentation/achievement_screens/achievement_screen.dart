import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 20),
          _buildStatsRow(context),
          const SizedBox(height: 30),
          Expanded(child: _buildBadgesGrid(context)),
          _buildBottomGoalCard().animate().scale(
            delay: 600.ms,
            curve: Curves.bounceOut,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).iconTheme.color,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "សមិទ្ធផលរបស់ខ្ញុំ",
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.secondary, Colors.orange],
                ),
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=4'),
              ),
            ),
            CircleAvatar(
              radius: 14,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "សួស្តី, វិនន័រ",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const Text(
          "អ្នកបម្រើការផ្នែក IT",
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
      ],
    ).animate().fadeIn().scale();
  }

  Widget _buildStatsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statItem(context, "មេដាយសរុប", "១២", Icons.military_tech),
          const SizedBox(width: 15),
          _statItem(context, "ចំណាត់ថ្នាក់", "#៥", Icons.leaderboard_outlined),
        ],
      ),
    );
  }

  Widget _statItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context) {
    final badges = [
      {
        "name": "មកដល់មុនគេ",
        "icon": Icons.wb_sunny_outlined,
        "color": Colors.orange,
        "locked": false,
      },
      {
        "name": "វត្តមានឥតខ្ចោះ",
        "icon": Icons.calendar_today_outlined,
        "color": Colors.teal,
        "locked": false,
      },
      {
        "name": "ឆ្នើមប្រចាំខែ",
        "icon": Icons.military_tech_outlined,
        "color": Colors.pink,
        "locked": false,
      },
      {
        "name": "លឿនរហ័ស",
        "icon": Icons.rocket_launch_outlined,
        "color": Colors.blue,
        "locked": false,
      },
      {
        "name": "សហការល្អ",
        "icon": Icons.handshake_outlined,
        "color": Colors.grey,
        "locked": true,
      },
      {
        "name": "គំនិតច្នៃប្រឌិត",
        "icon": Icons.lightbulb_outline,
        "color": Colors.grey,
        "locked": true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "មេដាយដែលទទួលបាន",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const Text(
                "មើលទាំងអស់",
                style: TextStyle(color: Colors.teal, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.8,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) =>
                _badgeItem(context, badges[index], index),
          ),
        ),
      ],
    );
  }

  Widget _badgeItem(
    BuildContext context,
    Map<String, dynamic> badge,
    int index,
  ) {
    bool isLocked = badge['locked'];
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLocked
                ? Theme.of(context).dividerColor.withOpacity(0.1)
                : (badge['color'] as Color).withValues(alpha: 0.1),
            border: isLocked
                ? null
                : Border.all(color: badge['color'], width: 1.5),
          ),
          child: Icon(
            badge['icon'],
            color: isLocked ? Theme.of(context).disabledColor : badge['color'],
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          badge['name'],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isLocked
                ? Colors.grey
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    ).animate().fadeIn(delay: (index * 50).ms).scale();
  }

  Widget _buildBottomGoalCard() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: AppColors.secondary,
                size: 28,
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "គោលដៅបន្ទាប់",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "បន្ត ៥ ថ្ងៃទៀតដើម្បីបានមេដាយ 'វីរៈបុរស'",
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Text(
                "៨០%",
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const LinearProgressIndicator(
            value: 0.8,
            minHeight: 8,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "វឌ្ឍនភាព",
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
              Text(
                "២០/២៥ ថ្ងៃ",
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
