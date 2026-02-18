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
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;
  final String status; // pending, approved, rejected

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
  });
}

class UserEmployee {
  final String uid;
  final String displayName;
  final String roleTitle;
  final String email;
  final String phone;
  final String departmentId;
  final String officeId;
  final String profileUrl;
  final String? status;
  final DateTime? joinDate;
  final String? faceStatus;

  UserEmployee({
    required this.uid,
    required this.displayName,
    required this.roleTitle,
    required this.email,
    required this.phone,
    required this.departmentId,
    required this.officeId,
    required this.profileUrl,
    this.status = 'active',
    this.joinDate,
    this.faceStatus,
  });

  factory UserEmployee.fromMap(Map<String, dynamic> map) {
    return UserEmployee(
      uid: map['uid'] ?? '',
      displayName: map['display_name'] ?? 'Unknown',
      roleTitle: map['role_title'] ?? 'Staff',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      departmentId: map['department_id'] ?? '',
      officeId: map['office_id'] ?? '',
      profileUrl: map['profile_url'] ?? '',
      status: map['status'] ?? 'active',
      joinDate: map['join_date'] != null
          ? DateTime.parse(map['join_date'])
          : null,
      faceStatus: map['biometrics']?['face_status'] ?? 'pending',
    );
  }
}
