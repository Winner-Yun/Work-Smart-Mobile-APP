import 'package:flutter_worksmart_mobile_app/shared/model/activity_models/leave_record.dart';

import 'achievements.dart';
import 'app_settings.dart';
import 'biometrics.dart';
import 'telegram_account.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String roleTitle;
  final String profileUrl;
  final String phone;
  final String email;
  final String officeId;
  final String departmentId;
  final Biometrics biometrics;
  final List<LeaveRecord> leaveRecords;
  final TelegramAccount telegram;
  final Achievements achievements;
  final AppSettings appSettings;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.roleTitle,
    required this.profileUrl,
    required this.phone,
    required this.email,
    required this.officeId,
    required this.departmentId,
    required this.biometrics,
    required this.telegram,
    required this.leaveRecords,
    required this.achievements,
    required this.appSettings,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      displayName: json['display_name'] ?? '',
      roleTitle: json['role_title'] ?? '',
      profileUrl: json['profile_url'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      officeId: json['office_id'] ?? '',
      departmentId: json['department_id'] ?? '',
      biometrics: Biometrics.fromJson(json['biometrics'] ?? {}),
      telegram: TelegramAccount.fromJson(json['telegram'] ?? {}),
      leaveRecords:
          (json['leave_records'] as List<dynamic>?)
              ?.map((e) => LeaveRecord.fromJson(e))
              .toList() ??
          [],
      achievements: Achievements.fromJson(json['achievements'] ?? {}),
      appSettings: AppSettings.fromJson(json['app_settings'] ?? {}),
    );
  }
}
