import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/achievement_screens/empleaderboard_screen.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';

abstract class LeaderboardLogic extends State<LeaderboardScreen> {
  late List<UserProfile> allEmployees;
  late String? loggedInUserId;
  bool isMonthly = true;

  @override
  void initState() {
    super.initState();
    loggedInUserId = widget.loginData?['uid'];
    _loadData();
  }

  void _loadData() {
    // Load all employees from mock data and convert to UserProfile models
    allEmployees = usersFinalData
        .map((json) => UserProfile.fromJson(json))
        .toList();
  }

  /// Get sorted employee data for leaderboard display
  List<Map<String, dynamic>> getLeaderboardData() {
    // Sort by performance score in descending order
    final sortedEmployees = List<UserProfile>.from(allEmployees)
      ..sort((a, b) {
        final scoreA = a.achievements.performanceScore;
        final scoreB = b.achievements.performanceScore;
        return scoreB.compareTo(scoreA);
      });

    return List.generate(sortedEmployees.length, (index) {
      final user = sortedEmployees[index];
      final rank = index + 1;

      // Determine trend (optional - can be extended with historical data if available)
      int trend = user.achievements.rankTrend;

      return {
        "rank": rank,
        "name": user.displayName,
        "dept": user.departmentId,
        "score": user.achievements.performanceScore,
        "trend": trend,
        "img": user.profileUrl,
      };
    });
  }

  /// Get top 3 employees for podium
  List<Map<String, dynamic>> getTopThreeEmployees() {
    final leaderboard = getLeaderboardData();
    return leaderboard.where((e) => e['rank'] <= 3).toList();
  }

  /// Get remaining employees (rank 4 and above)
  List<Map<String, dynamic>> getNextRankingsEmployees() {
    final leaderboard = getLeaderboardData();
    return leaderboard.where((e) => e['rank'] > 3).toList();
  }
}
