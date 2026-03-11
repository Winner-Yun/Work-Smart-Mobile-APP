import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/realtime_data_controller.dart';
import 'package:flutter_worksmart_mobile_app/core/util/database/user_data.dart';
import 'package:flutter_worksmart_mobile_app/features/user/presentation/profile&setting_screens/setting_screen.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';

abstract class SettingLogic extends State<SettingsScreen> {
  static final RealtimeDataController _dataController =
      RealtimeDataController();

  // --- State Variables ---
  late UserProfile currentUser;
  late String? loggedInUserId;
  bool isNotification = true;
  bool isSavingNotification = false;

  @override
  void initState() {
    super.initState();
    loggedInUserId = widget.loginData?['uid'];
    loadData();
  }

  void loadData() {
    final String userId = (widget.loginData?['uid'] ?? '').toString().trim();

    final Map<String, dynamic> currentUserData = userId.isEmpty
        ? defaultUserRecord
        : usersFinalData.firstWhere(
            (user) => user['uid']?.toString().trim() == userId,
            orElse: () => defaultUserRecord,
          );

    currentUser = UserProfile.fromJson(currentUserData);

    final dynamic appSettings = userId.isNotEmpty
        ? () {
            final int idx = usersFinalData.indexWhere(
              (u) => u['uid']?.toString().trim() == userId,
            );
            return idx != -1 ? usersFinalData[idx]['app_settings'] : null;
          }()
        : null;

    if (appSettings is Map) {
      isNotification = (appSettings['notifications_enabled'] as bool?) ?? true;
    }
  }

  Future<void> handleLanguageChange(
    BuildContext context,
    String langCode,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const CircularProgressIndicator(),
        ),
      ),
    );

    await LanguageManager().changeLanguage(langCode);
    await Future.delayed(const Duration(milliseconds: 250));

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoute.appmain,
        (route) => false,
        arguments: widget.loginData,
      );
    }
  }

  Future<void> handleNotificationChange(bool value) async {
    if (isSavingNotification) return;

    final String userId = (loggedInUserId ?? '').trim();
    if (userId.isEmpty) return;

    final bool previousValue = isNotification;
    setState(() {
      isNotification = value;
      isSavingNotification = true;
    });

    final int userIndex = usersFinalData.indexWhere(
      (user) => user['uid']?.toString().trim() == userId,
    );

    final Map<String, dynamic> appSettings =
        userIndex != -1 && usersFinalData[userIndex]['app_settings'] is Map
        ? Map<String, dynamic>.from(
            usersFinalData[userIndex]['app_settings'] as Map,
          )
        : <String, dynamic>{};

    appSettings['notifications_enabled'] = value;

    try {
      await _dataController.updateUserRecord(userId, {
        'app_settings': appSettings,
      });

      if (userIndex != -1) {
        usersFinalData[userIndex]['app_settings'] = appSettings;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isNotification = previousValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update notification setting.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingNotification = false;
        });
      }
    }
  }

  bool get isDarkMode => ThemeManager().isDarkMode;
}
