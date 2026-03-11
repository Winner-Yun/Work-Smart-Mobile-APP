class Policy {
  final String checkInStart;
  final String checkOutEnd;
  final int lateBufferMinutes;
  final int checkOutScanAllowMinutes;
  final int annualLeaveLimit;
  final int sickLeaveLimit;

  Policy({
    required this.checkInStart,
    required this.checkOutEnd,
    required this.lateBufferMinutes,
    required this.checkOutScanAllowMinutes,
    required this.annualLeaveLimit,
    required this.sickLeaveLimit,
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    final rawAllowMinutes =
        json['check_out_scan_allow_minutes'] ??
        json['checkOutScanAllowMinutes'];
    final int allowMinutes = rawAllowMinutes is num
        ? rawAllowMinutes.toInt()
        : int.tryParse(rawAllowMinutes?.toString() ?? '') ?? 30;
    final normalizedAllowMinutes = allowMinutes > 0 ? allowMinutes : 30;

    return Policy(
      checkInStart: json['check_in_start'] ?? '',
      checkOutEnd: json['check_out_end'] ?? '',
      lateBufferMinutes: json['late_buffer_minutes'] ?? 0,
      checkOutScanAllowMinutes: normalizedAllowMinutes,
      annualLeaveLimit: json['annual_leave_limit'] ?? 0,
      sickLeaveLimit: json['sick_leave_limit'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'check_in_start': checkInStart,
    'check_out_end': checkOutEnd,
    'late_buffer_minutes': lateBufferMinutes,
    'check_out_scan_allow_minutes': checkOutScanAllowMinutes,
    'annual_leave_limit': annualLeaveLimit,
    'sick_leave_limit': sickLeaveLimit,
  };
}
