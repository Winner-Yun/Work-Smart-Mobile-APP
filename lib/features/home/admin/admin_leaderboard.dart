import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';

class AdminLeaderboard extends StatefulWidget {
  const AdminLeaderboard({super.key});

  @override
  State<AdminLeaderboard> createState() => _AdminLeaderboardState();
}

class _AdminLeaderboardState extends State<AdminLeaderboard> {
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppStrings.tr('admin_ranking'), style: const TextStyle(fontFamily: 'Khmer')),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(
        children: [
          _buildTopTabs(),
          _buildStatsCards(),
          const SizedBox(height: 20),
          _buildPodium(),
          Expanded(child: _buildRankList()),
        ],
      ),
    );
  }

  Widget _buildTopTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(child: _tabItem(AppStrings.tr('every_week'), active: true)),
          Expanded(child: _tabItem(AppStrings.tr('every_months'))),
          Expanded(child: _tabItem(AppStrings.tr('group_average'))),
        ],
      ),
    );
  }

  Widget _tabItem(String text, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _statCard(AppStrings.tr('total_reard'), "96.8%", AppColors.primary),
          const SizedBox(width: 12),
          // Assuming you'll add a 'stars' key or similar for the total count
          _statCard(AppStrings.tr('total_reward_count') ?? "Reward", "482 ⭐", Colors.white10), 
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _podiumUser("សាកា ជនសិន", "99.2%", "#២", 75, "https://i.pravatar.cc/150?u=1"),
        _podiumUser("ម៉ៃឃើល ធន", "១០០%", "លេខ ១", 100, "https://i.pravatar.cc/150?u=2", isGold: true),
        _podiumUser("អាណា ឃិនស្មី", "98.5%", "#៣", 75, "https://i.pravatar.cc/150?u=3"),
      ],
    );
  }

  Widget _podiumUser(String name, String score, String rank, double size, String imgPath, {bool isGold = false}) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none, // Allows the rank badge to sit lower
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isGold ? Colors.amber : Colors.blueGrey, width: 3),
              ),
              child: CircleAvatar(
                radius: size / 2,
                backgroundColor: Colors.grey,
                backgroundImage: imgPath.startsWith('http') 
                    ? NetworkImage(imgPath) 
                    : AssetImage(imgPath) as ImageProvider,
              ),
            ),
            Positioned(
              bottom: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isGold ? Colors.amber : Colors.blueGrey, 
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Text(rank, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightSurface, fontSize: 16)),
        Text(score, style: const TextStyle(color: Colors.amber, fontSize: 14)),
      ],
    );
  }

  Widget _buildRankList() {
    final List<Map<String, dynamic>> players = [
      {"name": "ដេវីដ ម៉ីល័រ", "stat": "97.8%", "stars": "12", "img": "https://i.pinimg.com/1200x/fd/69/c8/fd69c87db3aecc3f1fbcc2ef2afd7e4d.jpg"},
      {"name": "ជេស៊ីកា វ៉ុង", "stat": "96.5%", "stars": "8", "img": "https://i.pravatar.cc/150?u=4"},
      {"name": "រ៉ូប៊ីត ស្មីត", "stat": "94.2%", "stars": "15", "img": "https://i.pravatar.cc/150?u=5"},
      {"name": "អេមីលី ដេវីស", "stat": "93.9%", "stars": "5", "img": "https://i.pravatar.cc/150?u=6"},
      {"name": "អេមីលី ដេវីស", "stat": "93.9%", "stars": "5", "img": "https://i.pravatar.cc/150?u=6"},
      {"name": "អេមីលី ដេវីស", "stat": "93.9%", "stars": "5", "img": "https://i.pravatar.cc/150?u=6"},
      {"name": "អេមីលី ដេវីស", "stat": "93.9%", "stars": "5", "img": "https://i.pravatar.cc/150?u=6"},
    ];

    return ListView.separated(
      padding: const EdgeInsets.only(top: 10),
      itemCount: players.length,
      separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) {
        final player = players[index];
        final String imgPath = player['img'];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text("${index + 4}", style: const TextStyle(color: Colors.white60, fontSize: 16)),
              const SizedBox(width: 15),
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white10,
                backgroundImage: imgPath.startsWith('http') 
                    ? NetworkImage(imgPath) 
                    : AssetImage(imgPath) as ImageProvider,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player['name'], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text("${AppStrings.tr('on-time')} ${player['stat']}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.circle, size: 4, color: Colors.white54)),
                        const Icon(Icons.stars, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(player['stars'], style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFFB300), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle, size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(AppStrings.tr('give_reward'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}