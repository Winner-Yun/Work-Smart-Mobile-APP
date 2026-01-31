import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/config/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/translations/app_strings.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool isMonthly = true;

  // Mock Database Structure
  final List<Map<String, dynamic>> mockEmployees = [
    {
      "rank": 1,
      "name": "តារា",
      "dept": "km_it",
      "score": 95,
      "trend": 0,
      "img": "https://i.pravatar.cc/150?u=1",
    },
    {
      "rank": 2,
      "name": "បូផា",
      "dept": "km_acc",
      "score": 87,
      "trend": 0,
      "img": "https://i.pravatar.cc/150?u=2",
    },
    {
      "rank": 3,
      "name": "វិបុល",
      "dept": "km_admin",
      "score": 85,
      "trend": 0,
      "img": "https://i.pravatar.cc/150?u=3",
    },
    {
      "rank": 4,
      "name": "សុភ័ក្រ",
      "dept": "km_it",
      "score": 92,
      "trend": 2,
      "img": "https://i.pravatar.cc/150?u=4",
    },
    {
      "rank": 5,
      "name": "សុខា",
      "dept": "km_acc",
      "score": 90,
      "trend": -9,
      "img": "https://i.pravatar.cc/150?u=5",
    },
    {
      "rank": 6,
      "name": "បញ្ញា",
      "dept": "km_admin",
      "score": 88,
      "trend": 0,
      "img": "https://i.pravatar.cc/150?u=6",
    },
    {
      "rank": 7,
      "name": "រតនា",
      "dept": "km_it",
      "score": 87,
      "trend": 1,
      "img": "https://i.pravatar.cc/150?u=7",
    },
    {
      "rank": 8,
      "name": "ពិសិដ្ឋ",
      "dept": "km_admin",
      "score": 85,
      "trend": -2,
      "img": "https://i.pravatar.cc/150?u=8",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Separate podium vs list data
    final topThree = mockEmployees.where((e) => e['rank'] <= 3).toList();
    final nextRankings = mockEmployees.where((e) => e['rank'] > 3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.tr('top_rankings'),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ).animate().fadeIn(duration: 400.ms).moveY(begin: -10, end: 0),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.workspace_premium,
              color: AppColors.secondary,
              size: 28,
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoute.achievementScreen);
            },
          ).animate().fadeIn(delay: 500.ms).scale(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildToggleButtons().animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 20),

          _buildPodiumSection(topThree),
          const SizedBox(height: 20),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                    child: _buildListHeader(),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: nextRankings.length,
                      itemBuilder: (context, index) {
                        final emp = nextRankings[index];
                        return _buildRankItem(emp, index);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildGoalCard().animate().scale(
                      delay: 600.ms,
                      curve: Curves.bounceOut,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[300]!.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleItem(
            AppStrings.tr('monthly'),
            isMonthly,
            () => setState(() => isMonthly = true),
          ),
          _toggleItem(
            AppStrings.tr('yearly'),
            !isMonthly,
            () => setState(() => isMonthly = false),
          ),
        ],
      ),
    );
  }

  Widget _toggleItem(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active ? AppColors.primary : AppColors.textGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumSection(List<Map<String, dynamic>> topThree) {
    // Reordering list so rank 2 is left, rank 1 is center, rank 3 is right
    final rank1 = topThree.firstWhere((e) => e['rank'] == 1);
    final rank2 = topThree.firstWhere((e) => e['rank'] == 2);
    final rank3 = topThree.firstWhere((e) => e['rank'] == 3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _podiumUser(rank2, 90, Colors.grey[400]!, delay: 300.ms),
          _podiumUser(
            rank1,
            130,
            AppColors.secondary,
            hasCrown: true,
            delay: 100.ms,
          ),
          _podiumUser(rank3, 75, Colors.orange[300]!, delay: 500.ms),
        ],
      ),
    );
  }

  Widget _podiumUser(
    Map<String, dynamic> emp,
    double height,
    Color color, {
    bool hasCrown = false,
    required Duration delay,
  }) {
    int rank = emp['rank'];
    return Column(
      children: [
        if (hasCrown)
          Image.asset(AppImg.crown, width: 35)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -5, duration: 1.seconds),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 40 : 32,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(emp['img']),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "#$rank",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ).animate().scale(delay: delay),
        const SizedBox(height: 8),
        Text(
          emp['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          "${emp['score']}%",
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 75,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.6),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: Icon(
            rank == 1 ? Icons.military_tech : Icons.emoji_events,
            color: color,
            size: 24,
          ),
        ).animate().moveY(
          begin: height,
          end: 0,
          delay: delay,
          duration: 600.ms,
        ),
      ],
    );
  }

  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.tr('next_rankings'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          AppStrings.tr('average_score'),
          style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRankItem(Map<String, dynamic> emp, int index) {
    int trend = emp['trend'];
    String deptKey = emp['dept'] == 'km_it'
        ? 'it_department'
        : (emp['dept'] == 'km_acc' ? 'acc_department' : 'admin_department');

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 25,
                child: Text(
                  "${emp['rank']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(emp['img']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      AppStrings.tr(deptKey),
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${emp['score']}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  if (trend > 0)
                    Text(
                      "↑ $trend",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (trend < 0)
                    Text(
                      "↓ ${trend.abs()}",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (400 + (index * 50)).ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildGoalCard() {
    double progress = 0.85;
    return Container(
      padding: const EdgeInsets.all(16),
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
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.tr('next_goal'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      AppStrings.tr('goal_description'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
