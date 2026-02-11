import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/logic/leaderboard_logic.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends LeaderboardLogic {
  @override
  Widget build(BuildContext context) {
    final topThree = getTopThreeEmployees();
    final nextRankings = getNextRankingsEmployees();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBackgroundContent(topThree),
          _buildDraggableSheet(nextRankings),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
        AppStrings.tr('top_rankings'),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.workspace_premium,
            color: AppColors.secondary,
            size: 28,
          ),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoute.achievementScreen),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBackgroundContent(List<Map<String, dynamic>> topThree) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildToggleButtons().animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 20),
        _buildPodiumSection(topThree),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildDraggableSheet(List<Map<String, dynamic>> nextRankings) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDragHandle(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: _buildListHeader(),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: nextRankings.length,
                  itemBuilder: (context, index) {
                    return _buildRankItem(nextRankings[index], index);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem(
            AppStrings.tr('monthly'),
            isMonthly,
            () => setState(() => isMonthly = true),
          ),
          _buildToggleItem(
            AppStrings.tr('yearly'),
            !isMonthly,
            () => setState(() => isMonthly = false),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).cardTheme.color
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active
                ? Theme.of(context).colorScheme.primary
                : AppColors.textGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumSection(List<Map<String, dynamic>> topThree) {
    final rank1 = topThree.firstWhere((e) => e['rank'] == 1);
    final rank2 = topThree.firstWhere((e) => e['rank'] == 2);
    final rank3 = topThree.firstWhere((e) => e['rank'] == 3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumUser(rank2, 90, Colors.grey[400]!, delay: 300.ms),
          _buildPodiumUser(
            rank1,
            130,
            AppColors.secondary,
            hasCrown: true,
            delay: 100.ms,
          ),
          _buildPodiumUser(rank3, 75, Colors.orange[300]!, delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildPodiumUser(
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
                backgroundColor: Theme.of(context).cardTheme.color,
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
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
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
              colors: [color.withOpacity(0.6), color.withOpacity(0.1)],
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      emp['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.tr(deptKey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${emp['score']}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                  if (trend > 0)
                    Text(
                      "↑ $trend",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (trend < 0)
                    Text(
                      "↓ ${trend.abs()}",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (200 + (index * 50)).ms)
        .slideX(begin: 0.1, end: 0);
  }
}
