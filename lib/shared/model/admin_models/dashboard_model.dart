import 'package:flutter_worksmart_mobile_app/core/constants/default_profile_urls.dart';

class DashboardStatsData {
  final int totalEmployees;
  final int presentCount;
  final double presentRate;
  final int onTimeCount;
  final int lateCount;
  final double onTimeRate;
  final int pendingRequests;

  const DashboardStatsData({
    required this.totalEmployees,
    required this.presentCount,
    required this.presentRate,
    required this.onTimeCount,
    required this.lateCount,
    required this.onTimeRate,
    required this.pendingRequests,
  });
}

class AttendanceRowData {
  final String name;
  final String dept;
  final String checkIn;
  final String checkOut;
  final String statusLabel;
  final String timeStatus;
  final String profileUrl;
  final bool isLate;
  final String? email;
  final String? phone;
  final String? officeId;
  final String? departmentId;

  const AttendanceRowData({
    required this.name,
    required this.dept,
    required this.checkIn,
    required this.checkOut,
    required this.statusLabel,
    required this.timeStatus,
    required this.profileUrl,
    required this.isLate,
    this.email,
    this.phone,
    this.officeId,
    this.departmentId,
  });
}

class TopPerformerData {
  final String name;
  final String dept;
  final String score;
  final String profileUrl;

  const TopPerformerData({
    required this.name,
    required this.dept,
    required this.score,
    required this.profileUrl,
  });
}

class LeaveRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final String profileUrl;
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;
  final String? attachmentUrl;
  final String? statusUpdatedAtUtc;
  final int? statusUpdatedAtUnix;
  final String status; // pending, approved, rejected

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    this.profileUrl = '',
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.attachmentUrl,
    this.statusUpdatedAtUtc,
    this.statusUpdatedAtUnix,
    required this.status,
  });
}

class UserEmployee {
  final String uid;
  final String displayName;
  final String roleTitle;
  final String gender;
  final String email;
  final String phone;
  final String departmentId;
  final String officeId;
  final String profileUrl;
  final String faceImageUrl;
  final List<String> faceImageUrls;
  final int faceCount;
  final String? status;
  final DateTime? joinDate;
  final String? faceStatus;

  UserEmployee({
    required this.uid,
    required this.displayName,
    required this.roleTitle,
    this.gender = 'male',
    required this.email,
    required this.phone,
    required this.departmentId,
    required this.officeId,
    required this.profileUrl,
    this.faceImageUrl = '',
    this.faceImageUrls = const [],
    this.faceCount = 0,
    this.status = 'active',
    this.joinDate,
    this.faceStatus,
  });

  factory UserEmployee.fromMap(Map<String, dynamic> map) {
    final biometrics = (map['biometrics'] as Map<String, dynamic>?) ?? {};

    final dynamic imageListRaw =
        biometrics['face_image_urls'] ?? biometrics['face_images'];
    final parsedList = imageListRaw is List
        ? imageListRaw
              .whereType<String>()
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];
    final singleImage = (biometrics['face_image_url'] as String?)?.trim() ?? '';
    final mergedFaceImages = {
      if (singleImage.isNotEmpty) singleImage,
      ...parsedList,
    }.toList();
    final gender = (map['gender'] ?? 'male').toString();
    final resolvedProfileUrl = DefaultProfileUrls.resolve(
      gender: gender,
      providedUrl: map['profile_url']?.toString(),
    );

    return UserEmployee(
      uid: map['uid'] ?? '',
      displayName: map['display_name'] ?? 'Unknown',
      roleTitle: map['role_title'] ?? 'Staff',
      gender: gender,
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      departmentId: map['department_id'] ?? '',
      officeId: map['office_id'] ?? '',
      profileUrl: resolvedProfileUrl,
      faceImageUrl: singleImage,
      faceImageUrls: mergedFaceImages,
      faceCount: biometrics['face_count'] ?? mergedFaceImages.length,
      status: map['status'] ?? 'active',
      joinDate: map['join_date'] != null
          ? DateTime.parse(map['join_date'])
          : null,
      faceStatus: biometrics['face_status'] ?? 'pending',
    );
  }
}
