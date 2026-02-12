import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/logic/achievement_logic.dart';

class AchievementScreen extends StatefulWidget {
  final Map<String, dynamic>? loginData;

  const AchievementScreen({super.key, this.loginData});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends AchievementLogic {
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
          _buildBottomGoalCard(
            context,
          ).animate().scale(delay: 600.ms, curve: Curves.bounceOut),
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
      title: Text(
        AppStrings.tr('my_achievements'),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final profileData = getUserProfileData();
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
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(profileData['profileUrl']),
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
          "${AppStrings.tr('hello')}, ${profileData['name']}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          profileData['role'],
          style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
      ],
    ).animate().fadeIn().scale();
  }

  Widget _buildStatsRow(BuildContext context) {
    final profileData = getUserProfileData();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statItem(
            context,
            AppStrings.tr('total_medals'),
            profileData['totalMedals'].toString(),
            Icons.military_tech,
          ),
          const SizedBox(width: 15),
          _statItem(
            context,
            AppStrings.tr('rank_label'),
            "#${profileData['rank']}",
            Icons.leaderboard_outlined,
          ),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
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
    final badgesData = getBadgesData();

    // Badge definitions with icons and colors
    final badgeDefinitions = {
      'early_bird': {'icon': Icons.wb_sunny_outlined, 'color': Colors.orange},
      'perfect_atd': {
        'icon': Icons.calendar_today_outlined,
        'color': Colors.teal,
      },
      'emp_month': {'icon': Icons.military_tech_outlined, 'color': Colors.pink},
      'speed': {'icon': Icons.rocket_launch_outlined, 'color': Colors.blue},
      'collab': {'icon': Icons.handshake_outlined, 'color': Colors.grey},
      'creative': {'icon': Icons.lightbulb_outline, 'color': Colors.grey},
    };

    final badges = badgesData.map((badgeData) {
      final badgeKey = badgeData['name'];
      final definition =
          badgeDefinitions[badgeKey] ??
          {'icon': Icons.star_outline, 'color': Colors.grey};
      return {
        "name": AppStrings.tr('badge_$badgeKey'),
        "icon": definition['icon'],
        "color": definition['color'],
        "locked": badgeData['isLocked'],
      };
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.tr('earned_badges'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                AppStrings.tr('view_all'),
                style: const TextStyle(color: Colors.teal, fontSize: 12),
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

  Widget _buildBottomGoalCard(BuildContext context) {
    final goalData = getGoalData();
    final progressPercent = (goalData['progress'] as double) * 100;

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.tr('next_goal'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      AppStrings.tr(goalData['description']),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${progressPercent.toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: goalData['progress'],
            minHeight: 8,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.secondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.tr('progress'),
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
              Text(
                "${goalData['daysCount']} ${AppStrings.tr('days')}",
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
