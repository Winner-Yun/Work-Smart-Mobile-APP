import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/restartwidget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotification = true;

  Future<void> _handleLanguageChange(
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
      ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
    );

    await LanguageManager().changeLanguage(langCode);
    await Future.delayed(const Duration(milliseconds: 800));

    if (context.mounted) {
      RestartWidget.restartApp(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeManager(), LanguageManager()]),
      builder: (context, child) {
        final isDarkMode = ThemeManager().isDarkMode;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(context),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              _buildSectionHeader(AppStrings.tr('general_section')),
              _buildPremiumGroup(context, [
                _buildLanguageTile(context),
                _buildCustomDivider(context),
                _buildGlassSwitchTile(
                  context,
                  Icons.dark_mode_rounded,
                  AppStrings.tr('dark_mode'),
                  Colors.purple,
                  isDarkMode,
                  (value) {
                    ThemeManager().toggleTheme(value);
                  },
                ),
                _buildCustomDivider(context),
                _buildGlassSwitchTile(
                  context,
                  Icons.notifications_active_rounded,
                  AppStrings.tr('notification_label'),
                  Colors.orange,
                  isNotification,
                  (v) => setState(() => isNotification = v),
                ),
                _buildCustomDivider(context),
              ]),
              const SizedBox(height: 30),
              _buildSectionHeader(AppStrings.tr('support_section')),
              _buildPremiumGroup(context, [
                _buildPremiumNavTile(
                  context,
                  Icons.headset_mic_rounded,
                  AppStrings.tr('help_support_title'),
                  Colors.blue,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoute.helpSupportScreen);
                  },
                ),
                _buildCustomDivider(context),
                _buildPremiumNavTile(
                  context,
                  Icons.auto_awesome_motion_rounded,
                  AppStrings.tr('about_app'),
                  Colors.indigo,
                  trailing: Text(
                    'v1.2.4',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 40),
              _buildBrandFooter(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTileContainer({
    required Widget child,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    bool isPressed = false;
    return StatefulBuilder(
      builder: (context, setLocalState) {
        return AnimatedContainer(
          duration: 150.ms,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isPressed
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTapDown: (_) => setLocalState(() => isPressed = true),
            onTapUp: (_) => setLocalState(() => isPressed = false),
            onTapCancel: () => setLocalState(() => isPressed = false),
            onTap: onTap,
            child: child,
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).iconTheme.color,
            size: 18,
          ),
        ),
      ),
      title: Text(
        AppStrings.tr('settings_title'),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 18,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w800,
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2);
  }

  Widget _buildPremiumGroup(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(children: children),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildLanguageTile(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: _buildGradientIcon(
        Icons.translate_rounded,
        Colors.blue,
        Colors.cyan,
      ),
      title: Text(
        AppStrings.tr('language_label'),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _premiumLangBtn('ខ្មែរ', context),
            _premiumLangBtn('EN', context),
          ],
        ),
      ),
    );
  }

  Widget _premiumLangBtn(String text, BuildContext context) {
    final String codeToCheck = (text == 'ខ្មែរ') ? 'km' : 'en';
    bool active = LanguageManager().locale == codeToCheck;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (!active) {
          _handleLanguageChange(context, codeToCheck);
        }
      },
      child: AnimatedContainer(
        duration: 250.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).scaffoldBackgroundColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active
                ? (isDark ? Colors.white : const Color(0xFF004C4C))
                : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassSwitchTile(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    bool value,
    Function(bool) onChanged,
  ) {
    return _buildAnimatedTileContainer(
      context: context,
      onTap: () => onChanged(!value),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: _buildGradientIcon(icon, color, color.withOpacity(0.5)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF004C4C),
        ),
      ),
    );
  }

  Widget _buildPremiumNavTile(
    BuildContext context,
    IconData icon,
    String title,
    Color color, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return _buildAnimatedTileContainer(
      context: context,
      onTap: onTap ?? () {},
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: _buildGradientIcon(icon, color, color.withOpacity(0.5)),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 24,
            ),
      ),
    );
  }

  Widget _buildGradientIcon(IconData icon, Color startColor, Color endColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _buildCustomDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.1),
      indent: 70,
      endIndent: 20,
    );
  }

  Widget _buildBrandFooter(BuildContext context) {
    return Column(
      children: [
        Text(
          'WORKSMART',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        Text(
          'CAMBODIA EDITION',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 800.ms);
  }
}
