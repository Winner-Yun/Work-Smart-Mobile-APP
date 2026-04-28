import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/realtime_data_controller.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/user/data_empty_state.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  final Map<String, dynamic>? loginData;

  const NotificationScreen({super.key, this.loginData});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final RealtimeDataController _realtimeDataController =
      RealtimeDataController();

  String get _uid => (widget.loginData?['uid'] ?? '').toString().trim();

  Future<void> _deleteNotification(String notificationId) async {
    if (_uid.isEmpty) return;

    await _realtimeDataController.deleteUserNotification(_uid, notificationId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: Text(AppStrings.tr('notif_deleted')),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _markAsRead(String notificationId) async {
    if (_uid.isEmpty) return;
    await _realtimeDataController.markUserNotificationRead(
      _uid,
      notificationId,
      isRead: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_uid.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: _buildEmptyState(message: 'User not found.'),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _realtimeDataController.watchUserNotifications(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? const <Map<String, dynamic>>[];
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }
          return _buildNotificationList(notifications);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).iconTheme.color,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppStrings.tr('notifications_title'),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.done_all,
            color: Theme.of(context).colorScheme.primary,
          ),
          tooltip: AppStrings.tr('read_all'),
          onPressed: () async {
            if (_uid.isEmpty) return;
            await _realtimeDataController.markAllUserNotificationsRead(_uid);
          },
        ),
      ],
    );
  }

  Widget _buildNotificationList(List<Map<String, dynamic>> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final item = notifications[index];
        final String notificationId = (item['id'] ?? '').toString();
        return GestureDetector(
          onTap: () => _handleNotificationTap(item),
          child: Dismissible(
            key: ValueKey<String>('notif-$notificationId'),
            direction: DismissDirection.endToStart,
            background: _buildDeleteBackground(),
            onDismissed: (_) => _deleteNotification(notificationId),
            child: _buildNotificationItem(item, index),
          ),
        );
      },
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> data, int index) {
    final size = MediaQuery.of(context).size;
    final bool isSmall = size.width < 360;

    final bool isRead = (data['isRead'] as bool?) ?? false;
    final String title = (data['title'] ?? '').toString();
    final String message = (data['message'] ?? '').toString();
    final String type = (data['type'] ?? 'general').toString();
    final DateTime? timestamp = _readTimestamp(data['timestamp']);

    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.015),
      padding: EdgeInsets.all(isSmall ? 12 : 15),
      decoration: BoxDecoration(
        color: isRead
            ? Theme.of(context).cardTheme.color?.withValues(alpha: 0.6)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isRead
              ? Theme.of(context).dividerColor.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(type, isRead),

          SizedBox(width: size.width * 0.03),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE + TIME
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 13 : 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      _formatTimestamp(timestamp),
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: isSmall ? 10 : 11,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.006),

                /// MESSAGE
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                    fontSize: isSmall ? 12 : 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          if (!isRead)
            Container(
              margin: EdgeInsets.only(left: size.width * 0.02, top: 5),
              width: isSmall ? 6 : 8,
              height: isSmall ? 6 : 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1);
  }

  Widget _buildIcon(String type, bool isRead) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'leave':
        iconData = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case 'attendance':
        iconData = Icons.how_to_reg_rounded;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.campaign_outlined;
        iconColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  DateTime? _readTimestamp(dynamic raw) {
    if (raw is DateTime) return raw;
    return null;
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) {
      return '';
    }
    return DateFormat('MMM d, h:mm a').format(timestamp);
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> notification) async {
    final String notificationId = (notification['id'] ?? '').toString();
    final String type = (notification['type'] ?? 'general')
        .toString()
        .trim()
        .toLowerCase();

    await _markAsRead(notificationId);
    if (!mounted) return;

    if (type == 'attendance') {
      final args = Map<String, dynamic>.from(widget.loginData ?? {});
      args['initialIndex'] = 3;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoute.appmain,
        (route) => false,
        arguments: args,
      );
      return;
    }

    if (type == 'leave') {
      Navigator.of(
        context,
      ).pushNamed(AppRoute.leaveDatailScreen, arguments: widget.loginData);
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text((notification['title'] ?? '').toString()),
          content: Text((notification['message'] ?? '').toString()),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState({String? message}) {
    return DataEmptyState(
      imageAsset: AppImg.emptyState,
      iconColor: Colors.grey[300],
      spacing: 15,
      message: message ?? AppStrings.tr('no_notif'),
      textStyle: const TextStyle(color: AppColors.textGrey),
    );
  }
}
