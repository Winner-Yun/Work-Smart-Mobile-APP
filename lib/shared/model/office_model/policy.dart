class Policy {
  final String checkInStart;
  final String checkOutEnd;
  final int lateBufferMinutes;
  final int annualLeaveLimit;
  final int sickLeaveLimit;

  Policy({
    required this.checkInStart,
    required this.checkOutEnd,
    required this.lateBufferMinutes,
    required this.annualLeaveLimit,
    required this.sickLeaveLimit,
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      checkInStart: json['check_in_start'] ?? '',
      checkOutEnd: json['check_out_end'] ?? '',
      lateBufferMinutes: json['late_buffer_minutes'] ?? 0,
      annualLeaveLimit: json['annual_leave_limit'] ?? 0,
      sickLeaveLimit: json['sick_leave_limit'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'check_in_start': checkInStart,
    'check_out_end': checkOutEnd,
    'late_buffer_minutes': lateBufferMinutes,
    'annual_leave_limit': annualLeaveLimit,
    'sick_leave_limit': sickLeaveLimit,
  };
}
