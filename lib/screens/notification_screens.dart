import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/config/appcolor.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Mock Data: List of Maps
  final List<Map<String, dynamic>> _notifications = [
    {
      "id": 1,
      "title": "ការស្នើសុំច្បាប់",
      "subtitle": "ច្បាប់សម្រាកប្រចាំឆ្នាំរបស់អ្នកត្រូវបានអនុម័ត។",
      "time": "២ ម៉ោងមុន",
      "type": "approval",
      "is_read": false,
    },
    {
      "id": 2,
      "title": "វត្តមាន",
      "subtitle": "កុំភ្លេចកត់ត្រាវត្តមានចេញពីធ្វើការនៅល្ងាចនេះ។",
      "time": "៥ ម៉ោងមុន",
      "type": "reminder",
      "is_read": false,
    },
    {
      "id": 3,
      "title": "ប្រកាសថ្មី",
      "subtitle": "ក្រុមហ៊ុននឹងឈប់សម្រាកនៅថ្ងៃបុណ្យអុំទូកខាងមុខនេះ។",
      "time": "ម្សិលមិញ",
      "type": "announcement",
      "is_read": true,
    },
  ];

  // Logic to delete a single notification
  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.primary,
        content: Text("បានលុបការជូនដំណឹង"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Show Bottom Sheet / Dialog on Long Press
  void _showActionMenu(int index) {
    final bool isRead = _notifications[index]['is_read'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 10,
      // Gives it that modern rounded corner look
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 30,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- MODERN DRAG HANDLE ---
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),

              // --- CONDITIONAL OPTION: MARK AS READ ---
              // Only shows if the notification is UNREAD
              if (!isRead)
                _buildMenuButton(
                  icon: Icons.done_all_rounded,
                  label: "សម្គាល់ថាបានអាន",
                  color: AppColors.primary,
                  onTap: () {
                    setState(() => _notifications[index]['is_read'] = true);
                    Navigator.pop(context);
                  },
                ),

              if (!isRead) const SizedBox(height: 12),

              // --- ALWAYS SHOW: DELETE ---
              _buildMenuButton(
                icon: Icons.delete_outline_rounded,
                label: "លុបការជូនដំណឹងនេះ",
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pop(context);
                  _deleteNotification(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationList(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.primary,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "ការជូនដំណឹង",
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        // Changed "Mark all as read" text to Icon
        IconButton(
          icon: const Icon(Icons.done_all, color: AppColors.primary),
          tooltip: "អានទាំងអស់",
          onPressed: () => setState(() {
            for (var n in _notifications) {
              n['is_read'] = true;
            }
          }),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withValues(alpha: 0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final item = _notifications[index];
        return GestureDetector(
          onLongPress: () => _showActionMenu(index), // TAP & HOLD LOGIC
          onTap: () => setState(() => item['is_read'] = true),
          child: _buildNotificationItem(item, index),
        );
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> data, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: data['is_read']
            ? AppColors.primary.withValues(alpha: 0.03)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: data['is_read']
              ? AppColors.primary.withValues(alpha: 0.03)
              : Colors.white,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(data['type'], data['is_read']),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      data['time'],
                      style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  data['subtitle'],
                  style: TextStyle(
                    color: AppColors.textDark.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (!data['is_read'])
            Container(
              margin: const EdgeInsets.only(left: 10, top: 5),
              width: 8,
              height: 8,
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
      case 'approval':
        iconData = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case 'reminder':
        iconData = Icons.alarm;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.campaign_outlined;
        iconColor = AppColors.primary;
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 15),
          const Text(
            "មិនទាន់មានការជូនដំណឹងនៅឡើយទេ",
            style: TextStyle(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}
