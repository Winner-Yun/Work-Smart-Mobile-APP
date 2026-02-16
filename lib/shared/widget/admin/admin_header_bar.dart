import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/logic/admin_dashboard_logic.dart';

class AdminHeaderBar extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AdminHeaderBar(this.scaffoldKey, {super.key});

  @override
  State<AdminHeaderBar> createState() => _AdminHeaderBarState();
}

class _AdminHeaderBarState extends State<AdminHeaderBar> {
  bool _isProfileHovering = false;

  @override
  Widget build(BuildContext context) {
    return _buildHeader(context, false);
  }

  Widget _buildHeader(BuildContext context, bool isCompact) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).dividerColor.withOpacity(0.6);
    final isDarkMode = ThemeManager().isDarkMode;

    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 24),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          if (isCompact)
            IconButton(
              onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu_rounded),
            ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppStrings.tr('search_hint'),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(width: 20),
            _buildActionIcon(
              context: context,
              onTap: () => LanguageManager().changeLanguage(
                LanguageManager().locale == 'en' ? 'km' : 'en',
              ),
              child: Text(
                LanguageManager().locale.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            _buildActionIcon(
              context: context,
              onTap: () => ThemeManager().toggleTheme(!isDarkMode),
              child: Icon(
                isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                size: 20,
              ),
            ),
            _buildActionIcon(
              context: context,
              onTap: () {},
              child: const Icon(Icons.notifications_none_rounded, size: 22),
            ),
            const SizedBox(width: 12),
            const VerticalDivider(indent: 20, endIndent: 20),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Admin",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'HR Administrator',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            _buildHoverableProfile(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHoverableProfile(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isProfileHovering = true),
      onExit: (_) => setState(() => _isProfileHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _isProfileHovering
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            getInitials('Admin'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    required BuildContext context,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.6),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
