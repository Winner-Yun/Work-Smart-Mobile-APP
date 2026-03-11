import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/realtime_data_controller.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/user_data.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/activity_models/leave_record.dart';
import 'package:intl/intl.dart';

enum LeaveSortBy {
  dateNewest,
  dateOldest,
  statusPending,
  statusApproved,
  statusRejected,
}

class LeaveRemoveModeState {
  final String? selectedForRemoveRequestId;
  final bool isRemoveMode;

  const LeaveRemoveModeState({
    required this.selectedForRemoveRequestId,
    required this.isRemoveMode,
  });
}

class LeaveRequestLogic {
  static final RealtimeDataController _dataController =
      RealtimeDataController();

  static bool isApprovedStatus(String status) {
    if (status == 'approved') return true;
    final String localized = AppStrings.tr('status_approved');
    return status.trim().toLowerCase() == localized.trim().toLowerCase();
  }

  static bool canRemoveStatus(String status) {
    return !isApprovedStatus(status);
  }

  static Future<void> showRemoveNotAllowedDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: scheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppStrings.tr('remove_leave_request_not_allowed_title'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            AppStrings.tr('remove_leave_request_not_allowed_message'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
              height: 1.35,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(AppStrings.tr('understood')),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> confirmAndDeleteLeave(
    BuildContext context, {
    required LeaveRecord record,
    String? userId,
    bool showSnackBar = true,
  }) async {
    final bool shouldDelete = await confirmRemoveRequest(context);
    if (!shouldDelete) return false;

    final bool removed = await removeLeaveRequest(
      requestId: record.requestId,
      userId: userId,
    );
    if (!removed) return false;

    if (!context.mounted) return true;

    if (showSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(
            AppStrings.tr('leave_request_removed'),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return true;
  }

  static String getLeaveTitle(String type) {
    switch (type) {
      case 'annual_leave':
        return AppStrings.tr('annual_leave');
      case 'sick_leave':
        return AppStrings.tr('sick_leave');
      default:
        return type.replaceAll('_', ' ');
    }
  }

  static IconData getLeaveIcon(String type) {
    switch (type) {
      case 'annual_leave':
        return Icons.beach_access_outlined;
      case 'sick_leave':
        return Icons.medical_services_outlined;
      default:
        return Icons.calendar_today_outlined;
    }
  }

  static String getStatusText(String status) {
    switch (status) {
      case 'approved':
        return AppStrings.tr('status_approved');
      case 'rejected':
        return AppStrings.tr('status_rejected');
      case 'pending':
      default:
        return AppStrings.tr('status_pending');
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  static LeaveRemoveModeState getLongPressRemoveModeState({
    required LeaveRecord record,
    required bool isSelectedForRemove,
  }) {
    if (isSelectedForRemove) {
      return const LeaveRemoveModeState(
        selectedForRemoveRequestId: null,
        isRemoveMode: false,
      );
    }

    return LeaveRemoveModeState(
      selectedForRemoveRequestId: record.requestId,
      isRemoveMode: true,
    );
  }

  static LeaveRemoveModeState getTapRemoveModeState({
    required LeaveRecord record,
    required bool isSelectedForRemove,
  }) {
    if (isSelectedForRemove) {
      return const LeaveRemoveModeState(
        selectedForRemoveRequestId: null,
        isRemoveMode: false,
      );
    }

    return LeaveRemoveModeState(
      selectedForRemoveRequestId: record.requestId,
      isRemoveMode: true,
    );
  }

  static List<LeaveRecord> filterHistoryByDate(
    List<LeaveRecord> history,
    DateTime? selectedDate,
  ) {
    if (selectedDate == null) {
      return history.toList();
    }

    final DateTime target = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    return history.where((record) {
      final DateTime start = DateTime(
        record.startDate.year,
        record.startDate.month,
        record.startDate.day,
      );
      final DateTime end = DateTime(
        record.endDate.year,
        record.endDate.month,
        record.endDate.day,
      );

      return !target.isBefore(start) && !target.isAfter(end);
    }).toList();
  }

  static String formatDateRange(LeaveRecord record) {
    final DateTime startDate = record.startDate;
    final DateTime endDate = record.endDate;
    final DateFormat fullFormatter = DateFormat('dd MMM yyyy');

    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      return fullFormatter.format(startDate);
    }

    final String endText = fullFormatter.format(endDate);
    String startText = DateFormat('dd MMM').format(startDate);

    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      startText = DateFormat('dd').format(startDate);
    }

    return '$startText - $endText';
  }

  static Future<bool> confirmRemoveRequest(BuildContext context) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: scheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppStrings.tr('remove_leave_request_title'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            AppStrings.tr('remove_leave_request_message'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
              height: 1.35,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(AppStrings.tr('cancel_button')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                AppStrings.tr('remove_button'),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    return shouldDelete == true;
  }

  static Future<bool> submitLeaveRequest({
    required String userId,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? attachmentUrl,
  }) async {
    final String normalizedUid = userId.trim();
    if (normalizedUid.isEmpty) return false;

    final int userIndex = _findUserIndex(uid: normalizedUid);
    if (userIndex < 0) return false;

    final List<Map<String, dynamic>> leaveRecords = _copyLeaveRecords(
      usersFinalData[userIndex]['leave_records'],
    );

    final String normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) return false;

    final DateTime normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final DateTime normalizedEnd = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );

    final Map<String, dynamic> request = <String, dynamic>{
      'request_id': _generateLeaveRequestId(normalizedUid),
      'type': type,
      'start_date': normalizedStart.toIso8601String(),
      'end_date': normalizedEnd.toIso8601String(),
      'reason': normalizedReason,
      'status': 'pending',
    };

    final String? normalizedAttachment = attachmentUrl?.trim();
    if (normalizedAttachment != null && normalizedAttachment.isNotEmpty) {
      request['attachment_url'] = normalizedAttachment;
    }

    leaveRecords.insert(0, request);

    try {
      await _dataController.updateUserRecord(normalizedUid, {
        'leave_records': leaveRecords,
      });
      usersFinalData[userIndex]['leave_records'] = leaveRecords;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> removeLeaveRequest({
    required String requestId,
    String? userId,
  }) async {
    int userIndex = _findUserIndex(uid: userId?.trim());

    if (userIndex < 0) {
      userIndex = _findUserIndex(requestId: requestId);
    }

    if (userIndex < 0) return false;

    final String targetUid =
        usersFinalData[userIndex]['uid']?.toString().trim() ?? '';
    if (targetUid.isEmpty) return false;

    final List<Map<String, dynamic>> leaveRecords = _copyLeaveRecords(
      usersFinalData[userIndex]['leave_records'],
    );

    Map<String, dynamic>? target;
    for (final item in leaveRecords) {
      if (item['request_id']?.toString() == requestId) {
        target = item;
        break;
      }
    }

    if (target != null && target['status'] == 'approved') {
      return false;
    }

    final int beforeCount = leaveRecords.length;
    leaveRecords.removeWhere(
      (item) => item['request_id']?.toString() == requestId,
    );

    if (beforeCount == leaveRecords.length) return false;

    try {
      await _dataController.updateUserRecord(targetUid, {
        'leave_records': leaveRecords,
      });
      usersFinalData[userIndex]['leave_records'] = leaveRecords;
      return true;
    } catch (_) {
      return false;
    }
  }

  static int _findUserIndex({String? uid, String? requestId}) {
    final String? normalizedUid = uid?.trim();
    if (normalizedUid != null && normalizedUid.isNotEmpty) {
      final int byUid = usersFinalData.indexWhere(
        (user) => user['uid']?.toString().trim() == normalizedUid,
      );
      if (byUid >= 0) return byUid;
    }

    if (requestId != null && requestId.isNotEmpty) {
      final int byRequest = usersFinalData.indexWhere((user) {
        final List<Map<String, dynamic>> records = _copyLeaveRecords(
          user['leave_records'],
        );
        return records.any(
          (item) => item['request_id']?.toString() == requestId,
        );
      });
      if (byRequest >= 0) return byRequest;
    }

    return usersFinalData.indexWhere(
      (user) => user['uid'] == 'user_winner_777',
    );
  }

  static List<Map<String, dynamic>> _copyLeaveRecords(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static String _generateLeaveRequestId(String uid) {
    final String alnumUid = uid.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final String suffix = alnumUid.length > 6
        ? alnumUid.substring(alnumUid.length - 6)
        : alnumUid;

    return 'leave_${DateTime.now().microsecondsSinceEpoch}_$suffix';
  }

  static List<LeaveRecord> sortHistory(
    List<LeaveRecord> history,
    LeaveSortBy sortBy,
  ) {
    final List<LeaveRecord> sorted = history.toList();

    switch (sortBy) {
      case LeaveSortBy.dateNewest:
        sorted.sort((a, b) => b.startDate.compareTo(a.startDate));
        break;
      case LeaveSortBy.dateOldest:
        sorted.sort((a, b) => a.startDate.compareTo(b.startDate));
        break;
      case LeaveSortBy.statusPending:
        sorted.sort((a, b) {
          final aPending = a.status == 'pending' ? 0 : 1;
          final bPending = b.status == 'pending' ? 0 : 1;
          if (aPending != bPending) return aPending.compareTo(bPending);
          return b.startDate.compareTo(a.startDate);
        });
        break;
      case LeaveSortBy.statusApproved:
        sorted.sort((a, b) {
          final aApproved = a.status == 'approved' ? 0 : 1;
          final bApproved = b.status == 'approved' ? 0 : 1;
          if (aApproved != bApproved) return aApproved.compareTo(bApproved);
          return b.startDate.compareTo(a.startDate);
        });
        break;
      case LeaveSortBy.statusRejected:
        sorted.sort((a, b) {
          final aRejected = a.status == 'rejected' ? 0 : 1;
          final bRejected = b.status == 'rejected' ? 0 : 1;
          if (aRejected != bRejected) return aRejected.compareTo(bRejected);
          return b.startDate.compareTo(a.startDate);
        });
        break;
    }

    return sorted;
  }
}
