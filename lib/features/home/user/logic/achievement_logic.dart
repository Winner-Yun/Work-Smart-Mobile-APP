import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/features/home/user/presentation/achievement_screens/achievement_screen.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';

abstract class AchievementLogic extends State<AchievementScreen> {
  late UserProfile currentUser;
  late List<UserProfile> allEmployees;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load current user (simulating logged-in user "Winner")
    final currentUserData = usersFinalData.firstWhere(
      (user) => user['uid'] == "user_winner_777",
      orElse: () => usersFinalData[0],
    );
    currentUser = UserProfile.fromJson(currentUserData);

    // Load all employees to calculate rank
    allEmployees = usersFinalData
        .map((json) => UserProfile.fromJson(json))
        .toList();
  }

  /// Get current user's rank by sorting all employees by performance score
  int getUserRank() {
    final sortedEmployees = List<UserProfile>.from(allEmployees)
      ..sort((a, b) {
        final scoreA = a.achievements.performanceScore;
        final scoreB = b.achievements.performanceScore;
        return scoreB.compareTo(scoreA);
      });

    final rankIndex = sortedEmployees.indexWhere(
      (u) => u.uid == currentUser.uid,
    );
    return rankIndex >= 0 ? rankIndex + 1 : 0;
  }

  /// Get user profile info
  Map<String, dynamic> getUserProfileData() {
    return {
      "name": currentUser.displayName,
      "role": currentUser.roleTitle,
      "profileUrl": currentUser.profileUrl,
      "totalMedals": currentUser.achievements.totalMedals,
      "rank": getUserRank(),
    };
  }

  /// Get badges data from user achievements
  List<Map<String, dynamic>> getBadgesData() {
    final badges = currentUser.achievements.badges;

    return badges.map((badge) {
      return {"name": badge.key, "isLocked": !badge.isUnlocked};
    }).toList();
  }

  /// Get goal data from user achievements
  Map<String, dynamic> getGoalData() {
    final goal = currentUser.achievements.goal;
    return {
      "title": goal.title,
      "description": goal.desc,
      "progress": goal.progressPercent,
      "daysCount": goal.daysCount,
    };
  }
}
